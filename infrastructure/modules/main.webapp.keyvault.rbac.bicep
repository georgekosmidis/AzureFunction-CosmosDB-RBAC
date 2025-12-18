@description('The resource that the role will be added.')
param keyVaultName string

@description('The build in role GUID. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles')
param roleIds array

@description('The Service Principal ID')
param principalId string

resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01' existing = {
  name: keyVaultName
}

resource functionAppRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleId in roleIds: {
  dependsOn:[
    keyVault
  ]
  scope: keyVault
  name: guid(keyVault.id , principalId, roleId)
  properties: {
    principalId: principalId
    principalType:'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
  }

}]
