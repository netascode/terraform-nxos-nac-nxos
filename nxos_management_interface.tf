resource "nxos_management_interface" "management_interface" {
  for_each = { for device in local.devices : device.name => device
  if length(try(local.device_config[device.name].interfaces.management, [])) > 0 }
  device = each.key
  management_interfaces = { for int in try(local.device_config[each.key].interfaces.management, []) : "mgmt${int.id}" => {
    admin_state      = try(int.shutdown, null) == null ? null : (try(int.shutdown) ? "down" : "up")
    description      = try(int.description, null)
    duplex           = try(int.duplex, null)
    mtu              = try(int.mtu, null)
    speed            = try(int.speed, null)
    auto_negotiation = try(int.negotiate_auto, null)
    snmp_trap_state  = try(int.snmp_trap_link_status, null) == null ? null : (try(int.snmp_trap_link_status) ? "enable" : "disable")
    vrf_dn           = try(int.vrf, null) != null ? "sys/inst-${try(int.vrf)}" : null
  } }

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_vrf.vrf,
  ]
}
