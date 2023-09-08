#!/usr/bin/env bash

# Example: ./add-custom-domain.sh hwf-staff-ext dev staff.help-with-fees.dev.platform.hmcts.net CNAME

ENV=$2

#hwf-staff-ext
#hwf-public
APP=$1-$ENV
HOSTNAME=$3
# HTTP or CNAME
VALIDATION_METHOD=$4

set -x

az containerapp hostname add -n $APP -g pet-$ENV-rg  --hostname $HOSTNAME
az containerapp hostname bind -n $APP -g pet-$ENV-rg  --hostname $HOSTNAME --environment petapps-$ENV --validation-method $VALIDATION_METHOD
