#!/usr/bin/env bash

ENV=$1

az deployment group create --resource-group pet-$ENV-rg --template-file hwf.bicep --parameters $ENV/hwf.bicepparam
