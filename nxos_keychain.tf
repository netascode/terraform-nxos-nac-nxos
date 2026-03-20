locals {
  keychain_crypto_algorithm_map = {
    "none"         = "NONE"
    "md5"          = "MD5"
    "hmac-sha-1"   = "HMAC-SHA-1"
    "hmac-sha-256" = "HMAC-SHA-256"
    "hmac-sha-384" = "HMAC-SHA-384"
    "hmac-sha-512" = "HMAC-SHA-512"
    "3des"         = "3DES"
    "aes"          = "AES"
  }
}

resource "nxos_keychain" "keychain" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].key_chains, [])) > 0 }
  device = each.key
  keychains = { for keychain in try(local.device_config[each.key].key_chains, []) : keychain.name => {
    keys = { for key in try(keychain.keys, []) : key.id => {
      cryptographic_algorithm = try(local.keychain_crypto_algorithm_map[try(key.cryptographic_algorithm, local.defaults.nxos.devices.configuration.key_chains.keys.cryptographic_algorithm)], null)
      encryption_type         = try(key.encryption_type, local.defaults.nxos.devices.configuration.key_chains.keys.encryption_type, null)
      key_string              = try(key.key_string, local.defaults.nxos.devices.configuration.key_chains.keys.key_string, null)
    } }
  } }
}
