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
    nxos_bgp_route_control.bgp_route_control,
    nxos_bgp_graceful_restart.bgp_graceful_restart,
    nxos_bgp_peer_template_address_family.bgp_peer_template_address_family,
    nxos_bgp_peer_address_family.bgpPeerAf,
    nxos_evpn_vni_route_target.evpn_vni_route_target,
    nxos_hmm_interface.hmm_interface,
    nxos_feature.feature,
    nxos_physical_interface.physical_interface,
    nxos_ipv4_interface_address.ethernet_ipv4_interface_address,
    nxos_ipv4_interface_address.loopback_ipv4_interface_address,
    nxos_ipv4_interface_address.loopback_ipv4_secondary_interface_address,
    nxos_ipv4_interface_address.svi_ipv4_interface_address,
    nxos_ipv4_interface_address.svi_ipv4_secondary_interface_address,
    nxos_nve_vni_ingress_replication.nve_vni_ingress_replication,
    nxos_ospf.ospf,
    nxos_pim.pim,
    nxos_system.system,
    nxos_bridge_domain.bridge_domain,
    nxos_vrf_route_target.vrf_route_target,
    nxos_ipv4_vrf.ipv4_vrf,
    nxos_ipv4_vrf.ipv4_vrf_default,
    nxos_port_channel_interface.port_channel_interface,
    nxos_icmpv4.icmpv4
  ]
}
