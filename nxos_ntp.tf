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
  allow_control        = try(local.device_config[each.key].ntp.allow_control, local.defaults.nxos.devices.configuration.ntp.allow_control, false) ? "enabled" : "disabled"
  allow_private        = try(local.device_config[each.key].ntp.allow_private, local.defaults.nxos.devices.configuration.ntp.allow_private, false) ? "enabled" : "disabled"
  authentication_state = try(local.device_config[each.key].ntp.authenticate, local.defaults.nxos.devices.configuration.ntp.authenticate, false) ? "enabled" : "disabled"
  logging              = try(local.device_config[each.key].ntp.logging, local.defaults.nxos.devices.configuration.ntp.logging, false) ? "enabled" : "disabled"
  logging_level        = try(local.device_config[each.key].ntp.logging_level, local.defaults.nxos.devices.configuration.ntp.logging_level, null)
  master               = try(local.device_config[each.key].ntp.master, local.defaults.nxos.devices.configuration.ntp.master, false) ? "enabled" : "disabled"
  master_stratum       = try(local.device_config[each.key].ntp.master_stratum, local.defaults.nxos.devices.configuration.ntp.master_stratum, null)
  passive              = try(local.device_config[each.key].ntp.passive, local.defaults.nxos.devices.configuration.ntp.passive, false) ? "enabled" : "disabled"
  rate_limit           = try(local.device_config[each.key].ntp.allow_control_rate_limit, local.defaults.nxos.devices.configuration.ntp.allow_control_rate_limit, null)
  servers = { for name, server in try(local.ntp_servers[each.key], {}) : name => {
    vrf       = try(server.vrf, local.defaults.nxos.devices.configuration.ntp.servers.vrf, null)
    type      = server.type
    key_id    = try(server.key, local.defaults.nxos.devices.configuration.ntp.servers.key, null)
    min_poll  = try(server.min_poll, local.defaults.nxos.devices.configuration.ntp.servers.min_poll, null)
    max_poll  = try(server.max_poll, local.defaults.nxos.devices.configuration.ntp.servers.max_poll, null)
    preferred = try(server.prefer, local.defaults.nxos.devices.configuration.ntp.servers.prefer, null)
  } }

  depends_on = [
    nxos_vrf.vrf,
  ]
}
