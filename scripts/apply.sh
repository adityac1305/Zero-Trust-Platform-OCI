#!/usr/bin/env bash

set -euo pipefail

ENVIRONMENT=${1:-lab}

cd "environments/${ENVIRONMENT}"

tofu apply "${ENVIRONMENT}.tfplan"