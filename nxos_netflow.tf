resource "nxos_netflow" "netflow" {
  for_each = { for device in local.devices : device.name => device
    if length(try(local.device_config[device.name].netflow.exporters, [])) > 0 ||
    length(try(local.device_config[device.name].netflow.records, [])) > 0 ||
    length(try(local.device_config[device.name].netflow.monitors, [])) > 0 ||
    length(try(local.device_config[device.name].netflow.hardware_profiles, [])) > 0 ||
  length(try(local.device_config[device.name].netflow.class_maps, [])) > 0 }
  device = each.key

  exporters = length(try(local.device_config[each.key].netflow.exporters, [])) > 0 ? { for exporter in try(local.device_config[each.key].netflow.exporters, []) : exporter.name => {
    description      = try(exporter.description, null)
    destination_ip   = try(exporter.destination, null)
    destination_port = try(exporter.transport_udp, null)
    dscp             = try(exporter.dscp, null)
    source_interface = try(exporter.source_interface_type, null) != null ? "${local.intf_prefix_map[try(exporter.source_interface_type)]}${try(exporter.source_interface_id, "")}" : null
    version          = try(exporter.version, null)
    vrf_name         = try(exporter.vrf, null)
  } } : null

  records = length(try(local.device_config[each.key].netflow.records, [])) > 0 ? { for record in try(local.device_config[each.key].netflow.records, []) : record.name => {
    description = try(record.description, null)
    collect_parameters = sum([
      try(record.collect_counter_bytes, false) ? 1 : 0,
      try(record.collect_counter_packets, false) ? 2 : 0,
      try(record.collect_timestamp_sys_uptime_first, false) ? 16 : 0,
      try(record.collect_timestamp_sys_uptime_last, false) ? 32 : 0,
      ]) > 0 ? join(",", sort([
        for pair in [
          { v = "count-bytes", b = try(record.collect_counter_bytes, false) },
          { v = "count-pkts", b = try(record.collect_counter_packets, false) },
          { v = "ts-first", b = try(record.collect_timestamp_sys_uptime_first, false) },
          { v = "ts-recent", b = try(record.collect_timestamp_sys_uptime_last, false) },
        ] : pair.v if pair.b
    ])) : null
    match_parameters = sum([
      try(record.match_datalink_ethertype, false) ? 1 : 0,
      try(record.match_datalink_mac_destination_address, false) ? 1 : 0,
      try(record.match_datalink_mac_source_address, false) ? 1 : 0,
      try(record.match_datalink_vlan, false) ? 1 : 0,
      try(record.match_ip_protocol, false) ? 1 : 0,
      try(record.match_ip_tos, false) ? 1 : 0,
      try(record.match_ipv4_source_address, false) ? 1 : 0,
      try(record.match_ipv4_destination_address, false) ? 1 : 0,
      try(record.match_ipv6_source_address, false) ? 1 : 0,
      try(record.match_ipv6_destination_address, false) ? 1 : 0,
      try(record.match_transport_source_port, false) ? 1 : 0,
      try(record.match_transport_destination_port, false) ? 1 : 0,
      ]) > 0 ? join(",", sort([
        for pair in [
          { v = "ethertype", b = try(record.match_datalink_ethertype, false) },
          { v = "dst-mac", b = try(record.match_datalink_mac_destination_address, false) },
          { v = "src-mac", b = try(record.match_datalink_mac_source_address, false) },
          { v = "vlan", b = try(record.match_datalink_vlan, false) },
          { v = "protocol", b = try(record.match_ip_protocol, false) },
          { v = "tos", b = try(record.match_ip_tos, false) },
          { v = "src-ipv4", b = try(record.match_ipv4_source_address, false) },
          { v = "dst-ipv4", b = try(record.match_ipv4_destination_address, false) },
          { v = "src-ipv6", b = try(record.match_ipv6_source_address, false) },
          { v = "dst-ipv6", b = try(record.match_ipv6_destination_address, false) },
          { v = "src-port", b = try(record.match_transport_source_port, false) },
          { v = "dst-port", b = try(record.match_transport_destination_port, false) },
        ] : pair.v if pair.b
    ])) : null
  } } : null

  monitors = length(try(local.device_config[each.key].netflow.monitors, [])) > 0 ? { for monitor in try(local.device_config[each.key].netflow.monitors, []) : monitor.name => {
    description         = try(monitor.description, null)
    record_target_dn    = try(monitor.record, null) != null ? "sys/flow/fr-[${monitor.record}]" : null
    exporter1_target_dn = try(monitor.exporter_1, null) != null ? "sys/flow/fe-[${monitor.exporter_1}]" : null
    exporter2_target_dn = try(monitor.exporter_2, null) != null ? "sys/flow/fe-[${monitor.exporter_2}]" : null
  } } : null

  hardware_profiles = length(try(local.device_config[each.key].netflow.hardware_profiles, [])) > 0 ? { for profile in try(local.device_config[each.key].netflow.hardware_profiles, []) : profile.name => {
    burst_interval_shift = try(profile.burst_interval_shift, null)
    export_interval      = try(profile.export_interval, null)
    ip_packet_id_shift   = try(profile.ip_packet_id_shift, null)
    mtu                  = try(profile.mtu, null)
    source_port          = try(profile.source_port, null)
  } } : null

  class_maps = length(try(local.device_config[each.key].netflow.class_maps, [])) > 0 ? { for cm in try(local.device_config[each.key].netflow.class_maps, []) : cm.name => {
    match_acls = length(try(cm.match_acls, [])) > 0 ? { for acl in try(cm.match_acls, []) : acl => {} } : null
  } } : null

  depends_on = [
    nxos_feature.feature,
  ]
}
