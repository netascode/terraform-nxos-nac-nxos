locals {
  nxos                    = try(local.model.nxos, {})
  global                  = try(local.nxos.global, [])
  devices                 = try(local.nxos.devices, [])
  device_groups           = try(local.nxos.device_groups, [])
  interface_groups        = try(local.nxos.interface_groups, [])
  configuration_templates = try(local.nxos.configuration_templates, [])

  device_variables = { for device in local.devices :
    device.name => merge(concat(
      [try(local.global.variables, {})],
      [for dg in local.device_groups : try(dg.variables, {}) if contains(try(device.device_groups, []), dg.name)],
      [for dg in local.device_groups : try(dg.variables, {}) if contains(try(dg.devices, []), device.name)],
      [try(device.variables, {})]
    )...)
  }

  device_group_variables = { for dg in local.device_groups :
    dg.name => try(dg.variables, {})
  }

  device_config_templates_raw_config = { for device in local.devices :
    device.name => {
      for dg in local.device_groups : dg.name => [
        for t in try(dg.configuration_templates, []) :
        yamlencode(try([for ct in local.configuration_templates : try(ct.configuration, {}) if ct.name == t][0], {}))
      ]
      if contains(try(device.device_groups, []), dg.name) || contains(try(dg.devices, []), device.name)
    }
  }

  device_config_templates_config = { for device, groups in local.device_config_templates_raw_config :
    device => provider::utils::yaml_merge([
      for group_name, group_configs in groups : provider::utils::yaml_merge(
        [for config in group_configs : templatestring(config, merge(local.device_variables[device], local.device_group_variables[group_name]))]
      )
    ])
  }

  devices_raw_config = { for device in local.devices :
    device.name => try(provider::utils::yaml_merge(concat(
      [yamlencode(try(local.global.configuration, {}))],
      [for dg in local.device_groups : yamlencode(try(dg.configuration, {})) if contains(try(device.device_groups, []), dg.name)],
      [for dg in local.device_groups : yamlencode(try(dg.configuration, {})) if contains(try(dg.devices, []), device.name)],
      [local.device_config_templates_config[device.name]],
      [yamlencode(try(device.configuration, {}))]
    )), "")
  }

  device_config = { for device, config in local.devices_raw_config :
    device => yamldecode(templatestring(config, local.device_variables[device]))
  }

  interface_groups_raw_config = {
    for device in local.devices : device.name => {
      for ig in local.interface_groups : ig.name => yamlencode(try(ig.configuration, {}))
    }
  }

  interface_groups_config = {
    for device in local.devices : device.name => [
      for ig in local.interface_groups : {
        name          = ig.name
        configuration = yamldecode(templatestring(local.interface_groups_raw_config[device.name][ig.name], local.device_variables[device.name]))
      }
    ]
  }

  provider_devices = [for device in local.devices : {
    name    = device.name
    url     = device.url
    managed = try(device.managed, local.defaults.nxos.devices.managed, true)
  }]
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
    nxos_ipv4_vrf.ipv4_vrf_default
  ]
}
