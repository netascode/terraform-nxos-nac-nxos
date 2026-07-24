resource "nxos_object_group" "object_group" {
  for_each = { for device in local.devices : device.name => device
    if length(try(local.device_config[device.name].ipv4_address_object_groups, [])) > 0 ||
    length(try(local.device_config[device.name].ipv6_address_object_groups, [])) > 0 ||
  length(try(local.device_config[device.name].port_object_groups, [])) > 0 }
  device = each.key

  ipv4_address_object_groups = length(try(local.device_config[each.key].ipv4_address_object_groups, [])) > 0 ? { for og in try(local.device_config[each.key].ipv4_address_object_groups, []) : og.name => {
    members = length(try(og.members, [])) > 0 ? { for m in try(og.members, []) : m.sequence_number => {
      prefix        = try(m.prefix, null)
      prefix_length = try(tostring(m.prefix_length), null)
      prefix_mask   = try(m.prefix_mask, null)
    } } : null
  } } : null

  ipv6_address_object_groups = length(try(local.device_config[each.key].ipv6_address_object_groups, [])) > 0 ? { for og in try(local.device_config[each.key].ipv6_address_object_groups, []) : og.name => {
    members = length(try(og.members, [])) > 0 ? { for m in try(og.members, []) : m.sequence_number => {
      prefix        = try(m.prefix, null)
      prefix_length = try(tostring(m.prefix_length), null)
      prefix_mask   = try(m.prefix_mask, null)
    } } : null
  } } : null

  port_object_groups = length(try(local.device_config[each.key].port_object_groups, [])) > 0 ? { for og in try(local.device_config[each.key].port_object_groups, []) : og.name => {
    members = length(try(og.members, [])) > 0 ? { for m in try(og.members, []) : m.sequence_number => {
      port_operator = try(m.port_operator, null)
      port_1        = try(tostring(m.port_1), null)
      port_2        = try(tostring(m.port_2), null)
    } } : null
  } } : null
}
