#!/bin/bash

set -e

pull() {
  local server=$1
  echo "Pulling repository on $server"
  ssh core@$server "docker pull pocketplaylab/$CIRCLE_PROJECT_REPONAME:latest"
}

# Need to pull on all servers
for i in $(env|grep CORE|cut -d "=" -f 2)
do
  pull "$i" &
done
wait

# Then connect to one controller is enough
ssh core@$CORE1  "fleetctl stop sentry presence-sentry && fleetctl start sentry presence-sentry"
