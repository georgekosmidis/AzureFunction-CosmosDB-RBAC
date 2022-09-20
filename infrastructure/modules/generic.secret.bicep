@description('The name of the App KeyVault.')
param serviceKeyVaultName string

@description('The name of the webapp.')
param secretName string

@description('The name of the webapp.')
@secure()
param secretValue string


resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: serviceKeyVaultName
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  parent: keyVault
  name: secretName
  properties: {
    value: secretValue
  }
}


output secretUri string = keyVaultSecret.properties.secretUri
