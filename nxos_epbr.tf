locals {
  epbr_probe_protocol_map = {
    "icmp" = "ICMP"
    "tcp"  = "TCP"
    "udp"  = "UDP"
    "http" = "HTTP"
    "dns"  = "DNS"
    "ctp"  = "CTP"
  }

  epbr_load_balance_method_map = {
    "src-ip"             = "src"
    "dst-ip"             = "dst"
    "src-dst-ipprotocol" = "src-dst-ip-proto"
  }

  epbr_access_list_type_map = {
    "ip"   = "ipv4"
    "ipv6" = "ipv6"
    "l2"   = "l2"
  }

  epbr_policy_interfaces = { for device in local.devices : device.name => concat(
    flatten([
      for intf_type, intf_prefix in { "ethernets" = "eth", "port_channels" = "po", "vlans" = "vlan" } : [
        for int in try(local.device_config[device.name].interfaces[intf_type], []) : { id = "${intf_prefix}${int.id}", epbr = try(int.epbr, null) }
      ]
    ]),
    flatten([
      for intf_type, intf_prefix in { "ethernets" = "eth", "port_channels" = "po" } : [
        for int in try(local.device_config[device.name].interfaces[intf_type], []) : [
          for sub in try(int.subinterfaces, []) : { id = "${intf_prefix}${int.id}.${sub.id}", epbr = try(sub.epbr, null) }
        ]
      ]
    ])
  ) }
  epbr_interfaces_map = { for device in local.devices : device.name => merge([
    for int in local.epbr_policy_interfaces[device.name] : merge(
      try(int.epbr.ip_policy, null) != null ? { "${int.id};ipv4;no-reverse" = { policy = int.epbr.ip_policy, egress_interface = null } } : {},
      try(int.epbr.ip_policy_reverse, null) != null ? { "${int.id};ipv4;reverse" = { policy = int.epbr.ip_policy_reverse, egress_interface = null } } : {},
      try(int.epbr.ipv6_policy, null) != null ? { "${int.id};ipv6;no-reverse" = { policy = int.epbr.ipv6_policy, egress_interface = null } } : {},
      try(int.epbr.ipv6_policy_reverse, null) != null ? { "${int.id};ipv6;reverse" = { policy = int.epbr.ipv6_policy_reverse, egress_interface = null } } : {},
      try(int.epbr.l2_policy, null) != null ? { "${int.id};l2;no-reverse" = { policy = int.epbr.l2_policy, egress_interface = try(int.epbr.l2_policy_egress_interface_type, null) != null ? "${local.intf_prefix_map[try(int.epbr.l2_policy_egress_interface_type)]}${try(int.epbr.l2_policy_egress_interface_id, "")}" : null } } : {},
      try(int.epbr.l2_policy_reverse, null) != null ? { "${int.id};l2;reverse" = { policy = int.epbr.l2_policy_reverse, egress_interface = try(int.epbr.l2_policy_reverse_egress_interface_type, null) != null ? "${local.intf_prefix_map[try(int.epbr.l2_policy_reverse_egress_interface_type)]}${try(int.epbr.l2_policy_reverse_egress_interface_id, "")}" : null } } : {},
    )
  ]...) }
}

