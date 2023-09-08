#!/usr/bin/env bash

# apex
# az containerapp env show -n petapps-$ENV -g pet-$ENV-rg -o tsv --query "properties.staticIp"

ENV=dev
APP=hwf-public-$ENV

az containerapp show -n $APP -g pet-$ENV-rg  -o tsv --query "properties.configuration.ingress.fqdn"