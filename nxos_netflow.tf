resource "nxos_netflow" "netflow" {
  for_each = { for device in local.devices : device.name => device
    if length(try(local.device_config[device.name].netflow.exporters, [])) > 0 ||
    length(try(local.device_config[device.name].netflow.records, [])) > 0 ||
    length(try(local.device_config[device.name].netflow.monitors, [])) > 0 ||
    length(try(local.device_config[device.name].netflow.hardware_profiles, [])) > 0 ||
  length(try(local.device_config[device.name].netflow.class_maps, [])) > 0 }
  device = each.key

  exporters = { for exporter in try(local.device_config[each.key].netflow.exporters, []) : exporter.name => {
    description      = try(exporter.description, null)
    destination_ip   = try(exporter.destination, null)
    destination_port = try(exporter.transport_udp, null)
    dscp             = try(exporter.dscp, null)
    source_interface = try(exporter.source_interface_type, null) != null ? "${local.intf_prefix_map[try(exporter.source_interface_type)]}${try(exporter.source_interface_id, "")}" : null
    version          = try(exporter.version, null)
    vrf_name         = try(exporter.vrf, null)
  } }

  records = { for record in try(local.device_config[each.key].netflow.records, []) : record.name => {
    description        = try(record.description, null)
    collect_parameters = try(join(",", sort(record.collect_parameters)), null)
    match_parameters   = try(join(",", sort(record.match_parameters)), null)
  } }

  monitors = { for monitor in try(local.device_config[each.key].netflow.monitors, []) : monitor.name => {
    description      = try(monitor.description, null)
    record_target_dn = try(monitor.record, null) != null ? "sys/flow/fr-[${monitor.record}]" : null
    exporter_buckets = { for bucket in try(monitor.exporter_buckets, []) : tostring(bucket.id) => {
      exporter1_target_dn = try(bucket.exporter_1, null) != null ? "sys/flow/fe-[${bucket.exporter_1}]" : null
      exporter2_target_dn = try(bucket.exporter_2, null) != null ? "sys/flow/fe-[${bucket.exporter_2}]" : null
      hash_high           = try(bucket.hash_high, null)
      hash_low            = try(bucket.hash_low, null)
    } }
  } }

  hardware_profiles = { for profile in try(local.device_config[each.key].netflow.hardware_profiles, []) : profile.name => {
    burst_interval_shift = try(profile.burst_interval_shift, null)
    export_interval      = try(profile.export_interval, null)
    ip_packet_id_shift   = try(profile.ip_packet_id_shift, null)
    mtu                  = try(profile.mtu, null)
    source_port          = try(profile.source_port, null)
  } }

  class_maps = { for cm in try(local.device_config[each.key].netflow.class_maps, []) : cm.name => {
    match_acls = { for acl in try(cm.match_acls, []) : acl => {} }
  } }

  depends_on = [
    nxos_feature.feature,
  ]
}
