param roleDefinitionId string
param principalId string
param roleAssignmentName string


resource registry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
 name: 'employmenttribunal'
}

resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  scope: registry
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
