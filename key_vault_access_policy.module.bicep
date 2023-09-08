param vaultName string
param objectId string

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: vaultName
}

resource accessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        objectId: objectId
        tenantId: subscription().tenantId
        permissions: {
          secrets: [
            'all'
          ]
          certificates: [
            'list'
          ]
        }
      }
    ]
  }
}
