targetScope = 'resourceGroup'

@description('デプロイ先リージョン')
param location string = resourceGroup().location

@description('プロジェクト名プレフィックス。英小文字と数字を推奨')
@minLength(3)
@maxLength(12)
param prefix string = 'ccdemo'

@description('CycleCloud管理VMの管理者ユーザー名')
param adminUsername string = 'azureuser'

@description('CycleCloud管理VMに設定するSSH公開鍵')
param adminSshPublicKey string

@description('CycleCloud管理VMのサイズ')
param cycleVmSize string = 'Standard_D4s_v5'

@description('CycleCloud管理VMに割り当てるパブリックIP SKU')
@allowed([
  'Standard'
])
param publicIpSku string = 'Standard'

var unique = toLower(uniqueString(resourceGroup().id, prefix))
var vnetName = '${prefix}-vnet'
var cycleSubnetName = 'cyclecloud-subnet'
var computeSubnetName = 'hpc-compute-subnet'
var cycleNsgName = '${prefix}-cycle-nsg'
var cyclePipName = '${prefix}-cycle-pip'
var cycleNicName = '${prefix}-cycle-nic'
var cycleVmName = '${prefix}-cycle-vm'
var identityName = '${prefix}-uami'
var storageName = toLower('st${prefix}${take(unique, 8)}')
var keyVaultName = toLower('kv-${prefix}-${take(unique, 8)}')

resource cycleNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: cycleNsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-SSH'
        properties: {
          priority: 100
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
      {
        name: 'Allow-HTTPS'
        properties: {
          priority: 110
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.40.0.0/16'
      ]
    }
    subnets: [
      {
        name: cycleSubnetName
        properties: {
          addressPrefix: '10.40.1.0/24'
          networkSecurityGroup: {
            id: cycleNsg.id
          }
        }
      }
      {
        name: computeSubnetName
        properties: {
          addressPrefix: '10.40.2.0/24'
        }
      }
    ]
  }
}

resource cyclePip 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: cyclePipName
  location: location
  sku: {
    name: publicIpSku
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    encryption: {
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enabledForTemplateDeployment: false
    enablePurgeProtection: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    publicNetworkAccess: 'Enabled'
  }
}

resource cycleNic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: cycleNicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: cyclePip.id
          }
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource cycleVm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: cycleVmName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uami.id}': {}
    }
  }
  properties: {
    hardwareProfile: {
      vmSize: cycleVmSize
    }
    osProfile: {
      computerName: cycleVmName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminSshPublicKey
            }
          ]
        }
      }
      customData: base64('''#cloud-config
package_update: true
runcmd:
  - [ sh, -c, "echo CycleCloud host provisioned. Install CycleCloud package manually or via automation runbook." ]
''')
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: cycleNic.id
        }
      ]
    }
  }
}

output cycleCloudVmName string = cycleVm.name
output cycleCloudPublicIp string = cyclePip.properties.ipAddress
output vnetId string = vnet.id
output computeSubnetId string = vnet.properties.subnets[1].id
output storageAccountName string = storage.name
output keyVaultName string = keyVault.name
output userAssignedIdentityId string = uami.id
