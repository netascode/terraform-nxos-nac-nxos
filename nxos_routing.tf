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

locals {
  routing_route_map_rule = flatten([
    for device in local.devices : [
      for route_map in try(local.device_config[device.name].routing.route_maps, []) : {
        key    = format("%s/%s", device.name, route_map.name),
        device = device.name,
        name   = route_map.name
      }
    ]
  ])
}

resource "nxos_route_map_rule" "route_map_rule" {
  for_each = { for v in local.routing_route_map_rule : v.key => v }
  device   = each.value.device
  name     = each.value.name
}

locals {
  routing_route_map_rule_entry = flatten([
    for device in local.devices : [
      for route_map in try(local.device_config[device.name].routing.route_maps, []) : [
        for entry in try(route_map.entries, []) : {
          key       = format("%s/%s/%s", device.name, route_map.name, entry.order),
          device    = device.name,
          rule_name = route_map.name,
          order     = entry.order,
          action    = try(entry.action, local.defaults.nxos.configuration.routing.route_maps.entries.action, "permit"),
        }
      ]
    ]
  ])
}

resource "nxos_route_map_rule_entry" "route_map_rule_entry" {
  for_each   = { for v in local.routing_route_map_rule_entry : v.key => v }
  device     = each.value.device
  rule_name  = each.value.rule_name
  order      = each.value.order
  action     = each.value.action
  depends_on = [nxos_route_map_rule.route_map_rule]
}

locals {
  routing_route_map_rule_entry_match_route = flatten([
    for device in local.devices : [
      for route_map in try(local.device_config[device.name].routing.route_maps, []) : [
        for entry in try(route_map.entries, []) : (
          try(entry.match_prefix_list, null) != null ? [
            {
              key       = format("%s/%s/%s", device.name, route_map.name, entry.order),
              device    = device.name,
              rule_name = route_map.name,
              order     = entry.order,
            }
          ] : []
        )
      ]
    ]
  ])
}

resource "nxos_route_map_rule_entry_match_route" "route_map_rule_entry_match_route" {
  for_each   = { for v in local.routing_route_map_rule_entry_match_route : v.key => v }
  device     = each.value.device
  rule_name  = each.value.rule_name
  order      = each.value.order
  depends_on = [nxos_route_map_rule_entry.route_map_rule_entry]
}

locals {
  routing_route_map_rule_entry_match_route_prefix_list = flatten([
    for device in local.devices : [
      for route_map in try(local.device_config[device.name].routing.route_maps, []) : [
        for entry in try(route_map.entries, []) : (
          try(entry.match_prefix_list, null) != null ? [
            {
              key            = format("%s/%s/%s", device.name, route_map.name, entry.order),
              device         = device.name,
              rule_name      = route_map.name,
              order          = entry.order,
              prefix_list_dn = format("sys/rpm/pfxlistv4-[%s]", entry.match_prefix_list)
            }
          ] : []
        )
      ]
    ]
  ])
}

resource "nxos_route_map_rule_entry_match_route_prefix_list" "route_map_rule_entry_match_route_prefix_list" {
  for_each       = { for v in local.routing_route_map_rule_entry_match_route_prefix_list : v.key => v }
  device         = each.value.device
  rule_name      = each.value.rule_name
  order          = each.value.order
  prefix_list_dn = each.value.prefix_list_dn
  depends_on     = [nxos_route_map_rule_entry_match_route.route_map_rule_entry_match_route]
}

locals {
  routing_route_map_rule_entry_set_regular_community = flatten([
    for device in local.devices : [
      for route_map in try(local.device_config[device.name].routing.route_maps, []) : [
        for entry in try(route_map.entries, []) : [
          for option in ["additive", "no_community", "set_criteria"] : (
            try(entry[option], null) != null ? [
              {
                key          = format("%s/%s/%s/%s", device.name, route_map.name, entry.order, option),
                device       = device.name,
                rule_name    = route_map.name,
                order        = entry.order,
                additive     = try(entry.additive, "disabled"),
                no_community = try(entry.no_community, "disabled"),
                set_criteria = try(entry.set_criteria, "none")
              }
            ] : []
          )
        ]
      ]
    ]
  ])
}

resource "nxos_route_map_rule_entry_set_regular_community" "route_map_rule_entry_set_regular_community" {
  for_each     = { for v in local.routing_route_map_rule_entry_set_regular_community : v.key => v }
  device       = each.value.device
  rule_name    = each.value.rule_name
  order        = each.value.order
  additive     = each.value.additive
  no_community = each.value.no_community
  set_criteria = each.value.set_criteria
  depends_on   = [nxos_route_map_rule_entry.route_map_rule_entry]
}

locals {
  routing_route_map_rule_entry_set_regular_community_item = flatten([
    for device in local.devices : [
      for route_map in try(local.device_config[device.name].routing.route_maps, []) : [
        for entry in try(route_map.entries, []) : (
          try(entry.community, null) != null ? [
            {
              key       = format("%s/%s/%s", device.name, route_map.name, entry.order),
              device    = device.name,
              rule_name = route_map.name,
              order     = entry.order,
              community = entry.community
            }
          ] : []
        )
      ]
    ]
  ])
}

resource "nxos_route_map_rule_entry_set_regular_community_item" "route_map_rule_entry_set_regular_community_item" {
  for_each   = { for v in local.routing_route_map_rule_entry_set_regular_community_item : v.key => v }
  device     = each.value.device
  rule_name  = each.value.rule_name
  order      = each.value.order
  community  = each.value.community
  depends_on = [nxos_route_map_rule_entry_set_regular_community.route_map_rule_entry_set_regular_community]
}