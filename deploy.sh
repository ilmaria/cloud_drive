#!/bin/sh
set -eu

mosh cloud_drive-server
cd cloud_drive

mix deps.get
MIX_ENV=prod mix release --env=prod --no-tar

_build/prod/rel/cloud_drive/bin/cloud_drive start