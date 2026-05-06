resource "nxos_esg" "esg" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].security_group.mac_segmentation, null) != null ||
    length(try(local.device_config[device.name].security_group.security_groups, [])) > 0 ||
    length(try(local.device_config[device.name].security_group.class_maps, [])) > 0 ||
    length(try(local.device_config[device.name].security_group.policy_maps, [])) > 0 ||
  length([for vrf in try(local.device_config[device.name].vrfs, []) : vrf if try(vrf.security_enforce_tag, null) != null || try(vrf.security_enforce_default, null) != null || try(vrf.security_enforce_mode, null) != null]) > 0 }
  device           = each.key
  mac_segmentation = try(local.device_config[each.key].security_group.mac_segmentation, null)

  security_groups = { for sg in try(local.device_config[each.key].security_group.security_groups, []) : sg.id => {
    name                              = try(sg.name, null)
    selector_connected_endpoints_ipv4 = { for ep in try(sg.match_connected_endpoints_ipv4, []) : "${ep.vrf};${ep.address}" => {} }
    selector_connected_endpoints_ipv6 = { for ep in try(sg.match_connected_endpoints_ipv6, []) : "${ep.vrf};${ep.address}" => {} }
    selector_match_vlans              = { for vlan_id in try(provider::utils::normalize_vlans(try(sg.match_vlans), "list"), []) : "vlan-${vlan_id}" => {} }
  } }

  class_maps = { for cm in try(local.device_config[each.key].security_group.class_maps, []) : cm.name => {
    description = try(cm.description, null)
    filter_entries = { for fe in try(cm.filter_entries, []) : fe.name => {
      apply_to_fragment           = try(fe.apply_to_fragment, null)
      arp_opcode                  = try(fe.arp_opcode, null)
      ether_type                  = try(fe.ether_type, null)
      icmpv4_type                 = try(fe.icmpv4_type, null)
      icmpv6_type                 = try(fe.icmpv6_type, null)
      match_destination_port_zero = try(fe.match_dest_port_zero, null)
      match_dscp                  = try(fe.match_dscp, null)
      match_source_port_zero      = try(fe.match_source_port_zero, null)
      stateful                    = try(fe.stateful, null)
    } }
  } }

  policy_maps = { for pm in try(local.device_config[each.key].security_group.policy_maps, []) : pm.name => {
    description = try(pm.description, null)
    match_class_maps = { for mc in try(pm.classes, []) : mc.class => {
      count_action      = try(mc.count, null)
      forwarding_action = try(mc.action, null)
      log_action        = try(mc.log, null)
      redirect_chain    = try(mc.redirect, null)
    } }
  } }

  domains = { for vrf in try(local.device_config[each.key].vrfs, []) : vrf.name => {
    default_action        = try(vrf.security_enforce_default, null)
    policy_classifier_tag = try(vrf.security_enforce_tag, null)
    security_mode         = try(vrf.security_enforce_mode, null)
  } if try(vrf.security_enforce_tag, null) != null || try(vrf.security_enforce_default, null) != null || try(vrf.security_enforce_mode, null) != null }

  depends_on = [
    nxos_feature.feature,
    nxos_system.system,
    nxos_vrf.vrf,
  ]
}
