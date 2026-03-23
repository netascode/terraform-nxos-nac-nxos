resource "nxos_access_list" "access_list" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].ip_access_lists, [])) > 0 }
  device = each.key
  access_lists = { for acl in try(local.device_config[each.key].ip_access_lists, []) : acl.name => {
    fragments          = try(acl.fragments, local.defaults.nxos.devices.configuration.ip_access_lists.fragments, null)
    per_ace_statistics = try(acl.statistics_per_entry, local.defaults.nxos.devices.configuration.ip_access_lists.statistics_per_entry, false) ? "on" : "off"
    entries = { for entry in try(acl.entries, []) : entry.sequence_number => {
      remark                    = try(entry.remark, local.defaults.nxos.devices.configuration.ip_access_lists.entries.remark, null)
      action                    = try(entry.action, local.defaults.nxos.devices.configuration.ip_access_lists.entries.action, null)
      protocol                  = try(tostring(entry.protocol), tostring(local.defaults.nxos.devices.configuration.ip_access_lists.entries.protocol), null)
      source_prefix             = try(entry.source.prefix, local.defaults.nxos.devices.configuration.ip_access_lists.entries.source.prefix, null)
      source_prefix_length      = try(tostring(entry.source.prefix_length), tostring(local.defaults.nxos.devices.configuration.ip_access_lists.entries.source.prefix_length), null)
      source_prefix_mask        = try(entry.source.prefix_mask, local.defaults.nxos.devices.configuration.ip_access_lists.entries.source.prefix_mask, null)
      source_address_group      = try(entry.source.address_group, local.defaults.nxos.devices.configuration.ip_access_lists.entries.source.address_group, null)
      source_port_operator      = try(entry.source.port_operator, local.defaults.nxos.devices.configuration.ip_access_lists.entries.source.port_operator, null)
      source_port_1             = try(tostring(entry.source.port_1), tostring(local.defaults.nxos.devices.configuration.ip_access_lists.entries.source.port_1), null)
      source_port_2             = try(tostring(entry.source.port_2), tostring(local.defaults.nxos.devices.configuration.ip_access_lists.entries.source.port_2), null)
      source_port_group         = try(entry.source.port_group, local.defaults.nxos.devices.configuration.ip_access_lists.entries.source.port_group, null)
      destination_prefix        = try(entry.destination.prefix, local.defaults.nxos.devices.configuration.ip_access_lists.entries.destination.prefix, null)
      destination_prefix_length = try(tostring(entry.destination.prefix_length), tostring(local.defaults.nxos.devices.configuration.ip_access_lists.entries.destination.prefix_length), null)
      destination_prefix_mask   = try(entry.destination.prefix_mask, local.defaults.nxos.devices.configuration.ip_access_lists.entries.destination.prefix_mask, null)
      destination_address_group = try(entry.destination.address_group, local.defaults.nxos.devices.configuration.ip_access_lists.entries.destination.address_group, null)
      destination_port_operator = try(entry.destination.port_operator, local.defaults.nxos.devices.configuration.ip_access_lists.entries.destination.port_operator, null)
      destination_port_1        = try(tostring(entry.destination.port_1), tostring(local.defaults.nxos.devices.configuration.ip_access_lists.entries.destination.port_1), null)
      destination_port_2        = try(tostring(entry.destination.port_2), tostring(local.defaults.nxos.devices.configuration.ip_access_lists.entries.destination.port_2), null)
      destination_port_group    = try(entry.destination.port_group, local.defaults.nxos.devices.configuration.ip_access_lists.entries.destination.port_group, null)
      dscp                      = try(entry.dscp, local.defaults.nxos.devices.configuration.ip_access_lists.entries.dscp, null)
      fragment                  = try(entry.fragment, local.defaults.nxos.devices.configuration.ip_access_lists.entries.fragment, null)
      log                       = try(entry.log, local.defaults.nxos.devices.configuration.ip_access_lists.entries.log, null)
      established               = try(entry.established, local.defaults.nxos.devices.configuration.ip_access_lists.entries.established, null)
      ack                       = try(entry.ack, local.defaults.nxos.devices.configuration.ip_access_lists.entries.ack, null)
      fin                       = try(entry.fin, local.defaults.nxos.devices.configuration.ip_access_lists.entries.fin, null)
      psh                       = try(entry.psh, local.defaults.nxos.devices.configuration.ip_access_lists.entries.psh, null)
      rst                       = try(entry.rst, local.defaults.nxos.devices.configuration.ip_access_lists.entries.rst, null)
      syn                       = try(entry.syn, local.defaults.nxos.devices.configuration.ip_access_lists.entries.syn, null)
      urg                       = try(entry.urg, local.defaults.nxos.devices.configuration.ip_access_lists.entries.urg, null)
      icmp_type                 = try(entry.icmp_type, local.defaults.nxos.devices.configuration.ip_access_lists.entries.icmp_type, null)
      icmp_code                 = try(entry.icmp_code, local.defaults.nxos.devices.configuration.ip_access_lists.entries.icmp_code, null)
      icmp_string               = try(entry.icmp_message, local.defaults.nxos.devices.configuration.ip_access_lists.entries.icmp_message, null)
      http_option_type          = try(entry.http_method, local.defaults.nxos.devices.configuration.ip_access_lists.entries.http_method, null)
      time_range                = try(entry.time_range, local.defaults.nxos.devices.configuration.ip_access_lists.entries.time_range, null)
      redirect                  = try(entry.redirect, local.defaults.nxos.devices.configuration.ip_access_lists.entries.redirect, null)
      packet_length_operator    = try(entry.packet_length_operator, local.defaults.nxos.devices.configuration.ip_access_lists.entries.packet_length_operator, null)
      packet_length_1           = try(tostring(entry.packet_length_1), tostring(local.defaults.nxos.devices.configuration.ip_access_lists.entries.packet_length_1), null)
      packet_length_2           = try(tostring(entry.packet_length_2), tostring(local.defaults.nxos.devices.configuration.ip_access_lists.entries.packet_length_2), null)
      precedence                = try(tostring(entry.precedence), tostring(local.defaults.nxos.devices.configuration.ip_access_lists.entries.precedence), null)
      vlan                      = try(entry.vlan, local.defaults.nxos.devices.configuration.ip_access_lists.entries.vlan, null)
      vni                       = try(entry.vni, local.defaults.nxos.devices.configuration.ip_access_lists.entries.vni, null)
    } }
  } }
}
