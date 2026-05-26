# Prompt Injection Fixtures

This directory will hold test fixtures for malicious or adversarial messages.

Fixtures should cover:

- Direct instruction override attempts.
- Hidden HTML instructions.
- Encoded or obfuscated instructions.
- Malicious attachment text.
- Calendar invite injection.
- Unsubscribe page injection.
- Research page injection.
- Memory poisoning attempts.
- Data exfiltration attempts.

Expected invariant:

- The app may summarize malicious content as message content, but must not obey it as an instruction or execute unauthorized actions.
