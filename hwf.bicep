param location string = 'uksouth'

var hwfVaultName = 'f74dd7b303a6devops'
var hwfVault = 'https://${hwfVaultName}.vault.azure.net/secrets'

param env string = 'dev'

param publicSubmissionUrl string
param dwpApiProxyUrl string
param laaBenefitCheckerUrl string

param serviceNowEmail string
param benefitApiPath string

var subnetId = '/subscriptions/58a2ce36-4e09-467b-8330-d164aa559c68/resourceGroups/pet_${env}_network_resource_group/providers/Microsoft.Network/virtualNetworks/pet_${env}_network/subnets/pet_dmz_${env}'

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'hwf-${env}'
  location: location
}

module keyVaultAccessPolicy 'key_vault_access_policy.module.bicep' = {
  name: 'keyVaultDeployment'
  scope: resourceGroup('genesis_resource_group')
  params: {
    vaultName: hwfVaultName
    objectId: uami.properties.principalId
  }
}

module acrPull 'role_assignment.module.bicep' = {
  name: 'acrPull'
  scope: resourceGroup('et_dev_etazure_resource_group')
  params: {
    principalId: uami.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    roleAssignmentName: guid(subscription().id, 'hwf-${env}-acr-pull')
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-03-01-preview' = {
  name: 'petapps-${env}'
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource environment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: 'petapps-${env}'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference(logAnalyticsWorkspace.id, '2020-03-01-preview').customerId
        sharedKey: listKeys(logAnalyticsWorkspace.id, '2020-03-01-preview').primarySharedKey
      }
    }

    vnetConfiguration: {
      // dockerBridgeCidr: ''
      infrastructureSubnetId: any(subnetId)
      // internal: false
      // platformReservedCidr: ''
      // platformReservedDnsIP: ''
    }

    workloadProfiles: [
      {
        maximumCount: 10
        minimumCount: 1
        name: 'pet-apps'
        workloadProfileType: 'D4'
      }
    ]
  }
}

resource hwf_public 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'hwf-public-${env}'
  location: location

  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: environment.id

    configuration: {
      ingress: {
        external: true
        targetPort: 3000

        ipSecurityRestrictions: [
          {
            action: 'Allow'
            description: 'petr_home'
            ipAddressRange: '88.97.40.133/32'
            name: 'petr_home'
          }
          {
            action: 'Allow'
            description: 'tim_home'
            ipAddressRange: '82.9.48.2/32'
            name: 'timj_home'
          }
        ]
      }

      registries: [
        {
          identity: uami.id
          server: 'employmenttribunal.azurecr.io'

        }
      ]

      secrets: [
        {
          name: 'hwf-public-secret-token'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-secret-token'
        }
        {
          name: 'hwf-public-appinsights-key'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-appinsights-key'
        }
        {
          name: 'hwf-public-submission-token'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-submission-token'
        }
        {
          name: 'hwf-public-sentry-dsn'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-sentry-dsn'
        }
        {
          name: 'hwf-public-zendesk-url'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-zendesk-url'
        }
        {
          name: 'hwf-public-zendesk-username'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-zendesk-username'
        }
        {
          name: 'hwf-public-zendesk-token'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-zendesk-token'
        }
        {
          name: 'hwf-public-smtp-username'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-smtp-username'
        }
        {
          name: 'hwf-public-smtp-password'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-smtp-password'
        }
        {
          name: 'hwf-public-address-lookup-endpoint'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-address-lookup-endpoint'
        }
        {
          name: 'hwf-public-address-lookup-api-key'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-address-lookup-api-key'
        }
        {
          name: 'hwf-public-address-lookup-api-secret'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-address-lookup-api-secret'
        }
        {
          name: 'hwf-maintenance-enabled'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-maintenance-enabled'
        }
        {
          name: 'hwf-maintenance-allowed-ips'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-maintenance-allowed-ips'
        }
      ]
    }

    template: {
      containers: [
        {
          image: 'employmenttribunal.azurecr.io/hwf-public:master-26ec9ea'
          name: 'hwf-public'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'HELP_ME_EMAIL'
              value: 'helpwithfees@justice.gov.uk'
            }
            {
              name: 'RAILS_SERVE_STATIC_FILES'
              value: 'true'
            }
            {
              name: 'SECRET_TOKEN'
              secretRef: 'hwf-public-secret-token'
            }
            {
              name: 'AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY'
              secretRef: 'hwf-public-appinsights-key'
            }
            {
              name: 'RAILS_ENV'
              value: 'production'
            }
            {
              name: 'RACK_ENV'
              value: 'production'
            }
            {
              name: 'WEB_CONCURRENCY'
              value: '1'
            }
            {
              name: 'SUBMISSION_URL'
              value: publicSubmissionUrl
            }
            {
              name: 'SUBMISSION_TOKEN'
              secretRef: 'hwf-public-submission-token'
            }
            {
              name: 'SENTRY_DSN'
              secretRef: 'hwf-public-sentry-dsn'
            }
            {
              name: 'SENTRY_SSL_VERIFICATION'
              value: 'false'
            }
            {
              name: 'ZENDESK_ENABLED'
              value: 'true'
            }
            {
              name: 'ZENDESK_URL'
              secretRef: 'hwf-public-zendesk-url'
            }
            {
              name: 'ZENDESK_USERNAME'
              secretRef: 'hwf-public-zendesk-username'
            }
            {
              name: 'ZENDESK_TOKEN'
              secretRef: 'hwf-public-zendesk-token'
            }
            {
              name: 'RAILS_LOG_TO_STDOUT'
              value: 'true'
            }
            {
              name: 'LOG_LEVEL'
              value: 'info'
            }
            {
              name: 'SMTP_USERNAME'
              secretRef: 'hwf-public-smtp-username'
            }
            {
              name: 'SMTP_PASSWORD'
              secretRef: 'hwf-public-smtp-password'
            }
            {
              name: 'ADDRESS_LOOKUP_ENDPOINT'
              secretRef: 'hwf-public-address-lookup-endpoint'
            }
            {
              name: 'ADDRESS_LOOKUP_API_KEY'
              secretRef: 'hwf-public-address-lookup-api-key'
            }
            {
              name: 'ADDRESS_LOOKUP_API_SECRET'
              secretRef: 'hwf-public-address-lookup-api-secret'
            }
            {
              name: 'MAINTENANCE_ENABLED'
              secretRef: 'hwf-maintenance-enabled'
            }
            {
              name: 'MAINTENANCE_ALLOWED_IPS'
              secretRef: 'hwf-maintenance-allowed-ips'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }

    }
  }
  dependsOn: [
    keyVaultAccessPolicy, acrPull
  ]
}

