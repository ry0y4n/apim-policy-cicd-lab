targetScope = 'subscription'

@description('The name of the resource group to create')
param resourceGroupName string = 'rg-apim'

@description('The name of the API Management service instance')
param apiManagementServiceName string = 'apim'

@description('The location for all resources')
param location string = 'japaneast'

@description('The publisher name for API Management')
param publisherName string = 'Demo Publisher'

@description('The publisher email for API Management')
param publisherEmail string = 'admin@example.com'

@description('The SKU for API Management')
@allowed([
  'BasicV2'
  'StandardV2'
  'PremiumV2'
])
param apimSku string = 'BasicV2'

@description('The capacity for API Management')
param apimCapacity int = 1
// Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: '${resourceGroupName}-${uniqueString(subscription().subscriptionId)}'
  location: location
}

module apimModule 'modules/apim.bicep' = {
  name: 'apimDeployment'
  scope: resourceGroup
  params: {
    apiManagementServiceName: '${apiManagementServiceName}-${uniqueString(subscription().subscriptionId)}'
    location: location
    publisherEmail: publisherEmail
    publisherName: publisherName
    apimSku: apimSku
    apimCapacity: apimCapacity
  }
}

// Outputs
output resourceGroupName string = resourceGroup.name
output apiManagementServiceName string = apimModule.outputs.apiManagementServiceName
