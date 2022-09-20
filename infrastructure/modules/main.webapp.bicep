@description('The location into which the key vault should be deployed.')
param location string

@description('The name of the frontdoor endpoint.')
param logAnalyticsWorkspaceName string

@description('The secret name of the common app insights.')
@secure()
param appInsightsConnString string

@description('The secret name of the common app insights.')
@secure()
param appInsightsInstrKey string

@description('The cosmos db endpoint.')
@secure()
param cosmosDbEndpoint string

@description('The name of the Local Service KeyVault.')
param keyVaultName string

@description('The keyvault secret for the WEBSITE_CONTENTAZUREFILECONNECTIONSTRING.')
@secure()
param keyVaultSecret_WCAFCS_secretUri string

@description('The keyvault secret for the AzureWebJobsStorage.')
@secure()
param keyVaultSecret_AzureWebJobsStorage_secretUri string

@description('The name of the Function App Service Plan SKU.')
param functionServicePlan string //= 'Y1'

var webAppName = '${resourceGroup().name}-webapp'
var serverFarmName = '${webAppName}-asp'
var webAppContentShare = guid(webAppName)

resource serverFarm 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: serverFarmName
  location: location
  sku: {
    name: functionServicePlan
  }
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    reserved: false
    zoneRedundant: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}


resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: serverFarm.id
    enabled: true
    hostNameSslStates: [
      {
        name: '${webAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${webAppName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    siteConfig: {
      ftpsState: 'Disabled'
      numberOfWorkers: 1
      netFrameworkVersion: 'v6.0'
      webSocketsEnabled: true
    }
    httpsOnly: true 
  }
  identity: {
    type: 'SystemAssigned'
  }
}


module keyVaultRoleAssignment 'main.webapp.keyvault.rbac.bicep' = {
  name: 'module-common-keyvault-RBAC'
  params:{
    keyVaultName:  keyVaultName
    principalId: webApp.identity.principalId
    roleIds: ['4633458b-17de-408a-b874-0445c86b69e6']//keyvault secrets user
  }
}

resource webAppSettings 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: webApp
  name: 'appsettings'
  dependsOn:[
    keyVaultRoleAssignment
  ]
  properties: {
    APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsConnString
    APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsInstrKey
    AzureWebJobsStorage: '@Microsoft.KeyVault(SecretUri=${keyVaultSecret_AzureWebJobsStorage_secretUri})'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: '@Microsoft.KeyVault(SecretUri=${keyVaultSecret_WCAFCS_secretUri})'
    WEBSITE_CONTENTSHARE: webAppContentShare
    FUNCTIONS_WORKER_RUNTIME: 'dotnet-isolated'
    FUNCTIONS_EXTENSION_VERSION: '~4'
    WEBSITE_RUN_FROM_PACKAGE: '1' 
    COSMOSDB_ENDPOINT: cosmosDbEndpoint
  }
}

module diagnostics 'main.webapp.diagnostics.bicep' = {
  name: 'module-webapp-diagnostics'
  dependsOn:[
    webApp
  ]
  params: {
    webAppName: webAppName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

output principalId string = webApp.identity.principalId
