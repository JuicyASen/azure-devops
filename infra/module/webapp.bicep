@description('The name of the App Service Plan.')
param appServicePlanName string

@description('The name of the Web App.')
param webAppName string

@description('The SKU for the App Service Plan. Example: B1, P1v2')
param skuName string = 'B1'

@description('The location for the resources.')
param location string = resourceGroup().location

@description('The version of the .NET runtime stack.')
param dotNetVersion string = 'DOTNETCORE|6.0'

@description('Tags to assign to the resources.')
param tags object = {}

param webAppUAMI string
param sqlServerName string 
param sqlDatabasename string  

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
    userAssignedIdentities: {
      '${webAppUAMI}': {}
    }
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
      value: 'Server=tcp:${sqlServerName}${environment().suffixes.sqlServerHostname}, 1433;Database=${sqlDatabasename};Authentication=Active Directory Default;'
    }
  }
}

output webAppEndpoint string = webApp.properties.defaultHostName
output webAppId string = webApp.id
output appServicePlanId string = appServicePlan.id
output webApp object = webApp
