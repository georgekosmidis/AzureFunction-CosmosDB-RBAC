@description('The name of the web app service.')
param storageEndpoints object

@description('The name of the web app service.')
param storageName string

@description('The name of the frontdoor endpoint.')
param logAnalyticsWorkspaceName string

var storageDiagnosticsName = '${storageName}-diag'

var hasblob = contains(storageEndpoints, 'blob')
var hastable = contains(storageEndpoints, 'table')
var hasfile = contains(storageEndpoints, 'file')
var hasqueue = contains(storageEndpoints, 'queue')

resource webAppStorage 'Microsoft.Storage/storageAccounts@2025-06-01' existing = {
  name: storageName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-07-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource diagnosticSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: storageDiagnosticsName
  scope: webAppStorage
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices@2025-06-01' existing = {
  parent: webAppStorage
  name: 'default'
}

resource blobSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (hasblob) {
  name: '${storageDiagnosticsName}-blob'
  scope: blob
  dependsOn:[
    webAppStorage
    diagnosticSetting
    blob
  ]
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource table 'Microsoft.Storage/storageAccounts/tableServices@2025-06-01' existing = {
  parent: webAppStorage
  name: 'default'
}

resource tableSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (hastable) {
  name: '${storageDiagnosticsName}-table'
  scope: table
  dependsOn:[
    webAppStorage
    table
    diagnosticSetting
  ]
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource file 'Microsoft.Storage/storageAccounts/fileServices@2025-06-01' existing = {
  parent: webAppStorage
  name: 'default'
}

resource fileSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (hasfile) {
  name: '${storageDiagnosticsName}-file'
  scope: file
  dependsOn:[
    webAppStorage
    file
    diagnosticSetting
  ]
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}

resource queue 'Microsoft.Storage/storageAccounts/queueServices@2025-06-01' existing = {
  parent: webAppStorage
  name: 'default'
}


resource queueSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (hasqueue) {
  name: '${storageDiagnosticsName}-queue'
  scope: queue
  dependsOn:[
    queue
    diagnosticSetting
  ]
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'StorageRead'
        enabled: true
      }
      {
        category: 'StorageWrite'
        enabled: true
      }
      {
        category: 'StorageDelete'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'Transaction'
        enabled: true
      }
    ]
  }
}
