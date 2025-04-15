// Input param
@description('The name of the storage account to create.')
param storageAccountName string

@description('Array of storage account containers.')
param containers array

@description('The location where the storage account will be created.')
param location string = resourceGroup().location

param tags object

// Storage Account Definition
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: true
    allowSharedKeyAccess: true
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {keyType: 'Account'}
        blob: {keyType: 'Account'}
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
  tags: tags
}

// Default Blob Definition
resource defaultBlob 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

// Default File Definition
resource defaultFile 'Microsoft.Storage/storageAccounts/fileServices@2024-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

// Default web container
resource defaultWebContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  parent: defaultBlob
  name: '$web'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

// Other custom containers
resource customContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = [
  for container in containers: {
    parent: defaultBlob
    name: container.name
    properties: {
      defaultEncryptionScope: '$account-encryption-key'
      denyEncryptionScopeOverride: false
      publicAccess: container.publicAccess
    }
  }
]

// Output
output staticWebsitePrimaryEndpoint string = storageAccount.properties.primaryEndpoints.web
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
