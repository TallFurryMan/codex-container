# Repository Guidelines

This document gives contributors a quick reference for how to work on this
project.  Follow the sections below to keep the codebase clean, consistent
and approachable.

## Project Structure & Module Organization

- `Dockerfile` – Builds a multi‑arch image with Python, Arduino, Pico SDK,
  Docker client, and the OpenAI Codex CLI.
- `Makefile` – Convenience targets for building, testing, and debugging.
- `test.sh` – Shell script run inside the container to validate tool
  installations.
- `README.md` – Project overview and usage guidelines.
- `AGENTS.md` – This file (contributor guide).

Place all source code in the container; the repository itself just stores
configuration and CI artifacts.

## Build, Test, and Development Commands

| Target | Command | What it does |
|--------|---------|--------------|
| `make build` | Builds multi‑arch image (`linux/amd64` + `linux/arm64`). | Prepares the toolset for cross‑platform testing.
| `make test` | Build image → run `test.sh` inside container. | Runs sanity checks for Docker client, Python, Arduino CLI
  and Pico SDK.
| `make shell` | `docker run -it` with host Docker socket. | Interactive Bash in the container.

All commands use the host’s Docker daemon via a bundled socket.  On macOS
with Colima, set `DOCKER_SOCKET=/Users/you/.colima/default/docker.sock`.

## Coding Style & Naming Conventions

* **Python** – 4‑space indentation; use `python -m black .` for formatting.
* **Shell** – `sh`/`bash` scripts start with `#!/usr/bin/env bash` and use
  `set -euo pipefail`.
* **File names** – snake_case for scripts; CamelCase for source modules.
* Run `pre-commit` installs: `black`, `flake8`, `shellcheck`.

## Testing Guidelines

The repository uses a single shell test (`test.sh`).  Tests are
lightweight sanity checks:

* Verify required binaries (`python`, `arduino-cli`, `docker`, `codex`).
* Show minimal output from `docker info` if the daemon is reachable.
* Report missing components but continue with the rest.

Run with `make test` and review the summary output.

## Commit & Pull Request Guidelines

* Commit messages use the Conventional Commits format: `feat: …`, `fix: …`.
* PR titles should match the commit title and describe the change.
* Include a description, any affected test files, and screenshots if
  applicable.
* Attach related issue numbers via `Closes #123`.

## Other Tips

* If you need to add new tools to the Docker image, edit `Dockerfile` and
  rerun `make build`.
* For VS Code dev containers or GitHub Actions, the same `Dockerfile` can be
  reused; just adjust the socket path via `-v $(DOCKER_SOCKET):/var/run/docker.sock`.

Happy coding!

