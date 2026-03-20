resource "nxos_keychain" "keychain" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].key_chains, [])) > 0 }
  device = each.key
  keychains = { for keychain in try(local.device_config[each.key].key_chains, []) : keychain.name => {
    keys = { for key in try(keychain.keys, []) : key.id => {
      cryptographic_algorithm = try(key.cryptographic_algorithm, local.defaults.nxos.devices.configuration.key_chains.keys.cryptographic_algorithm, null)
      encryption_type         = try(key.encryption_type, local.defaults.nxos.devices.configuration.key_chains.keys.encryption_type, null)
      key_string              = try(key.key_string, local.defaults.nxos.devices.configuration.key_chains.keys.key_string, null)
    } }
  } }
}
