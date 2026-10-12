locals {
  # ESG class map filter entries use the uppercase DSCP names returned by DME; values without a name are plain numbers.
  esg_dscp_int_to_string_map = {
    8  = "CS1"
    10 = "AF11"
    12 = "AF12"
    14 = "AF13"
    16 = "CS2"
    18 = "AF21"
    20 = "AF22"
    22 = "AF23"
    24 = "CS3"
    26 = "AF31"
    28 = "AF32"
    30 = "AF33"
    32 = "CS4"
    34 = "AF41"
    36 = "AF42"
    38 = "AF43"
    40 = "CS5"
    44 = "VA"
    46 = "EF"
    48 = "CS6"
  }

  # ESG class map filter entries use the protocol names returned by DME; protocols without a name are plain numbers.
  esg_protocol_int_to_string_map = {
    1   = "icmp"
    2   = "igmp"
    6   = "tcp"
    8   = "egp"
    9   = "igp"
    17  = "udp"
    58  = "icmpv6"
    88  = "eigrp"
    89  = "ospfigp"
    103 = "pim"
    115 = "l2tp"
  }

  # ESG class map filter entries use the port names returned by DME; ports without a name are plain numbers.
  esg_port_int_to_string_map = {
    20  = "ftpData"
    25  = "smtp"
    53  = "dns"
    80  = "http"
    110 = "pop3"
    443 = "https"
    554 = "rtsp"
  }

  esg_domains_map = { for device in local.devices : device.name =>
    { for vrf in try(local.device_config[device.name].vrfs, []) : vrf.name => {
      default_action        = try(vrf.security_enforce_default, null)
      policy_classifier_tag = try(vrf.security_enforce_tag, null)
      contracts = length(try(vrf.security_contracts, [])) > 0 ? { for contract in try(vrf.security_contracts, []) : "${contract.source};${contract.destination};${contract.policy}" => {
        direction = try(contract.unidir, null) == null ? null : (try(contract.unidir) ? "uni-dir" : "bi-dir")
      } } : null
    } if try(vrf.security_enforce_tag, null) != null || try(vrf.security_enforce_default, null) != null || length(try(vrf.security_contracts, [])) > 0 }
  }
}

