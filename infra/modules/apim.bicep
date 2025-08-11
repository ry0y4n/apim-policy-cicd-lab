@description('The name of the API Management service instance')
param apiManagementServiceName string

@description('The location for all resources')
param location string

@description('The publisher name for API Management')
param publisherName string

@description('The publisher email for API Management')
param publisherEmail string

@description('The SKU for API Management')
param apimSku string

@description('The capacity for API Management')
param apimCapacity int

// API Management Service
resource apiManagement 'Microsoft.ApiManagement/service@2024-05-01' = {
  name: apiManagementServiceName
  location: location
  sku: {
    name: apimSku
    capacity: apimCapacity
  }
  properties: {
    publisherName: publisherName
    publisherEmail: publisherEmail
  }
}

// API
resource sampleApi 'Microsoft.ApiManagement/service/apis@2024-05-01' = {
  name: 'sample-api'
  parent: apiManagement
  properties: {
    displayName: 'Sample API'
    path: 'sample-api'
    protocols: [
      'https'
    ]
    serviceUrl: 'https://httpbin.org'
    apiType: 'http'
  }
}

// Operation: get-data
resource getDataOperation 'Microsoft.ApiManagement/service/apis/operations@2024-05-01' = {
  name: 'get-data'
  parent: sampleApi
  properties: {
    displayName: 'Get Data'
    method: 'GET'
    urlTemplate: '/get-data'
  }
}

// Outputs
output apiManagementServiceName string = apiManagement.name
