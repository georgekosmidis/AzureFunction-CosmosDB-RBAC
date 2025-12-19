@description('Location for the Cosmos DB account.')
param location string = resourceGroup().location

@description('The default consistency level of the Cosmos DB account.')
@allowed([
  'Eventual'
  'ConsistentPrefix'
  'Session'
  'BoundedStaleness'
  'Strong'
])
param defaultConsistencyLevel string

@description('The name for the database')
param databaseName string

@description('The name for the container')
param containerName string

var accountName = '${resourceGroup().name}-cosmos'

// Define consistency policies
// See: https://learn.microsoft.com/en-us/azure/cosmos-db/consistency-levels
var consistencyPolicy = {
  Eventual: {
    defaultConsistencyLevel: 'Eventual'
  }
  ConsistentPrefix: {
    defaultConsistencyLevel: 'ConsistentPrefix'
  }
  Session: {
    defaultConsistencyLevel: 'Session'
  }
  BoundedStaleness: {
    defaultConsistencyLevel: 'BoundedStaleness'
    maxStalenessPrefix: 100000
    maxIntervalInSeconds: 300
  }
  Strong: {
    defaultConsistencyLevel: 'Strong'
  }
}

resource account 'Microsoft.DocumentDB/databaseAccounts@2025-11-01-preview' = {
  name: toLower(accountName)
  kind: 'GlobalDocumentDB'
  location: location
  properties: {
    consistencyPolicy: consistencyPolicy[defaultConsistencyLevel]
    locations: [{
      locationName: location
      failoverPriority: 0
      isZoneRedundant: false
    }]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-11-01-preview' = {
  parent: account
  name: databaseName
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-05-15' = {
  parent: database
  name: containerName
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/location'
        ]
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          {
            path: '/*'
          }
        ]
      }
      defaultTtl: 86400
    }
    options: {
      autoscaleSettings: {
        maxThroughput: 1000
      }
    }
  }
}

output cosmosDbEndpoint string = account.properties.documentEndpoint
output cosmosDbName string = accountName
