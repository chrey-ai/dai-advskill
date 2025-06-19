param location string = resourceGroup().location
param sqlAdminUsername string = 'tdadmin'
@secure()
param sqlAdminPassword string


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



resource postgresServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: 'chainlit-postgres'
  location: location
  properties: {
    administratorLogin: 'pgadmin'
    administratorLoginPassword: sqlAdminPassword
    version: '15'
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
    createMode: 'Default'
  }
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  tags: {
    'azd-service-name': 'postgresql'
  }
}

output pgServerName string = postgresServer.name
output sqlAdminUsername string = sqlAdminUsername

