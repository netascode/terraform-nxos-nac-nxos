locals {
  ntp_servers = { for device in local.devices : device.name => merge(
    { for server in try(local.device_config[device.name].ntp.servers, []) : server.ip => merge(server, { type = "server" }) },
    { for peer in try(local.device_config[device.name].ntp.peers, []) : peer.ip => merge(peer, { type = "peer" }) }
  ) }
}

resource "nxos_ntp" "ntp" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].ntp, null) != null }
  device                  = each.key
  admin_state             = "enabled"
  allow_control           = try(local.device_config[each.key].ntp.allow_control, null) == null ? null : (try(local.device_config[each.key].ntp.allow_control) ? "enabled" : "disabled")
  allow_private           = try(local.device_config[each.key].ntp.allow_private, null) == null ? null : (try(local.device_config[each.key].ntp.allow_private) ? "enabled" : "disabled")
  authentication_state    = try(local.device_config[each.key].ntp.authenticate, null) == null ? null : (try(local.device_config[each.key].ntp.authenticate) ? "enabled" : "disabled")
  logging                 = try(local.device_config[each.key].ntp.logging, null) == null ? null : (try(local.device_config[each.key].ntp.logging) ? "enabled" : "disabled")
  logging_level           = try(local.device_config[each.key].ntp.logging_level, null)
  master                  = try(local.device_config[each.key].ntp.master, null) == null ? null : (try(local.device_config[each.key].ntp.master) ? "enabled" : "disabled")
  master_stratum          = try(local.device_config[each.key].ntp.master_stratum, null)
  passive                 = try(local.device_config[each.key].ntp.passive, null) == null ? null : (try(local.device_config[each.key].ntp.passive) ? "enabled" : "disabled")
  rate_limit              = try(local.device_config[each.key].ntp.allow_control_rate_limit, null)
  source_interface        = try(local.device_config[each.key].ntp.source_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].ntp.source_interface_type)]}${try(local.device_config[each.key].ntp.source_interface_id, "")}" : null
  access_group_match_all  = try(local.device_config[each.key].ntp.access_group_match_all, null) == null ? null : try(local.device_config[each.key].ntp.access_group_match_all) ? "enabled" : "disabled"
  access_group_peer       = try(local.device_config[each.key].ntp.access_group_peer, null)
  access_group_query_only = try(local.device_config[each.key].ntp.access_group_query_only, null)
  access_group_serve      = try(local.device_config[each.key].ntp.access_group_serve, null)
  access_group_serve_only = try(local.device_config[each.key].ntp.access_group_serve_only, null)
  servers = length(try(local.ntp_servers[each.key], {})) > 0 ? { for name, server in try(local.ntp_servers[each.key], {}) : name => {
    vrf       = try(server.use_vrf, null)
    type      = server.type
    key_id    = try(server.key, null)
    min_poll  = try(server.minpoll, null)
    max_poll  = try(server.maxpoll, null)
    preferred = try(server.prefer, null)
  } } : null

  depends_on = [
    nxos_vrf.vrf,
  ]
}
