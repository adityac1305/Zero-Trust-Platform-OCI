#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT=${1:-lab}

cd "opentofu/environments/${ENVIRONMENT}"

tofu apply "${ENVIRONMENT}.tfplan"