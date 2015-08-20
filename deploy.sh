#!/bin/bash

# set -u fails the script if there are any undefiend environment variables

set -e -u

pull() {
  local server=$1
  echo "Pulling repository on $server"
  ssh core@$server "docker pull pocketplaylab/$CIRCLE_PROJECT_REPONAME:$CIRCLE_BRANCH"
}

env=$1
## Deploy on prod or staging
## Variables below have to be declared in CircleCI
if [[ $env == 'production' ]]; then
  FILTER="DEPLOY_CORE_PROD"
  MASTER=$DEPLOY_CORE_PROD1
elif [[ $env == 'staging' ]]; then
  FILTER="DEPLOY_CORE_STAGING"
  MASTER=$DEPLOY_CORE_STAGING1
fi
###
# Need to pull on all servers
for i in $(env|grep $FILTER|cut -d "=" -f 2)
do
  pull "$i" &
done
wait

# Then connect to one controller is enough
ssh core@$MASTER  "fleetctl stop sentry presence-sentry \
	 && fleetctl start sentry presence-sentry"

echo -e "Please wait while the container starts up...\n"

sleep 15

# Grepping <service>.service in case there are other services with similar names
# Please replace <service> with your own
echo -e ""
ssh core@$MASTER "fleetctl list-units |grep sentry"
echo -e ""
## Checking status of the unit
echo -e "Check status ^^^above^^^ about the unit\n"
echo -e ""
sleep 15
echo -e "All done\n"
echo -e ""