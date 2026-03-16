resource "nxos_keychain_manager" "keychain_manager" {
  for_each    = { for device in local.devices : device.name => device if(try(length(local.device_config[device.name].keychains), 0) > 0) }
  device      = each.key
  admin_state = "enabled"
}

locals {
  keychains = flatten([
    for device in local.devices : [
      for keychain in try(local.device_config[device.name].keychains, []) : {
        key    = format("%s/%s", device.name, keychain.name)
        device = device.name
        name   = keychain.name
      }
    ]
  ])
}

resource "nxos_keychain" "keychain" {
  for_each = { for v in local.keychains : v.key => v }
  device   = each.value.device
  name     = each.value.name

  depends_on = [nxos_keychain_manager.keychain_manager]
}

locals {
  keys = flatten([
    for device in local.devices : [
      for keychain in try(local.device_config[device.name].keychains, []) : [
        for key in try(keychain.keys, []) : {
          key        = format("%s/%s/%s", device.name, keychain.name, key.id)
          device     = device.name
          key_id     = key.id
          keychain   = format("%s/%s", device.name, keychain.name)
          key_string = sensitive(key.key_string)
        }
      ]
    ]
  ])
}

resource "nxos_keychain_key" "keychain_key" {
  for_each   = { for v in local.keys : v.key => v }
  device     = each.value.device
  key_id     = each.value.key_id
  keychain   = nxos_keychain.keychain[each.value.keychain].name
  key_string = each.value.key_string

  lifecycle {
    ignore_changes = [
      key_string,
    ]
  }
}

resource "nxos_ipv4_static_route" "example" {
  vrf_name = "IPN_VRF"
  device   = "IPN101"
  prefix   = "1.1.1.0/24"
  next_hops = [{
    interface_id = "unspecified"
    address      = "1.2.3.4"
    vrf_name     = "default"
    description  = "My Description"
    object       = 10
    preference   = 123
    tag          = 10
  }]
}