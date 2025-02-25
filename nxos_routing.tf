locals {
  routing_ipv4_prefix_list_rule = flatten([
    for device in local.devices : [
      for ipv4_prefix_list in try(local.device_config[device.name].routing.ipv4_prefix_lists, []) : {
        key    = format("%s/%s", device.name, ipv4_prefix_list.name),
        device = device.name,
        name   = ipv4_prefix_list.name
      }
    ]
  ])
}

resource "nxos_ipv4_prefix_list_rule" "ipv4_prefix_list_rule" {
  for_each = { for v in local.routing_ipv4_prefix_list_rule : v.key => v }
  device   = each.value.device
  name     = each.value.name
}

locals {
  routing_ipv4_prefix_list_rule_entry = flatten([
    for device in local.devices : [
      for ipv4_prefix_list in try(local.device_config[device.name].routing.ipv4_prefix_lists, []) : [
        for entry in try(ipv4_prefix_list.entries, []) : {
          key        = format("%s/%s/%s", device.name, ipv4_prefix_list.name, entry.order),
          device     = device.name,
          rule_name  = ipv4_prefix_list.name,
          order      = entry.order,
          action     = try(entry.action, local.defaults.nxos.configuration.routing.ipv4_prefix_lists.entries.action, "permit"),
          prefix     = try(entry.prefix, null),
          criteria   = try(entry.criteria, "exact"),
          from_range = try(entry.from_range, 0),
          to_range   = try(entry.to_range, 0)
        }
      ]
    ]
  ])
}

resource "nxos_ipv4_prefix_list_rule_entry" "ipv4_prefix_list_rule_entry" {
  for_each   = { for v in local.routing_ipv4_prefix_list_rule_entry : v.key => v }
  device     = each.value.device
  rule_name  = each.value.rule_name
  order      = each.value.order
  action     = each.value.action
  prefix     = each.value.prefix
  criteria   = each.value.criteria
  to_range   = each.value.to_range
  from_range = each.value.from_range

  depends_on = [nxos_ipv4_prefix_list_rule.ipv4_prefix_list_rule]
}