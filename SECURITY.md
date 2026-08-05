# Security Policy

Riftwire is an early-stage offline game project. Security still matters for dependencies, build tooling, imported assets, save files, and future distribution.

## Reporting a vulnerability

For sensitive vulnerabilities, use GitHub's private vulnerability reporting or a private Security Advisory for this repository. Do not open a public Issue containing exploit details, leaked credentials, or private user data.

For non-sensitive hardening suggestions, open a regular Issue with a minimal description and no weaponized proof of concept.

## Scope

Security-relevant areas include:

- dependency or editor-plugin supply-chain risks;
- arbitrary file access through save/import tooling;
- unsafe command execution in developer tools or agents;
- untrusted archive or asset parsing;
- secret leakage in commits, logs, screenshots, replays, or CI artifacts;
- future online or telemetry features.

## Repository rules

- Never commit tokens, passwords, private keys, cookies, or service credentials.
- Do not execute scripts from imported asset packs without review.
- Pin and review third-party addons before adoption.
- Agents must not change secrets, permissions, workflows, or release credentials without explicit human approval.
- Treat save files, replay files, and mod-like content as untrusted input.

There is no guaranteed response window while the project remains pre-production, but valid reports will be acknowledged and tracked privately where possible.
