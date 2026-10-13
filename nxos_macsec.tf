locals {
  macsec_interfaces_map = { for device in local.devices : device.name => [
    for int in try(local.device_config[device.name].interfaces.ethernets, []) : true
    if try(int.macsec_keychain, null) != null || try(int.macsec_policy, null) != null || try(int.macsec_fallback_keychain, null) != null
  ] }
}

resource "nxos_macsec" "macsec" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].macsec.shutdown, null) != null ||
    length(try(local.device_config[device.name].macsec.policies, [])) > 0 ||
  length(try(local.macsec_interfaces_map[device.name], [])) > 0 }
  device   = each.key
  shutdown = try(local.device_config[each.key].macsec.shutdown, null)
  policies = length(try(local.device_config[each.key].macsec.policies, [])) > 0 ? { for policy in try(local.device_config[each.key].macsec.policies, []) : policy.name => {
    allowed_peer_cipher_suite_1 = try(policy.cipher_suite_enforce_peer[0], null)
    allowed_peer_cipher_suite_2 = try(policy.cipher_suite_enforce_peer[1], null)
    allowed_peer_cipher_suite_3 = try(policy.cipher_suite_enforce_peer[2], null)
    allowed_peer_cipher_suite_4 = try(policy.cipher_suite_enforce_peer[3], null)
    cipher_suite                = length(try(policy.cipher_suite_enforce_peer, [])) > 0 ? "NoneOrEnforce-peer" : try(policy.cipher_suite, null)
    confidentiality_offset      = try(policy.conf_offset, null)
    crypto_policy_name          = try(policy.ppk_crypto_qkd_profile, null)
    include_icv_indicator       = try(policy.include_icv_indicator, null)
    include_sci                 = try(policy.include_sci, null)
    key_server_priority         = try(policy.key_server_priority, null)
    lldp_bypass                 = try(policy.protocol_lldp_encrypted, null) == null ? null : !try(policy.protocol_lldp_encrypted)
    replay_window               = try(policy.window_size, null)
    sak_expiry_time             = try(tostring(policy.sak_expiry_time), null)
    security_policy             = try(policy.security_policy, null)
  } } : null
  interfaces = length(try(local.macsec_interfaces_map[each.key], [])) > 0 ? { for int in try(local.device_config[each.key].interfaces.ethernets, []) : "eth${int.id}" => {
    fallback_keychain_name = try(int.macsec_fallback_keychain, null)
    keychain_name          = try(int.macsec_keychain, null)
    policy_name            = try(int.macsec_policy, null)
  } if try(int.macsec_keychain, null) != null || try(int.macsec_policy, null) != null || try(int.macsec_fallback_keychain, null) != null } : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_keychain.keychain,
    nxos_physical_interface.physical_interface,
  ]
}
