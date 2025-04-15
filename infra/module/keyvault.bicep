param keyVaultName string
param tags object
param location string = resourceGroup().location

@description('Array of secrets')
param secrets array

@description('Array of role assignment')
param roleAssignments array

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    enabledForTemplateDeployment: true
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    tenantId: tenant().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = [
  for secret in secrets: {
    parent: keyVault
    name: secret.name
    properties: {
      value: secret.value
    }
  }
]

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for roleAssign in roleAssignments: {
    name: guid(keyVault.id, roleAssign.principal, roleAssign.role)
    scope: keyVault
    properties: {
      principalId: roleAssign.principal
      roleDefinitionId: roleAssign.role
      principalType: roleAssign.principalType
    }
  }
]
