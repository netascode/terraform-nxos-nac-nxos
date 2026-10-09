resource "nxos_track" "track" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].tracks, [])) > 0 }
  device = each.key
  objects = length(try(local.device_config[each.key].tracks, [])) > 0 ? { for track in try(local.device_config[each.key].tracks, []) : track.id => {
    delay_down              = try(track.delay_down, null)
    delay_down_milliseconds = try(track.delay_down_milliseconds, null)
    delay_up                = try(track.delay_up, null)
    delay_up_milliseconds   = try(track.delay_up_milliseconds, null)
    interface_id            = try(track.interface_type, null) != null ? "${local.intf_prefix_map[try(track.interface_type)]}${try(track.interface_id, "")}" : null
    interface_protocol_type = try(track.interface_line_protocol, null) == true ? "line-protocol" : try(track.interface_ip_routing, null) == true ? "ipv4-routing" : try(track.interface_ipv6_routing, null) == true ? "ipv6-routing" : null
    ip_route_address_family = try(track.ip_route, null) != null ? "ipv4" : try(track.ipv6_route, null) != null ? "ipv6" : null
    ip_route_prefix         = try(track.ip_route, null) != null ? try(track.ip_route) : try(track.ipv6_route, null)
    ip_route_owner          = try(track.ip_route_reachability_hmm, track.ipv6_route_reachability_hmm, null) == null ? null : (try(track.ip_route_reachability_hmm, track.ipv6_route_reachability_hmm) ? "hmm" : "none")
    ip_route_state          = try(track.ip_route, track.ipv6_route, null) != null ? "reachability" : null
    ip_route_vrf_name       = try(track.vrf, null)
    ip_sla_probe_id         = try(track.ip_sla, null)
    ip_sla_probe_state      = try(track.ip_sla_reachability, null) == true ? "reachability" : try(track.ip_sla_state, null) == true ? "state" : null
    list_type               = try(track.list_boolean, track.list_threshold, null)
    list_percentage_down    = try(track.threshold_percentage_down, null)
    list_percentage_up      = try(track.threshold_percentage_up, null)
    list_weight_down        = try(track.threshold_weight_down, null)
    list_weight_up          = try(track.threshold_weight_up, null)
    list_members = length(try(track.objects, [])) > 0 ? { for obj in try(track.objects, []) : obj.id => {
      negate = try(obj.not, null)
      weight = try(obj.weight, null)
    } } : null
  } } : null

  depends_on = [
    nxos_vrf.vrf,
    nxos_physical_interface.physical_interface,
    nxos_loopback_interface.loopback_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_svi_interface.svi_interface,
  ]
}
