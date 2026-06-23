#!/usr/bin/env bash
# Run the Duas app in Chrome on a fixed port.
set -e

PORT=8910

cd "$(dirname "$0")"

flutter run -d chrome --web-port "$PORT" --web-hostname 127.0.0.1
