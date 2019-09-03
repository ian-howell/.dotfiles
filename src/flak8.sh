#!/bin/bash
set -x

echo "Getting flake8"

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$(mktemp -d)}"

sudo python3 -m pip install flake8

set +x
