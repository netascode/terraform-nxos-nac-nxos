resource "nxos_telemetry" "telemetry" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].telemetry.batch_dme_events, null) != null ||
    try(local.device_config[device.name].telemetry.merge_subscriptions, null) != null ||
    length(try(local.device_config[device.name].telemetry.destination_groups, [])) > 0 ||
    length(try(local.device_config[device.name].telemetry.sensor_groups, [])) > 0 ||
  length(try(local.device_config[device.name].telemetry.subscriptions, [])) > 0 }
  device              = each.key
  batch_dme_events    = try(local.device_config[each.key].telemetry.batch_dme_events, null)
  merge_subscriptions = try(local.device_config[each.key].telemetry.merge_subscriptions, null)
  destination_groups = { for dg in try(local.device_config[each.key].telemetry.destination_groups, []) : dg.id => {
    destinations = { for dest in try(dg.destinations, []) : "${dest.ip_address};${dest.port}" => {
      encoding = try(dest.encoding, null)
      node_id  = try(dest.node_id, null)
      protocol = try(dest.protocol, null)
    } }
  } }
  sensor_groups = { for sg in try(local.device_config[each.key].telemetry.sensor_groups, []) : sg.id => {
    data_source = try(sg.data_source, null)
    sensor_paths = { for sp in try(sg.sensor_paths, []) : sp.path => {
      alias            = try(sp.alias, null)
      depth            = try(sp.depth, null)
      filter_condition = try(sp.filter_condition, null)
      query_condition  = try(sp.query_condition, null)
    } }
  } }
  subscriptions = { for sub in try(local.device_config[each.key].telemetry.subscriptions, []) : sub.id => {
    sensor_group_relationships = { for sg in try(sub.sensor_groups, []) : "sys/tm/sensor-${sg.id}" => {
      sample_interval = try(sg.sample_interval, null)
    } }
    destination_group_relationships = { for dg in try(sub.destination_groups, []) : "sys/tm/dest-${dg}" => {} }
  } }

  depends_on = [
    nxos_feature.feature,
  ]
}
