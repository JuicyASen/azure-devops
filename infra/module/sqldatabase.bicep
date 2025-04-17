@description('The name of the SQL Server.')
param sqlServerName string

@description('The administrator username for the SQL Server.')
param administratorLogin string

@description('The UAMI for db access')
param sqlDatabaseAccessUAMIName string

@secure()
@description('The administrator password for the SQL Server.')
param administratorPassword string

@description('The name of the SQL Database.')
param databaseName string

@description('The edition of the SQL Database. Example: Basic, Standard, Premium')
param databaseEdition string = 'Basic'

@description('The compute size for the SQL Database. Example: S0, P1, Basic')
param databaseServiceObjective string = 'Basic'

@description('The location for the resources.')
param location string = resourceGroup().location

@description('Tags to assign to the resources.')
param tags object = {}

resource sqlServer 'Microsoft.Sql/servers@2023-08-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorPassword
    
  }
  tags: tags
}

resource allowAzureServicesFirewallRule 'Microsoft.Sql/servers/firewallRules@2023-08-01-preview' = {
  name: 'AllowAllAzureIPs'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2023-08-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: databaseServiceObjective
    tier: databaseEdition
  }
  tags: tags
}

resource sqlDatabaseAccessUAMI 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' = {
  name: sqlDatabaseAccessUAMIName
  location: resourceGroup().location
  tags: union({usedFor: 'SQLDatabase ${sqlServerName}/${databaseName}'}, tags)
}

output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName
output sqlDBAccessUAMI object = sqlDatabaseAccessUAMI
output sqlDatabaseName string = sqlDatabase.name
