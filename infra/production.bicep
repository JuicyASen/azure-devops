@description('The deployment environment')
param environment string = 'Production'
param env string = 'prd'

@description('The deployment location')
param location string = 'australiasoutheast'
param loc string = 'seau'

@description('The application name')
param application string = 'My-Pet-Groomer'
param app string = 'mpg'

@description('The username of the sql server admin')
param sqlUsername string = 'sqladmin'

param crossCuttingRG string
param UAMIDBACName string
param UAMIKeyVaultACName string
param utc_now string = utcNow('u')
param keyVaultName string = 'kv-${app}-crs-${loc}'
param sqlPSWDSecretName string = 'sqldbpswd'

var suffix = '${app}-${env}'
var storageAccountName = 'st${app}${env}${loc}'
var appServicePlanName = 'asp-${suffix}'
var webappName = 'web-${suffix}'
var sqlServerName = 'sql-${suffix}'
var databaseName = 'db-${suffix}'

var resourceCommonTags = {
  resourceCode: '${suffix}-${loc}'
  createdBy: 'YC'
  managedBy: 'Bicep'
  location: location
  envrionment: environment
  application: application
  createdDate: utc_now
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: keyVaultName
  scope: resourceGroup(crossCuttingRG)
}

resource crsKVSecretsAccessUAMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: UAMIKeyVaultACName
  scope: resourceGroup(crossCuttingRG)
}

resource dbAccessUAMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: UAMIDBACName
  scope: resourceGroup()
  dependsOn: [sqlModule]
}

module storageModule 'module/storage.bicep' = {
  name: 'storageModule'
  params: {
    storageAccountName: storageAccountName
    containers: [
      { name: 'company-logo-images', publicAccess: 'Blob' }
      { name: 'profile-images', publicAccess: 'None' }
    ]
    tags: resourceCommonTags
  }
}

module sqlModule 'module/sqldatabase.bicep' = {
  name: 'sqlModule'
  params: {
    sqlServerName: sqlServerName
    administratorLogin: sqlUsername
    administratorPassword: keyVault.getSecret(sqlPSWDSecretName)
    sqlDatabaseAccessUAMIName: UAMIDBACName
    databaseName: databaseName
    databaseEdition: 'Basic'
    databaseServiceObjective: 'Basic'
    tags: resourceCommonTags
  }
}

module webappModule 'module/webapp.bicep' = {
  name: 'webappModule'
  params: {
    webAppUAMIs: [dbAccessUAMI.id, crsKVSecretsAccessUAMI.id]
    UAMIsqlDBAccessClientId: dbAccessUAMI.properties.clientId
    UAMIKeyVaultAccessResourceId: crsKVSecretsAccessUAMI.id
    sqlServerName: sqlServerName
    sqlDatabasename: databaseName
    appServicePlanName: appServicePlanName
    webAppName: webappName
    dotNetVersion: 'DOTNETCORE|9.0'
    skuName: 'B1'
    tags: resourceCommonTags
  }
}

output storageAccountId string = storageModule.outputs.storageAccountId
output storageAccountName string = storageModule.outputs.storageAccountName
output webAppEndpoint string = webappModule.outputs.webAppEndpoint
output webAppId string = webappModule.outputs.webAppId
output appServicePlanId string = webappModule.outputs.appServicePlanId
