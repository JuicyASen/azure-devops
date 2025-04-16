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

resource keyVaultDeploymentRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(keyVault.id, 'KeyVaultDeploymentAccess')
  properties: {
    roleName: 'Key Vault Deployment Access'
    description: 'Allows secret retrieval during ARM deployments'
    permissions: [
      {
        actions: ['Microsoft.KeyVault/vaults/deploy/action']
        notActions: []
        dataActions: []
        notDataActions: []
      }
    ]
    assignableScopes: [
      keyVault.id
    ]
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
      roleDefinitionId: roleAssign.role == 'Key Vault Deployment Access'
        ? keyVaultDeploymentRole.id
        : roleAssign.role
      principalId: roleAssign.principal
      principalType: roleAssign.principalType
    }
  }
]
