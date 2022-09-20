@description('The name of the frontdoor endpoint.')
param logAnalyticsWorkspaceName string

@description('The name of the web app service.')
param webAppName string

var webAppDiagnosticsName = '${webAppName}-diag'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsWorkspaceName
}

resource webApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: webAppName
}

resource webAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: webApp
  name: webAppDiagnosticsName
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
      }
    ]
  }
}
