# Contributing

## Workflow

1. Fork and branch from `main`.
2. Make changes. Run `make lint test`.
3. Open a PR with a clear description.

## Issues

Bugs: include SDK version, device (and firmware), and reproduction — state whether it
reproduces in the simulator, on hardware, or both.
Features: describe the use case before the proposed API.

## Commit messages

Conventional Commits: `feat:`, `fix:`, `docs:`, etc.
Breaking changes: `feat!: ...`.

## Before you push

Never commit a signing key (`*.der`, `*.pem`, `developer_key*`). A pre-commit hook and a
CI gate both block it. If one is pushed anyway, rotate it — the history is public.
