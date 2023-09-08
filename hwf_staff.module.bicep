param location string = 'UK South'
param env string
param uamiId string

param environmentId string
param hwfVault string
param dwpApiProxyUrl string

param external bool

param domainName string = ''
param certificateId string = ''

resource hwf_staff 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'hwf-staff-${external ? 'ext' : 'int'}-${env}'
  location: location

  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uamiId}': {}
    }
  }
  properties: {
    managedEnvironmentId: environmentId

    configuration: {
      ingress: {
        external: external
        targetPort: 3000

        customDomains: external ? [
            {
              name: domainName
              certificateId: certificateId
              bindingType: 'SniEnabled'
            }
        ] : null

        ipSecurityRestrictions: external ? [
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
          {
            action: 'Allow'
            description: 'unknown_1'
            ipAddressRange: '81.134.202.29/32'
            name: 'unknown_1'
          }
          {
            action: 'Allow'
            description: 'unknown_2'
            ipAddressRange: '51.145.6.230/32'
            name: 'unknown_2'
          }
          {
            action: 'Allow'
            description: 'unknown_3'
            ipAddressRange: '194.33.192.0/25'
            name: 'unknown_3'
          }
          {
            action: 'Allow'
            description: 'unknown_4'
            ipAddressRange: '194.33.196.0/25'
            name: 'unknown_4'
          }
          {
            action: 'Allow'
            description: 'unknown_5'
            ipAddressRange: '52.210.206.51/32'
            name: 'unknown_5'
          }
          {
            action: 'Allow'
            description: 'unknown_6'
            ipAddressRange: '62.25.109.201/32'
            name: 'unknown_6'
          }
          {
            action: 'Allow'
            description: 'unknown_7'
            ipAddressRange: '62.25.109.203/32'
            name: 'unknown_7'
          }
          {
            action: 'Allow'
            description: 'unknown_8'
            ipAddressRange: '51.149.249.32/27'
            name: 'unknown_8'
          }
          {
            action: 'Allow'
            description: 'unknown_9'
            ipAddressRange: '51.149.249.0/27'
            name: 'unknown_9'
          }
        ] : null
      }

      registries: [
        {
          identity: uamiId
          server: 'employmenttribunal.azurecr.io'

        }
      ]

      secrets: [
        {
          name: 'hwf-staff-secret-token'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-secret-token'
        }
        {
          name: 'hwf-staff-submission-token'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-submission-token'
        }
        {
          name: 'hwf-staff-appinsights-key'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-appinsights-key'
        }
        {
          name: 'hwf-staff-sentry-dsn'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-sentry-dsn'
        }
        {
          name: 'hwf-staff-db-password'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-db-password'
        }
        {
          name: 'hwf-staff-db-host'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-db-host'
        }
        {
          name: 'hwf-staff-db-name'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-db-name'
        }
        {
          name: 'hwf-staff-db-user-name'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-db-user-name'
        }
        {
          name: 'hwf-staff-smtp-username'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-smtp-username'
        }
        {
          name: 'hwf-staff-smtp-password'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-smtp-password'
        }
        {
          name: 'hwf-staff-dwp-notification-alert-emails'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-dwp-notification-alert-emails'
        }
        {
          name: 'hwf-staff-hmrc-ttp-secret'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-hmrc-ttp-secret'
        }
        {
          name: 'hwf-staff-hmrc-client-id'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-hmrc-client-id'
        }
        {
          name: 'hwf-staff-hmrc-secret'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-hmrc-secret'
        }
        {
          name: 'hwf-staff-hmrc-api-url'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-hmrc-api-url'
        }
        {
          name: 'hwf-staff-notify-api-key'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-notify-api-key'
        }

        {
          name: 'hwf-staff-hmrc-office-code'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-staff-hmrc-office-code'
        }
        {
          name: 'hwf-maintenance-enabled'
          identity: uamiId
          keyVaultUrl: '${hwfVault}/${env}-hwf-maintenance-enabled'
        }
        {
          name: 'hwf-maintenance-allowed-ips'
          identity: uamiId
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
}
