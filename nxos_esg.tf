locals {
  esg_domains_map = { for device in local.devices : device.name =>
    { for vrf in try(local.device_config[device.name].vrfs, []) : vrf.name => {
      default_action        = try(vrf.security_enforce_default, null)
      policy_classifier_tag = try(vrf.security_enforce_tag, null)
    } if try(vrf.security_enforce_tag, null) != null || try(vrf.security_enforce_default, null) != null }
  }
}

resource "nxos_esg" "esg" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].security_group.mac_segmentation, null) != null ||
    length(try(local.device_config[device.name].security_group.security_groups, [])) > 0 ||
    length(try(local.device_config[device.name].security_group.class_maps, [])) > 0 ||
    length(try(local.device_config[device.name].security_group.policy_maps, [])) > 0 ||
  length([for vrf in try(local.device_config[device.name].vrfs, []) : vrf if try(vrf.security_enforce_tag, null) != null || try(vrf.security_enforce_default, null) != null]) > 0 }
  device           = each.key
  mac_segmentation = try(local.device_config[each.key].security_group.mac_segmentation, null)

  security_groups = length(try(local.device_config[each.key].security_group.security_groups, [])) > 0 ? { for sg in try(local.device_config[each.key].security_group.security_groups, []) : sg.id => {
    name                              = try(sg.name, null)
    selector_connected_endpoints_ipv4 = length(try(sg.match_connected_endpoints_ipv4, [])) > 0 ? { for ep in try(sg.match_connected_endpoints_ipv4, []) : "${ep.vrf};${ep.address}" => {} } : null
    selector_connected_endpoints_ipv6 = length(try(sg.match_connected_endpoints_ipv6, [])) > 0 ? { for ep in try(sg.match_connected_endpoints_ipv6, []) : "${ep.vrf};${ep.address}" => {} } : null
    selector_match_vlans              = length(try(provider::utils::normalize_vlans(try(sg.match_vlans), "list"), [])) > 0 ? { for vlan_id in try(provider::utils::normalize_vlans(try(sg.match_vlans), "list"), []) : "vlan-${vlan_id}" => {} } : null
  } } : null

  class_maps = length(try(local.device_config[each.key].security_group.class_maps, [])) > 0 ? { for cm in try(local.device_config[each.key].security_group.class_maps, []) : cm.name => {
    description = try(cm.description, null)
    filter_entries = length(try(cm.filter_entries, [])) > 0 ? { for fe in try(cm.filter_entries, []) : fe.name => {
      apply_to_fragment = try(fe.fragments, null)
      icmpv4_type       = try(fe.icmpv4_type, null)
      icmpv6_type       = try(fe.icmpv6_type, null)
      match_dscp        = try(fe.dscp, null)
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
