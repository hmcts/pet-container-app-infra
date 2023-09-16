#!/usr/bin/env bash


#usage ./deploy.sh hwf dev

PRODUCT=$1
ENV=$2

az deployment group create --resource-group pet-$ENV-rg --template-file $PRODUCT.bicep --parameters $ENV/$PRODUCT.bicepparam
