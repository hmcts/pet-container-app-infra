param location string = 'uksouth'

var wsproxyVaultName = 'f74dd7b303a6devops'
var wsproxyVault = 'https://${wsproxyVaultName}.vault.azure.net/secrets'

param env string = 'dev'

var subnetId = '/subscriptions/58a2ce36-4e09-467b-8330-d164aa559c68/resourceGroups/pet_${env}_network_resource_group/providers/Microsoft.Network/virtualNetworks/pet_${env}_network/subnets/pet_dmz_${env}'

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: wsproxy-${env}'
  location: location
}

module keyVaultAccessPolicy 'key_vault_access_policy.module.bicep' = {
  name: 'keyVaultDeployment'
  scope: resourceGroup('genesis_resource_group')
  params: {
    vaultName: wsproxy
    objectId: uami.properties.principalId
  }
}

module acrPull 'role_assignment.module.bicep' = {
  name: 'acrPull'
  scope: resourceGroup('et_dev_etazure_resource_group')
  params: {
    principalId: uami.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    roleAssignmentName: guid(subscription().id, 'wsproxy-${env}-acr-pull')
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

resource wsproxy 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'wsproxy-${env}'
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
        targetPort: 443

        customDomains: [
          {
            name: publicDomainName
            certificateId: publicDomainCertificateId
            bindingType: 'SniEnabled'
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
          name: 'test'
          identity: uami.id
          keyVaultUrl: '${wsproxyVault}/${env}-test'
        }
      ]
    }

    template: {
      containers: [
        {
          image: 'employmenttribunal.azurecr.io/tt-wsproxy:latest'
          name: 'wsproxy'
          resources: {
            cpu: '0.5'
            memory: '1.0Gi'
          }
          env: [
            {
              name: 'TEST'
              value: 'TEST'
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
