resource "nxos_hardware_telemetry" "hardware_telemetry" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].sflow, null) != null }
  device                           = each.key
  sflow_agent_address              = try(local.device_config[each.key].sflow.agent_address, null)
  sflow_counter_poll_interval      = try(local.device_config[each.key].sflow.counter_poll_interval, null)
  sflow_extended_bgp               = try(local.device_config[each.key].sflow.extended_bgp, null)
  sflow_extended_switch            = try(local.device_config[each.key].sflow.extended_switch, null)
  sflow_max_header_size            = try(local.device_config[each.key].sflow.max_header_size, null)
  sflow_packet_sampling_rate       = try(local.device_config[each.key].sflow.sampling_rate, null)
  sflow_receiver_max_datagram_size = try(local.device_config[each.key].sflow.max_datagram_size, null)
  sflow_receiver_port              = try(local.device_config[each.key].sflow.collector_port, null)
  receivers = try({ for collector in local.device_config[each.key].sflow.collectors :
    "${try(collector.vrf, "default")};${collector.address}" => {
      source_address = try(collector.source_address, null)
    }
  }, null)

  depends_on = [
    nxos_feature.feature,
  ]
}
