resource "nxos_keychain" "keychain" {
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

resource "nxos_keychain_classic" "keychain_classic" {
  for_each = { for v in local.keychains : v.key => v }
  device   = each.value.device
  name     = each.value.name

  depends_on = [nxos_keychain.keychain]
}

locals {
  keys = flatten([
    for device in local.devices : [
      for keychain in try(local.device_config[device.name].keychains, []) : [
        for key in try(keychain.keys, []) : {
          key          = format("%s/%s/%s", device.name, keychain.name, key.id)
          device       = device.name
          key_id       = key.id
          keychain_key = format("%s/%s", device.name, keychain.name)
          key_string   = sensitive(key.key_string)
        }
      ]
    ]
  ])
}

resource "nxos_keychain_key" "keychain_key" {
  for_each   = { for v in local.keys : v.key => v }
  device     = each.value.device
  key_id     = each.value.key_id
  keychain   = nxos_keychain_classic.keychain_classic[each.value.keychain_key].name
  key_string = each.value.key_string
}
