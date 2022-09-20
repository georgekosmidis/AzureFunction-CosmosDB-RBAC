@description('The location into which the virtual network resources should be deployed.')
param location string

@description('Log Analytics workspace pricing tier.')
param logAnalyticsWorkspaceSku string

var lawName = '${resourceGroup().name}-law'
var lawDiagName = '${lawName}-diag'

resource law 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: lawName
  location: location
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSku
    }
  }
}

resource setting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: lawDiagName
  scope: law
  properties: {
    workspaceId: law.id
    logs: [
      {
        category: 'Audit'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output lawId string = law.id
output lawName string = lawName
