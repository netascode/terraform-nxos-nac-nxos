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
    nxos_feature_bfd.bfd,
    nxos_feature_bgp.bgp,
    nxos_feature_dhcp.dhcp,
    nxos_feature_evpn.evpn,
    nxos_feature_hmm.fabric_forwarding,
    nxos_feature_hsrp.hsrp,
    nxos_feature_interface_vlan.interface_vlan,
    nxos_feature_isis.isis,
    nxos_feature_lacp.lacp,
    nxos_feature_lldp.lldp,
    nxos_feature_macsec.macsec,
    nxos_feature_netflow.netflow,
    nxos_feature_nv_overlay.nv_overlay,
    nxos_feature_ospf.ospf,
    nxos_feature_ospfv3.ospfv3,
    nxos_feature_pim.pim,
    nxos_feature_ptp.ptp,
    nxos_feature_pvlan.pvlan,
    nxos_feature_ssh.ssh,
    nxos_feature_tacacs.tacacs,
    nxos_feature_telnet.telnet,
    nxos_feature_udld.udld,
    nxos_feature_vn_segment.vn_segment,
    nxos_feature_vpc.vpc,
    nxos_ipv4_interface_address.ethernet_ipv4_interface_address,
    nxos_ipv4_interface_address.loopback_ipv4_interface_address,
    nxos_ipv4_interface_address.loopback_ipv4_secondary_interface_address,
    nxos_ipv4_interface_address.svi_ipv4_interface_address,
    nxos_ipv4_interface_address.svi_ipv4_secondary_interface_address,
    nxos_nve_vni_ingress_replication.nve_vni_ingress_replication,
    nxos_ospf_area.ospf_area,
    nxos_ospf_authentication.ospf_authentication,
    nxos_pim_static_rp_group_list.pim_static_rp_group_list,
    nxos_pim_anycast_rp_peer.pim_anycast_rp_peer,
    nxos_pim_interface.pim_interface,
    nxos_system.system,
    nxos_ethernet.ethernet,
    nxos_bridge_domain.bridge_domain,
    nxos_vrf_route_target.vrf_route_target,
    nxos_ipv4_vrf.ipv4_vrf,
    nxos_ipv4_vrf.ipv4_vrf_default,
    nxos_vpc_domain.vpc_domain,
    nxos_vpc_keepalive.vpc_keepalive,
    nxos_vpc_peerlink.vpc_peerlink,
    nxos_vpc_interface.vpc_interface
  ]
}
