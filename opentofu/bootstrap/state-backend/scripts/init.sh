#!/usr/bin/env bash

set -euo pipefail

cd opentofu/bootstrap/state-backend

tofu init -input=false -reconfigure
