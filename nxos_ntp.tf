locals {
  ntp_servers = { for device in local.devices : device.name => merge(
    { for server in try(local.device_config[device.name].ntp.servers, []) : server.ip => merge(server, { type = "server" }) },
    { for peer in try(local.device_config[device.name].ntp.peers, []) : peer.ip => merge(peer, { type = "peer" }) }
  ) }
}

resource "nxos_ntp" "ntp" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].ntp, null) != null }
  device               = each.key
  admin_state          = "enabled"
  allow_control        = try(local.device_config[each.key].ntp.allow_control, false) ? "enabled" : "disabled"
  allow_private        = try(local.device_config[each.key].ntp.allow_private, false) ? "enabled" : "disabled"
  authentication_state = try(local.device_config[each.key].ntp.authenticate, false) ? "enabled" : "disabled"
  logging              = try(local.device_config[each.key].ntp.logging, false) ? "enabled" : "disabled"
  logging_level        = try(local.device_config[each.key].ntp.logging_level, null)
  master               = try(local.device_config[each.key].ntp.master, false) ? "enabled" : "disabled"
  master_stratum       = try(local.device_config[each.key].ntp.master_stratum, null)
  passive              = try(local.device_config[each.key].ntp.passive, false) ? "enabled" : "disabled"
  rate_limit           = try(local.device_config[each.key].ntp.allow_control_rate_limit, null)
  servers = { for name, server in try(local.ntp_servers[each.key], {}) : name => {
    vrf       = try(server.vrf, null)
    type      = server.type
    key_id    = try(server.key, null)
    min_poll  = try(server.min_poll, null)
    max_poll  = try(server.max_poll, null)
    preferred = try(server.prefer, null)
  } }

  depends_on = [
    nxos_vrf.vrf,
  ]
}
