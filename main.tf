module "model" {
  source = "./modules/model"

  yaml_directories          = var.yaml_directories
  yaml_files                = var.yaml_files
  model                     = var.model
  managed_device_groups     = var.managed_device_groups
  managed_devices           = var.managed_devices
  write_default_values_file = var.write_default_values_file
  write_model_file          = var.write_model_file
}

locals {
  model    = module.model.model
  defaults = module.model.default_values
  nxos     = try(local.model.nxos, {})
  devices  = try(local.nxos.devices, [])
  device_config = { for device in try(local.nxos.devices, []) :
    device.name => try(device.configuration, {})
  }
  provider_devices = module.model.devices
}

provider "nxos" {
  devices = local.provider_devices
}

resource "nxos_save_config" "save_config" {
  for_each = { for device in local.devices : device.name => device if var.save_config }
  device   = each.key
  depends_on = [
    nxos_access_list.access_list,
    nxos_bgp.bgp,
    nxos_evpn.evpn,
    nxos_hmm.hmm,
    nxos_feature.feature,
    nxos_physical_interface.physical_interface,
    nxos_nvo.nvo,
    nxos_ospf.ospf,
    nxos_ospfv3.ospfv3,
    nxos_pim.pim,
    nxos_route_policy.route_policy,
    nxos_system.system,
    nxos_bridge_domain.bridge_domain,
    nxos_vrf.vrf,
    nxos_port_channel_interface.port_channel_interface,
    nxos_icmpv4.icmpv4,
    nxos_subinterface.subinterface,
    nxos_ipv4.ipv4,
    nxos_ipv6.ipv6,
    nxos_hsrp.hsrp,
    nxos_isis.isis,
    nxos_keychain.keychain,
    nxos_user_management.user_management,
    nxos_spanning_tree.spanning_tree,
    nxos_vpc.vpc,
    nxos_default_qos.default_qos,
    nxos_dhcp.dhcp,
    nxos_logging.logging,
    nxos_ntp.ntp,
    nxos_queuing_qos.queuing_qos
  ]
}
