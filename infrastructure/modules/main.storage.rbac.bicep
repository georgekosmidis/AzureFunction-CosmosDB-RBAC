@description('The name of the storage of the web app.')
param storageAccountName string

@description('The Service Principal ID')
param principalId string

@description('The build in role GUID. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles')
param roleIds array

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' existing = {
  name: storageAccountName
}

resource roleAssignmentsPrimaryWebApp_blob 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleId in roleIds: {
  scope: storageAccount
  name: guid(storageAccount.id, principalId, roleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId) 
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}]
