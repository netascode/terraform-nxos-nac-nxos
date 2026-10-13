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

  keychain_classic_map = { for device in local.devices : device.name => [
    for keychain in try(local.device_config[device.name].key_chains, []) : true
    if !try(keychain.macsec, false)
  ] }

  keychain_macsec_map = { for device in local.devices : device.name => [
    for keychain in try(local.device_config[device.name].key_chains, []) : true
    if try(keychain.macsec, false)
  ] }
}

resource "nxos_keychain" "keychain" {
  for_each = { for device in local.devices : device.name => device
    if length(try(local.device_config[device.name].key_chains, [])) > 0 ||
  try(local.device_config[device.name].macsec.key_chain_macsec_psk_no_show, null) != null }
  device = each.key
  keychains = length(try(local.keychain_classic_map[each.key], [])) > 0 ? { for keychain in try(local.device_config[each.key].key_chains, []) : keychain.name => {
    keys = length(try(keychain.keys, [])) > 0 ? { for key in try(keychain.keys, []) : key.id => {
      cryptographic_algorithm = try(local.keychain_crypto_algorithm_map[try(key.cryptographic_algorithm)], null)
      encryption_type         = try(key.encryption_type, null)
      key_string              = try(key.key_string, null)
    } } : null
  } if !try(keychain.macsec, false) } : null
  macsec_keychains = length(try(local.keychain_macsec_map[each.key], [])) > 0 ? { for keychain in try(local.device_config[each.key].key_chains, []) : keychain.name => {
    keys = length(try(keychain.keys, [])) > 0 ? { for key in try(keychain.keys, []) : tostring(key.id) => {
      cryptographic_algorithm = try(key.cryptographic_algorithm, null)
      encryption_type         = try(key.encryption_type, null)
      key_hex_string          = try(key.key_octet_string, null)
      duration                = try(key.send_lifetime.duration, null)
      end_day                 = try(key.send_lifetime.end_day, null)
      end_month               = try(key.send_lifetime.end_month, null)
      end_time                = try(key.send_lifetime.end_time, null)
      end_year                = try(key.send_lifetime.end_year, null)
      infinite                = try(key.send_lifetime.infinite, null) == null ? null : (try(key.send_lifetime.infinite) ? "enabled" : "disabled")
      local                   = try(key.send_lifetime.local, null) == null ? null : (try(key.send_lifetime.local) ? "local" : "unspecified")
      start_day               = try(key.send_lifetime.start_day, null)
      start_month             = try(key.send_lifetime.start_month, null)
      start_time              = try(key.send_lifetime.start_time, null)
      start_year              = try(key.send_lifetime.start_year, null)
    } } : null
  } if try(keychain.macsec, false) } : null
  macsec_psk_no_show = try(local.device_config[each.key].macsec.key_chain_macsec_psk_no_show, null) == null ? null : (try(local.device_config[each.key].macsec.key_chain_macsec_psk_no_show) ? "enabled" : "disabled")

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
  ]
}
