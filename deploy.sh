#!/bin/sh

ssh -tt cloud_drive-server <<'ENDSSH'
(cd cloud_drive &&
git pull &&
mix deps.get &&
MIX_ENV=prod mix release --env=prod --no-tar &&
_build/prod/rel/cloud_drive/bin/cloud_drive start
logout)
ENDSSH