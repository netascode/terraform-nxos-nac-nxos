resource "nxos_ospf" "ospf" {
  for_each    = { for device in local.devices : device.name => device if try(contains(local.device_config[device.name].system.features, "ospf"), contains(local.defaults.nxos.configuration.system.features, "ospf"), false) }
  device      = each.key
  admin_state = "enabled"

  depends_on = [
    nxos_feature_ospf.ospf
  ]
}

locals {
  routing_ospf_processes = flatten([
    for device in local.devices : [
      for proc in try(local.device_config[device.name].routing.ospf_processes, []) : {
        key    = format("%s/%s", device.name, proc.name)
        device = device.name
        name   = proc.name
      }
    ]
  ])
}

resource "nxos_ospf_instance" "ospf_instance" {
  for_each = { for v in local.routing_ospf_processes : v.key => v }
  device   = each.value.device
  name     = each.value.name

  depends_on = [
    nxos_ospf.ospf
  ]
}

locals {
  routing_ospf_processes_vrfs = flatten([
    for device in local.devices : [
      for proc in try(local.device_config[device.name].routing.ospf_processes, []) : [
        for vrf in try(proc.vrfs, []) : {
          key                     = format("%s/%s/%s", device.name, proc.name, vrf.vrf)
          device                  = device.name
          proc_key                = format("%s/%s", device.name, proc.name)
          vrf                     = vrf.vrf
          admin_state             = try(vrf.admin_state, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.admin_state, false) ? "enabled" : "disabled"
          bandwidth_reference     = try(vrf.bandwidth_reference, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.bandwidth_reference, null)
          banwidth_reference_unit = try(vrf.banwidth_reference_unit, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.banwidth_reference_unit, null)
          distance                = try(vrf.distance, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.distance, null)
          router_id               = try(vrf.router_id, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.router_id, null)
        }
      ]
    ]
  ])
}

resource "nxos_ospf_vrf" "ospf_vrf" {
  for_each                 = { for v in local.routing_ospf_processes_vrfs : v.key => v }
  device                   = each.value.device
  instance_name            = nxos_ospf_instance.ospf_instance[each.value.proc_key].name
  name                     = each.value.vrf
  admin_state              = each.value.admin_state
  bandwidth_reference      = each.value.bandwidth_reference
  bandwidth_reference_unit = each.value.banwidth_reference_unit
  distance                 = each.value.distance
  router_id                = each.value.router_id
}

locals {
  routing_ospf_processes_vrfs_areas = flatten([
    for device in local.devices : [
      for proc in try(local.device_config[device.name].routing.ospf_processes, []) : [
        for vrf in try(proc.vrfs, []) : [
          for area in try(vrf.areas, []) : {
            key                 = format("%s/%s/%s/%s", device.name, proc.name, vrf.vrf, area.area)
            device              = device.name
            process             = proc.name
            vrf_key             = format("%s/%s/%s", device.name, proc.name, vrf.vrf)
            area                = area.area
            authentication_type = try(area.authentication_type, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.areas.authentication_type, null)
            cost                = try(area.cost, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.areas.cost, null)
            type                = try(area.type, local.defaults.nxos.devices.configuration.routing.ospf_processes.vrfs.areas.type, null)
          }
        ]
      ]
    ]
  ])
}

resource "nxos_ospf_area" "ospf_area" {
  for_each            = { for v in local.routing_ospf_processes_vrfs_areas : v.key => v }
  device              = each.value.device
  instance_name       = each.value.process
  vrf_name            = nxos_ospf_vrf.ospf_vrf[each.value.vrf_key].name
  area_id             = each.value.area
  authentication_type = each.value.authentication_type
  cost                = each.value.cost
  type                = each.value.type
}

locals {
  ospf_interfaces = concat(local.interfaces_ethernets, local.interfaces_loopbacks, local.interfaces_vlans)
}

resource "nxos_ospf_interface" "ospf_interface" {
  for_each              = { for v in local.ospf_interfaces : v.key => v if v.ospf_process_name != null }
  device                = each.value.device
  instance_name         = each.value.ospf_process_name
  vrf_name              = nxos_ospf_vrf.ospf_vrf["${each.value.device}/${each.value.ospf_process_name}/${each.value.vrf}"].name
  interface_id          = "${each.value.type}${each.value.id}"
  advertise_secondaries = each.value.ospf_advertise_secondaries
  area                  = each.value.ospf_area
  bfd                   = each.value.ospf_bfd
  cost                  = each.value.ospf_cost
  dead_interval         = each.value.ospf_dead_interval
  hello_interval        = each.value.ospf_hello_interval
  network_type          = each.value.ospf_network_type
  passive               = each.value.ospf_passive
  priority              = each.value.ospf_priority
}

resource "nxos_ospf_authentication" "ospf_authentication" {
  for_each            = { for v in local.ospf_interfaces : v.key => v if v.ospf_authentication_type == "simple" || v.ospf_authentication_type == "md5" }
  device              = each.value.device
  instance_name       = each.value.ospf_process_name
  vrf_name            = each.value.vrf
  interface_id        = nxos_ospf_interface.ospf_interface[each.key].interface_id
  key                 = each.value.ospf_authentication_key
  key_id              = each.value.ospf_authentication_key_id
  key_secure_mode     = each.value.ospf_authentication_key_secure_mode
  keychain            = each.value.ospf_authentication_keychain
  md5_key             = each.value.ospf_authentication_md5_key
  md5_key_secure_mode = each.value.ospf_authentication_md5_key_secure_mode
  type                = each.value.ospf_authentication_type
}
