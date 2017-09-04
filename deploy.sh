#!/bin/sh

ssh cloud_drive-server '
cd cloud_drive
git pull

mix deps.get

# Build without making a tar
MIX_ENV=prod mix release --env=prod --no-tar

# Kill previous server process
kill $(lsof -i tcp:8000 -t) &>/dev/null

# Start server in daemon mode
_build/prod/rel/cloud_drive/bin/cloud_drive start
'