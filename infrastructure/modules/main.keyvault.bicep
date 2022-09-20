@description('The location into which the key vault should be deployed.')
param location string

@description('Specifies the Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Get it by using Get-AzSubscription cmdlet.')
param tenantId string

@description('Log Analytics workspace id to use for diagnostics settings.')
param logAnalyticsWorkspaceName string

@description('The KeyVault SKU')
param keyVaultSku string// = 'standard'


var keyVaultName = replace(replace('${resourceGroup().name}-kvault', '-api', ''), 'wv-rg-', '')
var keyVaultDiagName = '${keyVaultName}-diag'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: false
    enableRbacAuthorization: true
    softDeleteRetentionInDays: 90
    tenantId: tenantId
    sku: {
      name: keyVaultSku
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsWorkspaceName
}

resource applicationInsightsDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: keyVault
  name: keyVaultDiagName
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
        category: 'AuditEvent'
        enabled: true
      }
    ]
  }
}

output keyVaultName string = keyVaultName
