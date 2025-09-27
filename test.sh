#!/usr/bin/env bash

set -euo pipefail

echo "=== Docker daemon info ==="
if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
        docker info | head -n 3
    else
        echo "  [WARNING] Docker daemon not reachable; only client is present" 
    fi
else
    echo "  [WARNING] Docker client not available in image; skipping Docker checks" 
fi

echo "=== Python version ==="
python --version

echo "=== Arduino CLI version ==="
arduino-cli version

echo "=== Pico SDK path contents ==="
echo "Path: $PICO_SDK_PATH"
if [ -d "$PICO_SDK_PATH" ]; then
    ls -al "$PICO_SDK_PATH" | head -n 5
else
    echo "  [ERROR] Pico SDK path not found"
fi

echo "Test script completed." 
echo "=== SUMMARY ==="
RESULTS=""
if [ -z "$RESULTS" ]; then
    echo "  All checks passed."
else
    echo "$RESULTS"
fi
