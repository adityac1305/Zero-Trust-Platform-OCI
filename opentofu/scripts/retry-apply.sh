#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT=${1:-lab}

while true; do
  echo "======================================"
  echo "Running tofu apply at $(date)"
  echo "======================================"

  cd "opentofu/environments/${ENVIRONMENT}"

  tofu apply -auto-approve "${ENVIRONMENT}.tfplan" && break

  echo ""
  echo "Apply failed. Retrying in 5 minutes..."
  echo ""

  cd ../../..

  sleep 300
done

echo ""
echo "Infrastructure applied successfully."