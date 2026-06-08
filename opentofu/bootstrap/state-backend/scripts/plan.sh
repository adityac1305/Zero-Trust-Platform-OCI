#!/usr/bin/env bash

set -euo pipefail

cd opentofu/bootstrap/state-backend

tofu plan -var-file=bootstrap.tfvars -out=bootstrap.tfplan
