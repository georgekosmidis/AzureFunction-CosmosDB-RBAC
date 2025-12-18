@description('The location into which the key vault should be deployed.')
param location string

@description('The name of the App KeyVault.')
param serviceKeyVaultName string

@description('The name of the frontdoor endpoint.')
param logAnalyticsWorkspaceName string

@description('The name of the storage SKU.')
param storageAccountSKU string //= 'Standard_LRS'

var storageAccountName = replace(replace(replace('${resourceGroup().name}-webapp-stg', 'api', ''), 'wv-rg-', ''),'-', '')

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSKU
  }
  kind: 'Storage'
  properties: {
    publicNetworkAccess: 'Enabled'
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: true
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

module keyVaultStorageSecret 'generic.secret.bicep' = {
  name: 'module-keyvault-secret'
  params: {
    serviceKeyVaultName: serviceKeyVaultName
    secretName: '${storageAccountName}-secret'
    secretValue: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
  }
}


module diagnostics 'main.storage.diagnostics.bicep' = {
  name: 'module-webapp-storage-diagnostics'
  params: {
    storageEndpoints: storageAccount.properties.primaryEndpoints // reference(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2019-06-01', 'Full').properties.primaryEndpoints
    storageName: storageAccountName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}

output storageAccountName string = storageAccountName
output keyVaultSecret_secretUri string = keyVaultStorageSecret.outputs.secretUri