module hwfStaffPublic 'hwf_staff.module.bicep' = {
  name: 'hwfStaffPublic'
  params: {
    env: env
    uamiId: uami.id
    environmentId: environment.id
    location: location
    hwfVault: hwfVault
    dwpApiProxyUrl: dwpApiProxyUrl
    external: true
  }
}

module hwfStaffInternal 'hwf_staff.module.bicep' = {
  name: 'hwfStaffInternal'
  params: {
    env: env
    uamiId: uami.id
    environmentId: environment.id
    location: location
    hwfVault: hwfVault
    dwpApiProxyUrl: dwpApiProxyUrl
    external: false
  }
}

resource hwf_benefit_checker_api 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'hwf-benefit-checker-api-${env}'
  location: location

  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: environment.id

    configuration: {
      ingress: {
        external: true
        targetPort: 3000
      }

      registries: [
        {
          identity: uami.id
          server: 'employmenttribunal.azurecr.io'

        }
      ]

      secrets: [
        {
          name: 'hwf-benefit-checker-api-org-id'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-benefit-checker-api-org-id'
        }
        {
          name: 'hwf-benefit-checker-api-user-id'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-benefit-checker-api-user-id'
        }
        {
          name: 'hwf-benefit-checker-api-service-name'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-benefit-checker-api-service-name'
        }
        {
          name: 'hwf-public-appinsights-key'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-public-appinsights-key'
        }
      ]
    }

    template: {
      containers: [
        {
          image: 'employmenttribunal.azurecr.io/hwf-benefit-checker-api:v2.3.2'
          name: 'hwf-benefit-checker-api'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'RAILS_ENV'
              value: 'production'
            }
            {
              name: 'RACK_ENV'
              value: 'production'
            }
            {
              name: 'WEB_CONCURRENCY'
              value: '1'
            }
            {
              name: 'SERVICE_NOW_EMAIL'
              value: serviceNowEmail
            }
            {
              name: 'API_XMLNS'
              value: 'https://lsc.gov.uk/benefitchecker/service/1.0/API_1.0_Check'
            }
            {
              name: 'API_HOST'
              value: laaBenefitCheckerUrl
            }
            {
              name: 'API_PATH'
              value: benefitApiPath
            }
            {
              name: 'API_ORG_ID'
              secretRef: 'hwf-benefit-checker-api-org-id'
            }
            {
              name: 'API_USER_ID'
              secretRef: 'hwf-benefit-checker-api-user-id'
            }
            {
              name: 'API_SERVICE_NAME'
              secretRef: 'hwf-benefit-checker-api-service-name'
            }
            {
              name: 'AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY'
              secretRef: 'hwf-public-appinsights-key'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }

    }
  }

  dependsOn: [
    keyVaultAccessPolicy, acrPull
  ]

}
