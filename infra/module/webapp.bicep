@description('The name of the App Service Plan.')
param appServicePlanName string

@description('The name of the Web App.')
param webAppName string

@description('The SKU for the App Service Plan. Example: B1, P1v2')
param skuName string = 'B1'

@description('The location for the resources.')
param location string = resourceGroup().location

@description('The version of the .NET runtime stack.')
param dotNetVersion string = 'DOTNETCORE|9.0'

@description('Tags to assign to the resources.')
param tags object = {}

param webAppUAMIs array
param sqlDBAccessUAMI object
param sqlServerName string 
param sqlDatabasename string

var builtWebAppUAMIs = toObject(webAppUAMIs, uami => uami.id, e => {})

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: skuName == 'B1' ? 'Basic' : 'PremiumV2'
    capacity: 1
  }
  properties: {
    reserved: true // Specifies that the plan is for Linux
  }
  tags: tags
}

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: builtWebAppUAMIs
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: dotNetVersion
    }
    httpsOnly: false
  }
  tags: tags
}

resource connectionString 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: webApp
  name: 'connectionstrings'
  properties: {
    DefaultConnection: {
      type: 'SQLAzure'
      value: 'Server=${sqlServerName}${environment().suffixes.sqlServerHostname};Database=${sqlDatabasename};Authentication=Active Directory Managed Identity;User Id=${sqlDBAccessUAMI.properties.clientId};TrustServerCertificate=False'
    }
  }
}

output webAppEndpoint string = webApp.properties.defaultHostName
output webAppId string = webApp.id
output appServicePlanId string = appServicePlan.id
output webApp object = webApp
