@description('The deployment environment')
param environment string = 'Cross Cutting'
param env string = 'crs'

@description('The deployment location')
param location string = 'australiasoutheast'
param loc string = 'seau'

@description('The application name')
param application string = 'My-Pet-Groomer'
param app string = 'mpg'

param utc_now string = utcNow('u')
param adminPrincipalId string
param prdServicePrincipalId string
param webAppUAMIName string
param keyVaultName string

@secure()
@description('The SQL Database password')
param secret_sqldb_pswd string

var suffix = '${app}-${env}'
var resourceCommonTags = {
  resourceCode: '${suffix}-${loc}'
  createdBy: 'YC'
  managedBy: 'Bicep'
  location: location
  envrionment: environment
  application: application
  createdDate: utc_now
}

var keyVaultSecretsUserRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

// Project Identities
resource webAppUAMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: webAppUAMIName
  location: resourceGroup().location
  tags: union({usedBy: 'web-mpg-admin'}, resourceCommonTags)
}

// App KeyVault
module keyVaultModule 'module/keyvault.bicep' = {
  name: 'keyVault'
  params: {
    keyVaultName: keyVaultName
    tags: resourceCommonTags
    secrets: [
      { name: 'sqldbpswd', value: secret_sqldb_pswd }
    ]
    roleAssignments: [
      // Admin User
      {
        role: keyVaultSecretsUserRole
        principal: adminPrincipalId
        principalType: 'User'
      }
      // Web App UAMI
      {
        role: keyVaultSecretsUserRole
        principal: webAppUAMI.properties.principalId
        principalType: 'ServicePrincipal'
      }
      // Production Pipeline SP
      {
        role: keyVaultSecretsUserRole
        principal: prdServicePrincipalId
        pricipalType: 'ServicePrincipal'
      }
    ]
  }
}
