param location string = 'uksouth'

param env string = 'dev'

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'wsproxy-${env}'
  location: location
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

@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 2

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'wsproxy-${env}'
  location: location

  dependsOn: [acrPull]

  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
  properties: {
    imageRegistryCredentials: [
      {
        server: 'employmenttribunal.azurecr.io'
        identity: uami.id
      }
    ]
    containers: [
      {
        name: 'wsproxy'
        properties: {
          image: 'employmenttribunal.azurecr.io/tt-wsproxy:tactical-dev-hardened'
          ports: [
            {
              port: 8080
              protocol: 'TCP'
            }
            {
              port: 443
              protocol: 'TCP'
            }
          ]
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGb
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'Always'
    ipAddress: {
      type: 'Public'
      ports: [
        {
          port: 8080
          protocol: 'TCP'
        }
        {
          port: 443
          protocol: 'TCP'
        }
      ]
    }
  }
}
