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

resource hwf_staff 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'hwf-staff-${env}'
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

        // TODO see why this doesn't work for other apps to talk to it
        // ipSecurityRestrictions: [
        //   {
        //     action: 'Allow'
        //     description: 'petr_home'
        //     ipAddressRange: '88.97.40.133/32'
        //     name: 'petr_home'
        //   }
        //   {
        //     action: 'Allow'
        //     description: 'tim_home'
        //     ipAddressRange: '82.9.48.2/32'
        //     name: 'timj_home'
        //   }
        //   {
        //     action: 'Allow'
        //     description: 'public app'
        //     ipAddressRange: '51.11.62.203/32'
        //     name: 'environment_outbound_ip'
        //   }
        // ]
      }

      registries: [
        {
          identity: uami.id
          server: 'employmenttribunal.azurecr.io'

        }
      ]

      secrets: [
        {
          name: 'hwf-staff-secret-token'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-secret-token'
        }
        {
          name: 'hwf-staff-submission-token'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-submission-token'
        }
        {
          name: 'hwf-staff-appinsights-key'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-appinsights-key'
        }
        {
          name: 'hwf-staff-sentry-dsn'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-sentry-dsn'
        }
        {
          name: 'hwf-staff-db-password'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-db-password'
        }
        {
          name: 'hwf-staff-db-host'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-db-host'
        }
        {
          name: 'hwf-staff-db-name'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-db-name'
        }
        {
          name: 'hwf-staff-db-user-name'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-db-user-name'
        }
        {
          name: 'hwf-staff-smtp-username'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-smtp-username'
        }
        {
          name: 'hwf-staff-smtp-password'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-smtp-password'
        }
        {
          name: 'hwf-staff-dwp-notification-alert-emails'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-dwp-notification-alert-emails'
        }
        {
          name: 'hwf-staff-hmrc-ttp-secret'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-hmrc-ttp-secret'
        }
        {
          name: 'hwf-staff-hmrc-client-id'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-hmrc-client-id'
        }
        {
          name: 'hwf-staff-hmrc-secret'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-hmrc-secret'
        }
        {
          name: 'hwf-staff-hmrc-api-url'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-hmrc-api-url'
        }
        {
          name: 'hwf-staff-notify-api-key'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-notify-api-key'
        }

        {
          name: 'hwf-staff-hmrc-office-code'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-hmrc-office-code'
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
          image: 'employmenttribunal.azurecr.io/hwf-staff:master-84ae717'
          name: 'hwf-staff'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'SERVICE_NOW_EMAIL'
              value: 'DCD-HWFSupportServiceDeskDEV@HMCTS.NET'
            }
            {
              name: 'RAILS_SERVE_STATIC_FILES'
              value: 'true'
            }
            {
              name: 'SECRET_TOKEN'
              secretRef: 'hwf-staff-secret-token'
            }
            {
              name: 'SUBMISSION_TOKEN'
              secretRef: 'hwf-staff-submission-token'
            }
            {
              name: 'AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY'
              secretRef: 'hwf-staff-appinsights-key'
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
              name: 'SENTRY_DSN'
              secretRef: 'hwf-staff-sentry-dsn'
            }
            {
              name: 'SENTRY_SSL_VERIFICATION'
              value: 'false'
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
              name: 'DOCKER_STATE'
              value: 'migrate'
            }
            {
              name: 'DB_PASSWORD'
              secretRef: 'hwf-staff-db-password'
            }
            {
              name: 'DB_HOST'
              secretRef: 'hwf-staff-db-host'
            }
            {
              name: 'DB_PORT'
              value: '5432'
            }
            {
              name: 'DB_USERNAME'
              secretRef: 'hwf-staff-db-user-name'
            }
            {
              name: 'DB_NAME'
              secretRef: 'hwf-staff-db-name'
            }
            {
              name: 'SMTP_DOMAIN'
              value: 'staff.demo.hwf.dsd.io'
            }
            {
              name: 'SMTP_HOSTNAME'
              value: 'smtp.sendgrid.net'
            }
            {
              name: 'SMTP_PORT'
              value: '587'
            }
            {
              name: 'SMTP_USERNAME'
              secretRef: 'hwf-staff-smtp-username'
            }
            {
              name: 'SMTP_PASSWORD'
              secretRef: 'hwf-staff-smtp-password'
            }
            {
              name: 'DWP_API_PROXY'
              value: dwpApiProxyUrl
            }
            {
              name: 'DWP_NOTIFICATION_ALERT_EMAILS'
              secretRef: 'hwf-staff-dwp-notification-alert-emails'
            }
            {
              name: 'ACTIVE_JOB_ENABLED'
              value: 'true'
            }
            {
              name: 'HMRC_TTP_SECRET'
              secretRef: 'hwf-staff-hmrc-ttp-secret'
            }
            {
              name: 'HMRC_CLIENT_ID'
              secretRef: 'hwf-staff-hmrc-client-id'
            }
            {
              name: 'HMRC_SECRET'
              secretRef: 'hwf-staff-hmrc-secret'
            }
            {
              name: 'HMRC_API_URL'
              secretRef: 'hwf-staff-hmrc-api-url'
            }
            {
              name: 'NOTIFY_COMPLETED_NEW_REFUND_TEMPLATE_ID'
              value: 'dbd72fa4-0232-4825-9460-b6f1d369b481'
            }
            {
              name: 'NOTIFY_COMPLETED_ONLINE_TEMPLATE_ID'
              value: 'ab017b1b-0f5a-45df-b2c5-467f97a54828'
            }
            {
              name: 'NOTIFY_COMPLETED_PAPER_TEMPLATE_ID'
              value: '115e4918-ce48-4bfe-8784-1b8404237d4c'
            }
            {
              name: 'NOTIFY_COMPLETED_CY_NEW_REFUND_TEMPLATE_ID'
              value: 'd92e6d1d-08b6-4124-84d3-a93bfb6b4c26'
            }

            {
              name: 'NOTIFY_COMPLETED_CY_ONLINE_TEMPLATE_ID'
              value: '61cb8166-c137-459b-b1c0-b0ca63c1da6e'
            }

            {
              name: 'NOTIFY_COMPLETED_CY_PAPER_TEMPLATE_ID'
              value: '9f52cb39-33bd-4df6-871c-e337c058972b'
            }

            {
              name: 'NOTIFY_PASSWORD_RESET_TEMPLATE_ID'
              value: 'fc94a9eb-99d1-47ad-a5d0-f47f16128766'
            }

            {
              name: 'NOTIFY_DWP_DOWN_TEMPLATE_ID'
              value: '22025e7a-1bdd-450b-bb8f-a35f7493bd7c'
            }
            {
              name: 'GOVUK_NOTIFY_API_KEY'
              secretRef: 'hwf-staff-notify-api-key'
            }
            {
              name: 'HMRC_OFFICE_CODE'
              secretRef: 'hwf-staff-hmrc-office-code'
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
          name: 'hwf-benefit-checker-api-api-org-id'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-benefit-checker-api-api-org-id'
        }
        {
          name: 'hwf-benefit-checker-api-api-user-id'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-benefit-checker-api-api-user-id'
        }
        {
          name: 'hwf-benefit-checker-api-api-service-name'
          identity: uami.id
          keyVaultUrl: '${hwfVault}/${env}-hwf-benefit-checker-api-api-service-name'
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
              secretRef: 'hwf-benefit-checker-api-api-org-id'
            }
            {
              name: 'API_USER_ID'
              secretRef: 'hwf-benefit-checker-api-api-user-id'
            }
            {
              name: 'API_SERVICE_NAME'
              secretRef: 'hwf-benefit-checker-api-api-service-name'
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
