#!/usr/bin/env bash

# Docs:
# https://learn.microsoft.com/en-us/azure/container-apps/custom-domains-managed-certificates?pivots=azure-cli

ENV=$2

#hwf-staff-ext
#hwf-public
APP=$1-$ENV

az containerapp env show -n petapps-$ENV -g pet-$ENV-rg -o tsv --query "properties.staticIp"
az containerapp show -n $APP -g pet-$ENV-rg  -o tsv --query "properties.configuration.ingress.fqdn"

az containerapp show -n $APP -g pet-$ENV-rg -o tsv --query "properties.customDomainVerificationId"

