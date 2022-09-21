@description('The location into which the key vault should be deployed.')
param location string = resourceGroup().location 

@description('Specify the Log Analytics Pricing Tier: PerGB2018 or legacy tiers (Free, Standalone, PerNode, Standard or Premium) which are not available to all customers.')
@allowed([
  'CapacityReservation'
  'Free'
  'LACluster'
  'PerGB2018'
  'PerNode'
  'Premium'
  'Standalone'
  'Standard'
])
param logAnalyticsWorkspaceSku string = 'PerGB2018'

@description('Specify the Function App Storage Pricing Tier. Check details at https://learn.microsoft.com/en-us/rest/api/storagerp/srp_sku_types/')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageAccountSKU string = 'Standard_LRS'

@description('Specify the plan\'s pricing tier and instance size. Check details at https://azure.microsoft.com/en-us/pricing/details/app-service/')
@allowed([
  'F1'
  'Y1'
  'D1'
  'B1'
  'B2'
  'B3'
  'S1'
  'S2'
  'S3'
  'P1'
  'P2'
  'P3'
  'P4'
])
param functionServicePlan string = 'Y1'

@description('Specify whether the key vault is a standard vault or a premium vault.')
@allowed([
  'standard'
  'premium'
])
param keyVaultSku string = 'standard'

@description('The default consistency level of the Cosmos DB account.')
@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
param defaultConsistencyLevel string = 'Session'

@description('The name for the CosmosDb database')
param databaseName string = 'LifeOnEarthDatabase'

@description('The name for the CosmosDb container (that will go under the previous database)')
param containerName string = 'HumansContainer'

module analyticsWorkspace 'modules/main.analyticsWorkspace.bicep' = {
  name: 'analytics-workspace'
  params: {
    location: location
    logAnalyticsWorkspaceSku: logAnalyticsWorkspaceSku
  }
}

module appInsights 'modules/main.appInsights.bicep' = {
  name: 'app-insights'
  params: {
    location: location
    logAnalyticsWorkspaceId: analyticsWorkspace.outputs.lawId
  }
}

module cosmosDb 'modules/main.cosmosdb.bicep' = {
  name: 'cosmos-db'
  params:{
    location: location
    containerName: containerName
    databaseName: databaseName
    defaultConsistencyLevel: defaultConsistencyLevel
  }
}

module keyvault 'modules/main.keyvault.bicep' = {
  name: 'service-kvault'
  params: {
    keyVaultSku: keyVaultSku
    location: location
    logAnalyticsWorkspaceName: analyticsWorkspace.outputs.lawName
    tenantId: subscription().tenantId
  }
}

module webAppStorage 'modules/main.storage.bicep' = {
  name: 'webapp-storage'
  dependsOn:[
    keyvault
  ]
  params:{
    storageAccountSKU: storageAccountSKU
    serviceKeyVaultName: keyvault.outputs.keyVaultName
    location: location
    logAnalyticsWorkspaceName: analyticsWorkspace.outputs.lawName
  }
}

module webApp 'modules/main.webapp.bicep' = {
  name: 'webapp'
  dependsOn:[
    cosmosDb
    webAppStorage
    keyvault
  ]
  params: {
    functionServicePlan: functionServicePlan
    location: location
    keyVaultName: keyvault.outputs.keyVaultName
    logAnalyticsWorkspaceName: analyticsWorkspace.outputs.lawName
    appInsightsConnString: appInsights.outputs.appInsightsConnString
    appInsightsInstrKey: appInsights.outputs.appInsightsInstrKey
    cosmosDbEndpoint: cosmosDb.outputs.cosmosDbEndpoint
    keyVaultSecret_WCAFCS_secretUri: webAppStorage.outputs.keyVaultSecret_secretUri
    keyVaultSecret_AzureWebJobsStorage_secretUri: webAppStorage.outputs.keyVaultSecret_secretUri
  }
}

module cosmosDbRBAC 'modules/main.cosmosdb.rbac.bicep' = {
  dependsOn:[
    cosmosDb
    webApp
  ]
  name: 'cosmos-db-rbac'
  params:{
    cosmosDbName: cosmosDb.outputs.cosmosDbName
    principalId: webApp.outputs.principalId
    //https://learn.microsoft.com/en-us/azure/cosmos-db/how-to-setup-rbac#built-in-role-definitions
    roleIds: ['00000000-0000-0000-0000-000000000002']
  }
}

module webAppStorageRBAC 'modules/main.storage.rbac.bicep' = {
  dependsOn:[
    webApp
    webAppStorage
  ]
  name: 'webapp-storage-rbac'
  params:{
    storageAccountName: webAppStorage.outputs.storageAccountName
    principalId: webApp.outputs.principalId
    roleIds: ['0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe']
  }
}
