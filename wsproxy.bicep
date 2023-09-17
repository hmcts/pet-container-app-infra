param location string = 'uksouth'

var wsproxyVaultName = 'f74dd7b303a6devops'
var wsproxyVault = 'https://${wsproxyVaultName}.vault.azure.net/secrets'

var wsproxyStorageAccountName = 'wsproxy-${env}'

param publicDomainName string
param publicDomainCertificateId string

param env string = 'dev'

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: 'wsproxy-${env}'
  location: location
}

module keyVaultAccessPolicy 'key_vault_access_policy.module.bicep' = {
  name: 'keyVaultDeployment'
  scope: resourceGroup('genesis_resource_group')
  params: {
    vaultName: wsproxyVaultName
    objectId: uami.properties.principalId
  }
}

@description('The number of CPU cores to allocate to the container.')
param cpuCores int = 1

@description('The amount of memory to allocate to the container in gigabytes.')
param memoryInGb int = 2

resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2023-05-01' = {
  name: 'wsproxy-${env}'
  location: location
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
          image: 'employmenttribunal.azurecr.io/tt-wsproxy:tactical-dev'
          ports: [
            {
              port: 8080
              protocol: 'TCP'
            }
            {
              port: 4430
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
          port: 4430
          protocol: 'TCP'
        }
      ]
    }
  }
}
