param location string = resourceGroup().location
param sqlServerName string = 'chainlit-sql-server'
param sqlAdminUsername string = 'tdadmin'
@secure()
param sqlAdminPassword string
param databaseName string = 'chainlitdb'

resource sqlServer 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: sqlServerName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: sqlAdminUsername
    administratorLoginPassword: sqlAdminPassword
    version: '12.0'
    azureADOnlyAuthentication: {
      azureADOnlyAuthentication: true
    }
  }
}

resource sqlAdAdmin 'Microsoft.Sql/servers/administrators@2022-02-01-preview' = {
  name: 'ActiveDirectory'
  parent: sqlServer
  properties: {
    administratorType: 'ActiveDirectory'
    login: 'sql-admins'
    sid: '4f7380aa-3fed-4f3e-a4e0-49af84d53987' // TODO: Replace with the actual objectId of the sql-admins group
    tenantId: '4a302c0b-d1fa-49e5-bc80-a008b7ca6eb4' // TODO: Replace with your Azure AD tenant ID
  }
}

resource sqlServerAllowAllWindowsAzureIps 'Microsoft.Sql/servers/firewallRules@2022-02-01-preview' = {
  name: 'AllowAllWindowsAzureIps'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }

}

resource sqlDb 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: databaseName
  parent: sqlServer
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 10737418240 // 10 GB
    autoPauseDelay: 30 // Auto-pause after 60 minutes of inactivity
    minCapacity: 1 // Minimum vCores
    zoneRedundant: false
    sampleName: 'AdventureWorksLT'
  }
  sku: {
    name: 'GP_S_Gen5_1' // General Purpose, Serverless, Gen5, 1 vCore
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 1
  }

}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'chainlit-appserviceplan'
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'chainlit-webapp'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
  tags: {
    'azd-service-name': 'chainlit-webapp'
  }
}

output sqlServerName string = sqlServer.name
output sqlAdminUsername string = sqlAdminUsername
output sqlDbName string = sqlDb.name
