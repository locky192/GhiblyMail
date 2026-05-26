#!/usr/bin/env bash
set -euo pipefail

echo "== Swift build =="
swift build

echo "== Swift tests and security checks =="
scripts/security-check.sh

echo "== Codex readiness =="
codex --version
codex login status

node - <<'NODE'
const { spawn } = require('child_process');
const codex = spawn('codex', ['app-server'], { stdio: ['pipe', 'pipe', 'pipe'] });
let buf = '';
let account = null;
let gmail = null;
let finished = false;
function finish() {
  if (finished) return;
  finished = true;
  codex.kill('SIGTERM');
  if (!account || account.type !== 'chatgpt') {
    console.error('Codex is not logged in with ChatGPT-managed auth.');
    process.exit(1);
  }
  if (!gmail?.installed || !gmail?.enabled) {
    console.error('gmail@openai-curated is not installed and enabled.');
    process.exit(1);
  }
  console.log(JSON.stringify({ account: { type: account.type, planType: account.planType }, gmail }, null, 2));
}
codex.stdout.on('data', chunk => {
  buf += chunk.toString();
  let i;
  while ((i = buf.indexOf('\n')) >= 0) {
    const line = buf.slice(0, i).trim();
    buf = buf.slice(i + 1);
    if (!line) continue;
    const msg = JSON.parse(line);
    if (msg.id === 2) account = msg.result?.account ?? null;
    if (msg.id === 3 && msg.result) {
      for (const m of msg.result.marketplaces ?? []) {
        for (const p of m.plugins ?? []) {
          if (p.id === 'gmail@openai-curated') {
            gmail = { id: p.id, installed: p.installed, enabled: p.enabled };
          }
        }
      }
    }
    if (account && gmail) finish();
  }
});
function send(message) { codex.stdin.write(JSON.stringify(message) + '\n'); }
send({ method: 'initialize', id: 1, params: { clientInfo: { name: 'ghiblymail_mvp_check', title: 'GhiblyMail MVP Check', version: '0.1.0' } } });
send({ method: 'initialized', params: {} });
send({ method: 'account/read', id: 2, params: { refreshToken: false } });
send({ method: 'plugin/list', id: 3, params: { limit: 200 } });
setTimeout(finish, 20000);
NODE

if [[ "${GHIBLYMAIL_CHECK_GMAIL_LABEL:-0}" == "1" ]]; then
  echo "== Optional no-write Gmail label smoke test =="
  codex exec --skip-git-repo-check --sandbox read-only \
    'Use the installed Gmail plugin only. Do not modify Gmail. Check whether the Gmail label ghiblymail-test exists and return only compact JSON with keys labelExists, threadCount if available, and error if any. Do not include email subjects, senders, snippets, or message bodies.'
else
  echo "Skipping live Gmail label check. Set GHIBLYMAIL_CHECK_GMAIL_LABEL=1 to run it."
fi

echo "MVP checks passed."
