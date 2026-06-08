#!/usr/bin/env bash

set -euo pipefail

echo "WARNING: This will destroy the OpenTofu state bucket."

read -r -p "Type YES to continue: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
  echo "Aborted."
  exit 1
fi

cd opentofu/bootstrap/state-backend

tofu destroy -var-file=bootstrap.tfvars