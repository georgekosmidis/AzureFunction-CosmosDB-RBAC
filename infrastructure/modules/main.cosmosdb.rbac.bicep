@description('The name of the cosmos DB')
param cosmosDbName string

@description('The Service Principal ID')
param principalId string

@description('The build in role GUID. See https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles')
param roleIds array

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing =  {
  name: cosmosDbName
}

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2022-05-15' = [for roleId in roleIds: {
  name: '${cosmosDb.name}/${guid(roleId, principalId, cosmosDb.id)}'
  properties: {
    roleDefinitionId: '${resourceGroup().id}/providers/Microsoft.DocumentDB/databaseAccounts/${cosmosDb.name}/sqlRoleDefinitions/${roleId}'
    principalId: principalId
    scope: cosmosDb.id
  }
}]
