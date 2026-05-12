locals {
  span_type_map = {
    "local"              = "local"
    "erspan-source"      = "erspan-source"
    "erspan-destination" = "erspanDst"
  }

  span_header_type_map = {
    "2"               = "v2"
    "3"               = "v3"
    "3-rfc-compliant" = "v3-rfc-compliant"
  }
}

resource "nxos_span" "span" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].monitor_sessions, [])) > 0 }
  device = each.key
  sessions = length(try(local.device_config[each.key].monitor_sessions, [])) > 0 ? { for session in try(local.device_config[each.key].monitor_sessions, []) : session.id => {
    acl_name                   = try(session.filter_access_group, null)
    config_state               = try(session.shutdown, null) == null ? null : try(session.shutdown) ? "down" : "up"
    description                = try(session.description, null)
    destination_ip             = try(session.destination_ip, null)
    destination_ipv6           = try(session.destination_ipv6, null)
    destination_ports          = try(session.destination_interface_type, null) != null ? "${local.intf_prefix_map[try(session.destination_interface_type)]}${try(session.destination_interface_id, "")}" : null
    erspan_id                  = try(session.erspan_id, null)
    forwarding_drops_direction = try(session.source_forward_drops, null)
    header_type                = try(local.span_header_type_map[try(session.header_type)], null)
    ip_dscp                    = try(session.ip_dscp, null)
    ip_ttl                     = try(session.ip_ttl, null)
    marker_packet              = try(session.marker_packet, null)
    marker_packet_interval     = try(session.marker_packet_interval, null)
    mtu                        = try(session.mtu, null)
    source_ip                  = try(session.source_ip, null)
    source_ipv6                = try(session.source_ipv6, null)
    type                       = try(local.span_type_map[try(session.type)], null)
    vrf_name                   = try(session.vrf, null)
    source_interfaces = length(try(session.source_interfaces, [])) > 0 ? { for si in try(session.source_interfaces, []) : "${local.intf_prefix_map[try(si.interface_type)]}${try(si.interface_id)}" => {
      direction = try(si.direction, null)
    } } : null
    source_vlans = length(try(session.source_vlans, [])) > 0 ? merge([for sv in try(session.source_vlans, []) : {
      for vlan_id in try(provider::utils::normalize_vlans(sv.vlans, "list"), []) :
      "vlan-${vlan_id}" => { direction = try(sv.direction, null) }
    }]...) : null
    filter_vlans = try(provider::utils::normalize_vlans(try(session.filter_vlans), "string-nxos"), null)
  } } : null

  depends_on = [
    nxos_feature.feature,
  ]
}
