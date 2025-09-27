#!/usr/bin/env bash

# Codex‑Tools Docker Image

This repository contains a minimal, cross‑platform Docker image pre‑loaded with
the following tools:

| Tool | Purpose |
|------|---------|
| **Python 3.11** | Primary language runtime (used by the Codex CLI). |
| **OpenAI Python SDK** | `codex` command for interacting with the OpenAI API. |
| **Arduino CLI** | Flashing firmware to AVR/ARM based boards. |
| **Raspberry Pi Pico SDK** | CMake‑based SDK for developing tiny‑OS‑style firmware. |
| **Bash** | Interactive debugging inside the container. |
| **docker‑ce‑cli** | Docker client for running host‑side Docker commands from
  within the image. |

The image is built for **amd64** and **arm64** (and can be extended easily). It
uses a build script to fetch the latest Pico SDK and the official Arduino CLI
installer. The Docker client is installed from the official Debian mirrors and
is selected at build time using `uname -m`.

## Building the Image

```bash
make build
```

The command uses Docker *buildx* to produce a single image that contains both
architectures, which can be pushed to a registry or used locally.

## Running the Test Suite
This repository ships a small `test.sh` script that verifies basic runtime
capabilities. The script can be run directly from the host or inside the
container.

```bash
make test
```

* The `test.sh` script will: 
  1. Check that the Docker client is present. It warns if the host daemon is not
     reachable but will continue. 
  2. Print the host Python version, Arduino CLI version, and Pico SDK path
     contents. 
  3. Show the first few lines of `docker info` if the daemon can be reached.

### Quick‑Start (interactive shell)

```bash
make shell
```

The container will drop you into a `bash` shell with the tools available.

## Usage as a Tooling Container

The image is primarily intended to act as a drop‑in build environment for
Arduino and Pico firmware projects that need a consistent, reproducible set of
dependencies. It can be used as a CI runner as well.

## File Structure

```
Dockerfile      – Minimal Dockerfile for the image
Makefile        – Convenience target for build / test / shell
test.sh         – Self‑contained sanity‑check script
README.md       – This file
```

All files are licensed under the MIT license.