resource "nxos_epbr" "epbr" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].epbr, null) != null ||
  length(local.epbr_interfaces_map[device.name]) > 0 }
  device = each.key

  services = length(try(local.device_config[each.key].epbr.services, [])) > 0 ? { for svc in try(local.device_config[each.key].epbr.services, []) : svc.name => {
    type                           = try(svc.type, null)
    vrf                            = try(svc.vrf, null)
    service_interface              = try(svc.service_interface_type, null) != null ? "${local.intf_prefix_map[try(svc.service_interface_type)]}${try(svc.service_interface_id, "")}" : null
    admin_state                    = try(svc.shutdown, null) == null ? null : (try(svc.shutdown) ? "shut" : "noShut")
    connection_mode                = try(svc.mode, null)
    security_group                 = try(svc.security_group, null)
    reverse_security_group         = try(svc.security_group_reverse, null)
    hold_down_threshold_count      = try(svc.hold_down_threshold_count, null)
    hold_down_threshold_time       = try(svc.hold_down_threshold_time, null)
    threshold_up                   = try(svc.threshold, null)
    probe_control                  = try(svc.probe.control, null) == null ? null : (try(svc.probe.control) ? "enable" : "disable")
    probe_dns_host                 = try(svc.probe.dns_host, null)
    probe_frequency                = try(svc.probe.frequency, null)
    probe_http_get                 = try(svc.probe.http_get, null)
    probe_http_version             = try(svc.probe.http_version, null)
    probe_port                     = try(svc.probe.port, null)
    probe_protocol                 = try(local.epbr_probe_protocol_map[try(svc.probe.protocol)], null)
    probe_retry_down_count         = try(svc.probe.retry_down_count, null)
    probe_retry_up_count           = try(svc.probe.retry_up_count, null)
    probe_reverse_source_interface = try(svc.probe.reverse_interface_type, null) != null ? "${local.intf_prefix_map[try(svc.probe.reverse_interface_type)]}${try(svc.probe.reverse_interface_id, "")}" : null
    probe_source_interface         = try(svc.probe.source_interface_type, null) != null ? "${local.intf_prefix_map[try(svc.probe.source_interface_type)]}${try(svc.probe.source_interface_id, "")}" : null
    probe_timeout                  = try(svc.probe.timeout, null)

    endpoints = length(try(svc.service_end_points, [])) > 0 ? { for ep in try(svc.service_end_points, []) : ep.ip => {
      service_interface                      = try(ep.interface_type, null) != null ? "${local.intf_prefix_map[try(ep.interface_type)]}${try(ep.interface_id, "")}" : null
      admin_state                            = try(ep.shutdown, null) == null ? null : (try(ep.shutdown) ? "shut" : "noShut")
      hold_down_threshold_count              = try(ep.hold_down_threshold_count, null)
      hold_down_threshold_time               = try(ep.hold_down_threshold_time, null)
      mode                                   = try(ep.mode, null)
      weight                                 = try(ep.weight, null)
      probe_control                          = try(ep.probe.control, null) == null ? null : (try(ep.probe.control) ? "enable" : "disable")
      probe_dns_host                         = try(ep.probe.dns_host, null)
      probe_frequency                        = try(ep.probe.frequency, null)
      probe_http_get                         = try(ep.probe.http_get, null)
      probe_http_version                     = try(ep.probe.http_version, null)
      probe_port                             = try(ep.probe.port, null)
      probe_protocol                         = try(local.epbr_probe_protocol_map[try(ep.probe.protocol)], null)
      probe_retry_down_count                 = try(ep.probe.retry_down_count, null)
      probe_retry_up_count                   = try(ep.probe.retry_up_count, null)
      probe_reverse_source_interface         = try(ep.probe.reverse_interface_type, null) != null ? "${local.intf_prefix_map[try(ep.probe.reverse_interface_type)]}${try(ep.probe.reverse_interface_id, "")}" : null
      probe_source_interface                 = try(ep.probe.source_interface_type, null) != null ? "${local.intf_prefix_map[try(ep.probe.source_interface_type)]}${try(ep.probe.source_interface_id, "")}" : null
      probe_timeout                          = try(ep.probe.timeout, null)
      probe_track_id                         = try(ep.probe.track, null)
      reverse_ip                             = try(ep.reverse.ip, null)
      reverse_service_interface              = try(ep.reverse.interface_type, null) != null ? "${local.intf_prefix_map[try(ep.reverse.interface_type)]}${try(ep.reverse.interface_id, "")}" : null
      reverse_probe_control                  = try(ep.reverse.probe.control, null) == null ? null : (try(ep.reverse.probe.control) ? "enable" : "disable")
      reverse_probe_dns_host                 = try(ep.reverse.probe.dns_host, null)
      reverse_probe_frequency                = try(ep.reverse.probe.frequency, null)
      reverse_probe_http_get                 = try(ep.reverse.probe.http_get, null)
      reverse_probe_http_version             = try(ep.reverse.probe.http_version, null)
      reverse_probe_port                     = try(ep.reverse.probe.port, null)
      reverse_probe_protocol                 = try(local.epbr_probe_protocol_map[try(ep.reverse.probe.protocol)], null)
      reverse_probe_retry_down_count         = try(ep.reverse.probe.retry_down_count, null)
      reverse_probe_retry_up_count           = try(ep.reverse.probe.retry_up_count, null)
      reverse_probe_reverse_source_interface = try(ep.reverse.probe.reverse_interface_type, null) != null ? "${local.intf_prefix_map[try(ep.reverse.probe.reverse_interface_type)]}${try(ep.reverse.probe.reverse_interface_id, "")}" : null
      reverse_probe_source_interface         = try(ep.reverse.probe.source_interface_type, null) != null ? "${local.intf_prefix_map[try(ep.reverse.probe.source_interface_type)]}${try(ep.reverse.probe.source_interface_id, "")}" : null
      reverse_probe_timeout                  = try(ep.reverse.probe.timeout, null)
      reverse_probe_track_id                 = try(ep.reverse.probe.track, null)
    } } : null

    l2_endpoints = length(try(svc.service_end_point_interfaces, [])) > 0 ? { for ep in try(svc.service_end_point_interfaces, []) : "${local.intf_prefix_map[ep.interface_type]}${ep.interface_id}" => {
      probe_control                          = try(ep.probe.control, null) == null ? null : (try(ep.probe.control) ? "enable" : "disable")
      probe_dns_host                         = try(ep.probe.dns_host, null)
      probe_frequency                        = try(ep.probe.frequency, null)
      probe_http_get                         = try(ep.probe.http_get, null)
      probe_http_version                     = try(ep.probe.http_version, null)
      probe_port                             = try(ep.probe.port, null)
      probe_protocol                         = try(local.epbr_probe_protocol_map[try(ep.probe.protocol)], null)
      probe_retry_down_count                 = try(ep.probe.retry_down_count, null)
      probe_retry_up_count                   = try(ep.probe.retry_up_count, null)
      probe_reverse_source_interface         = try(ep.probe.reverse_interface_type, null) != null ? "${local.intf_prefix_map[try(ep.probe.reverse_interface_type)]}${try(ep.probe.reverse_interface_id, "")}" : null
      probe_source_interface                 = try(ep.probe.source_interface_type, null) != null ? "${local.intf_prefix_map[try(ep.probe.source_interface_type)]}${try(ep.probe.source_interface_id, "")}" : null
      probe_timeout                          = try(ep.probe.timeout, null)
      probe_track_id                         = try(ep.probe.track, null)
      reverse_service_interface              = try(ep.reverse.interface_type, null) != null ? "${local.intf_prefix_map[try(ep.reverse.interface_type)]}${try(ep.reverse.interface_id, "")}" : null
      reverse_probe_control                  = try(ep.reverse.probe.control, null) == null ? null : (try(ep.reverse.probe.control) ? "enable" : "disable")
      reverse_probe_dns_host                 = try(ep.reverse.probe.dns_host, null)
      reverse_probe_frequency                = try(ep.reverse.probe.frequency, null)
      reverse_probe_http_get                 = try(ep.reverse.probe.http_get, null)
      reverse_probe_http_version             = try(ep.reverse.probe.http_version, null)
      reverse_probe_port                     = try(ep.reverse.probe.port, null)
      reverse_probe_protocol                 = try(local.epbr_probe_protocol_map[try(ep.reverse.probe.protocol)], null)
      reverse_probe_retry_down_count         = try(ep.reverse.probe.retry_down_count, null)
      reverse_probe_retry_up_count           = try(ep.reverse.probe.retry_up_count, null)
      reverse_probe_reverse_source_interface = try(ep.reverse.probe.reverse_interface_type, null) != null ? "${local.intf_prefix_map[try(ep.reverse.probe.reverse_interface_type)]}${try(ep.reverse.probe.reverse_interface_id, "")}" : null
      reverse_probe_source_interface         = try(ep.reverse.probe.source_interface_type, null) != null ? "${local.intf_prefix_map[try(ep.reverse.probe.source_interface_type)]}${try(ep.reverse.probe.source_interface_id, "")}" : null
      reverse_probe_timeout                  = try(ep.reverse.probe.timeout, null)
      reverse_probe_track_id                 = try(ep.reverse.probe.track, null)
    } } : null
  } } : null

  service_chains = length(try(local.device_config[each.key].epbr.service_chains, [])) > 0 ? { for chain in try(local.device_config[each.key].epbr.service_chains, []) : chain.name => {
    failover_group      = try(chain.mode_multisite_failover_group, null)
    load_balance_method = try(local.epbr_load_balance_method_map[try(chain.load_balance_method)], null)
    mode                = try(chain.mode_multisite, null) == null ? null : (try(chain.mode_multisite) ? "multisite" : "no-mode")

    sequences = length(try(chain.sequences, [])) > 0 ? { for seq in try(chain.sequences, []) : seq.sequence_number => {
      service             = try(seq.set_service, null)
      action              = try(seq.action, null)
      fail_action         = try(seq.fail_action, null)
      load_balance_method = try(local.epbr_load_balance_method_map[try(seq.load_balance_method)], null)
      reverse_action      = try(seq.reverse_action, null)
    } } : null
  } } : null

  failover_groups = length(try(local.device_config[each.key].epbr.failover_groups, [])) > 0 ? { for fg in try(local.device_config[each.key].epbr.failover_groups, []) : fg.name => {
    service_chains = length(try(fg.service_chains, [])) > 0 ? { for chain in try(fg.service_chains, []) : chain.name => {
      preference = try(chain.preference, null)
    } } : null
  } } : null

  policies = length(try(local.device_config[each.key].epbr.policies, [])) > 0 ? { for pol in try(local.device_config[each.key].epbr.policies, []) : pol.name => {
    default_traffic_action = try(pol.default_traffic_action, null)
    destination_vrf        = try(pol.destination_vrf, null)
    source_vrf             = try(pol.source_vrf, null)
    statistics             = try(pol.statistics, null)

    matches = length(try(pol.matches, [])) > 0 ? { for match in try(pol.matches, []) : match.address => {
      access_list_type    = try(local.epbr_access_list_type_map[try(match.type)], null)
      buckets             = try(match.load_balance_buckets, null)
      destination_vrf     = try(match.destination_vrf, null)
      ipv6                = try(match.type, null) == "ipv6" ? true : null
      load_balance_method = try(local.epbr_load_balance_method_map[try(match.load_balance_method)], null)
      mask_position       = try(match.load_balance_mask_position, null)
      source_vrf          = try(match.source_vrf, null)
      traffic_action      = try(match.drop, false) ? "drop" : try(match.exclude, false) ? "exclude" : null
      vlans               = try(match.vlans, null) != null ? try(provider::utils::normalize_vlans(try(match.vlans), "string-nxos"), null) : null

      sequences = length(try(match.sequences, [])) > 0 ? { for seq in try(match.sequences, []) : seq.sequence_number => {
        service     = try(seq.set_service, null)
        fail_action = try(seq.fail_action, null)
      } } : null
    } } : null
  } } : null

  infra_vlans = length(try(provider::utils::normalize_vlans(try(local.device_config[each.key].epbr.infra_vlans), "list"), [])) > 0 ? { for vlan_id in try(provider::utils::normalize_vlans(try(local.device_config[each.key].epbr.infra_vlans), "list"), []) : tostring(vlan_id) => {} } : null

  interfaces = length(local.epbr_interfaces_map[each.key]) > 0 ? local.epbr_interfaces_map[each.key] : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_vrf.vrf,
    nxos_track.track,
    nxos_access_list.access_list,
    nxos_bridge_domain.bridge_domain,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_svi_interface.svi_interface,
    nxos_loopback_interface.loopback_interface,
    nxos_subinterface.subinterface,
  ]
}