resource "nxos_esg" "esg" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].security_group.mac_segmentation, null) != null ||
    length(try(local.device_config[device.name].security_group.security_groups, [])) > 0 ||
    length(try(local.device_config[device.name].security_group.class_maps, [])) > 0 ||
    length(try(local.device_config[device.name].security_group.policy_maps, [])) > 0 ||
  length([for vrf in try(local.device_config[device.name].vrfs, []) : vrf if try(vrf.security_enforce_tag, null) != null || try(vrf.security_enforce_default, null) != null || length(try(vrf.security_contracts, [])) > 0]) > 0 }
  device           = each.key
  mac_segmentation = try(local.device_config[each.key].security_group.mac_segmentation, null)

  security_groups = length(try(local.device_config[each.key].security_group.security_groups, [])) > 0 ? { for sg in try(local.device_config[each.key].security_group.security_groups, []) : sg.id => {
    name                              = try(sg.name, null)
    type_layer4_7                     = try(sg.type_layer4_7, null) == null ? null : (try(sg.type_layer4_7) ? "enabled" : "disabled")
    intra_group_isolation             = try(sg.intra_group_isolation, null) == null ? null : (try(sg.intra_group_isolation) ? "enabled" : "disabled")
    selector_connected_endpoints_ipv4 = length(try(sg.match_connected_endpoints_ipv4, [])) > 0 ? { for ep in try(sg.match_connected_endpoints_ipv4, []) : "${ep.vrf};${ep.address}" => {} } : null
    selector_connected_endpoints_ipv6 = length(try(sg.match_connected_endpoints_ipv6, [])) > 0 ? { for ep in try(sg.match_connected_endpoints_ipv6, []) : "${ep.vrf};${ep.address}" => {} } : null
    # External subnet selectors are split by the presence of nexthop and encap-type into separate DME classes.
    selector_external_subnets_ipv4 = length([for es in try(sg.match_external_subnets_ipv4, []) : es if try(es.nexthop_ipv4, null) == null]) > 0 ? { for es in try(sg.match_external_subnets_ipv4, []) : "${es.vrf};${es.address}" => {
      route_inject = try(es.route_inject, null) == null ? null : (try(es.route_inject) ? "enabled" : "disabled")
    } if try(es.nexthop_ipv4, null) == null } : null
    selector_external_subnets_nexthop_ipv4       = length([for es in try(sg.match_external_subnets_ipv4, []) : es if try(es.nexthop_ipv4, null) != null && try(es.encap_type, null) == null]) > 0 ? { for es in try(sg.match_external_subnets_ipv4, []) : "${es.vrf};${es.address};${es.nexthop_ipv4}" => {} if try(es.nexthop_ipv4, null) != null && try(es.encap_type, null) == null } : null
    selector_external_subnets_nexthop_encap_ipv4 = length([for es in try(sg.match_external_subnets_ipv4, []) : es if try(es.nexthop_ipv4, null) != null && try(es.encap_type, null) != null]) > 0 ? { for es in try(sg.match_external_subnets_ipv4, []) : "${es.vrf};${es.address};${es.nexthop_ipv4};${es.encap_type}" => {} if try(es.nexthop_ipv4, null) != null && try(es.encap_type, null) != null } : null
    selector_external_subnets_ipv6 = length([for es in try(sg.match_external_subnets_ipv6, []) : es if try(es.nexthop_ipv4, null) == null && try(es.nexthop_ipv6, null) == null]) > 0 ? { for es in try(sg.match_external_subnets_ipv6, []) : "${es.vrf};${es.address}" => {
      route_inject = try(es.route_inject, null) == null ? null : (try(es.route_inject) ? "enabled" : "disabled")
    } if try(es.nexthop_ipv4, null) == null && try(es.nexthop_ipv6, null) == null } : null
    selector_external_subnets_nexthop_ipv6       = length([for es in try(sg.match_external_subnets_ipv6, []) : es if try(coalesce(try(es.nexthop_ipv6, null), try(es.nexthop_ipv4, null)), null) != null && try(es.encap_type, null) == null]) > 0 ? { for es in try(sg.match_external_subnets_ipv6, []) : "${es.vrf};${es.address};${coalesce(try(es.nexthop_ipv6, null), try(es.nexthop_ipv4, null))}" => {} if try(coalesce(try(es.nexthop_ipv6, null), try(es.nexthop_ipv4, null)), null) != null && try(es.encap_type, null) == null } : null
    selector_external_subnets_nexthop_encap_ipv6 = length([for es in try(sg.match_external_subnets_ipv6, []) : es if try(coalesce(try(es.nexthop_ipv4, null), try(es.nexthop_ipv6, null)), null) != null && try(es.encap_type, null) != null]) > 0 ? { for es in try(sg.match_external_subnets_ipv6, []) : "${es.vrf};${es.address};${coalesce(try(es.nexthop_ipv4, null), try(es.nexthop_ipv6, null))};${es.encap_type}" => {} if try(coalesce(try(es.nexthop_ipv4, null), try(es.nexthop_ipv6, null)), null) != null && try(es.encap_type, null) != null } : null
    selector_match_interfaces                    = length(try(sg.match_interfaces, [])) > 0 ? { for intf in try(sg.match_interfaces, []) : "${local.intf_prefix_map[intf.interface_type]}${intf.interface_id}" => {} } : null
    selector_match_vlans                         = length(try(provider::utils::normalize_vlans(try(sg.match_vlans), "list"), [])) > 0 ? { for vlan_id in try(provider::utils::normalize_vlans(try(sg.match_vlans), "list"), []) : "vlan-${vlan_id}" => {} } : null
    # DME stores MAC addresses as uppercase colon-separated octets (e.g. 00:1B:63:84:45:E6).
    selector_match_vlan_macs       = length(try(sg.match_vlan_macs, [])) > 0 ? { for vm in try(sg.match_vlan_macs, []) : "vlan-${vm.vlan};${upper(join(":", regexall("[0-9A-Fa-f]{2}", replace(vm.mac, "/[^0-9A-Fa-f]/", ""))))}" => {} } : null
    selector_match_vlan_interfaces = length(try(sg.match_vlan_interfaces, [])) > 0 ? { for vi in try(sg.match_vlan_interfaces, []) : "vlan-${vi.vlan};${local.intf_prefix_map[vi.interface_type]}${vi.interface_id}" => {} } : null
  } } : null

  class_maps = length(try(local.device_config[each.key].security_group.class_maps, [])) > 0 ? { for cm in try(local.device_config[each.key].security_group.class_maps, []) : cm.name => {
    description = try(cm.description, null)
    filter_entries = length(try(cm.filter_entries, [])) > 0 ? { for fe in try(cm.filter_entries, []) : fe.name => {
      apply_to_fragment     = try(fe.fragments, null)
      destination_port_from = try(tostring(fe.dport), null) != null ? try(local.esg_port_int_to_string_map[fe.dport], tostring(fe.dport)) : null
      destination_port_to   = try(tostring(try(fe.dport_to, fe.dport)), null) != null ? try(local.esg_port_int_to_string_map[try(fe.dport_to, fe.dport)], tostring(try(fe.dport_to, fe.dport))) : null
      ether_type            = try(fe.ether_type, null)
      icmpv4_type           = try(fe.icmpv4_type, null)
      icmpv6_type           = try(fe.icmpv6_type, null)
      match_dscp            = try(tostring(fe.dscp), null) != null ? try(local.esg_dscp_int_to_string_map[fe.dscp], tostring(fe.dscp)) : null
      protocol              = try(tostring(fe.protocol), null) != null ? try(local.esg_protocol_int_to_string_map[fe.protocol], tostring(fe.protocol)) : null
      source_port_from      = try(tostring(fe.sport), null) != null ? try(local.esg_port_int_to_string_map[fe.sport], tostring(fe.sport)) : null
      source_port_to        = try(tostring(try(fe.sport_to, fe.sport)), null) != null ? try(local.esg_port_int_to_string_map[try(fe.sport_to, fe.sport)], tostring(try(fe.sport_to, fe.sport))) : null
      stateful              = try(fe.stateful, null)
      tcp_rules             = length(try(fe.session_rule, [])) > 0 ? join(",", sort(fe.session_rule)) : null
    } } : null
  } } : null

  policy_maps = length(try(local.device_config[each.key].security_group.policy_maps, [])) > 0 ? { for pm in try(local.device_config[each.key].security_group.policy_maps, []) : pm.name => {
    description = try(pm.description, null)
    match_class_maps = length(try(pm.classes, [])) > 0 ? { for mc in try(pm.classes, []) : mc.class => {
      count_action      = try(mc.count, null)
      forwarding_action = try(mc.action, null)
      log_action        = try(mc.log, null)
      redirect_chain    = try(mc.redirect, null)
    } } : null
  } } : null

  domains = length(local.esg_domains_map[each.key]) > 0 ? local.esg_domains_map[each.key] : null

  depends_on = [
    nxos_feature.feature,
    nxos_vrf.vrf,
  ]
}
