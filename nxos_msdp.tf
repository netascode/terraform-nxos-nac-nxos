locals {
  # Per device: VRF name => VRF configuration. The default VRF is built from the
  # top-level `routing.msdp` attributes.
  msdp_vrf_configs = { for device in local.devices : device.name => merge(
    { "default" = try(local.device_config[device.name].routing.msdp, {}) },
    { for vrf in try(local.device_config[device.name].routing.msdp.vrfs, []) : vrf.vrf => vrf },
  ) }
}

resource "nxos_msdp" "msdp" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].routing.msdp, null) != null }
  device = each.key

  vrfs = { for vrf_name, vrf in local.msdp_vrf_configs[each.key] : vrf_name => {
    # The provider only accepts "flush-routes", a null value unsets it
    control                = try(vrf.flush_routes, false) ? "flush-routes" : null
    originator_interface   = try(vrf.originator_id_interface_type, null) != null ? "${local.intf_prefix_map[try(vrf.originator_id_interface_type)]}${try(vrf.originator_id_interface_id, "")}" : null
    reconnect_interval     = try(vrf.reconnect_interval, null)
    source_active_interval = try(vrf.sa_interval, null)

    # ip msdp redistribute {route-map <rm> | prefix-list <pl>}
    redistribution_route_map   = try(vrf.redistribute_route_map, null)
    redistribution_prefix_list = try(vrf.redistribute_prefix_list, null)
    redistribution_source      = try(vrf.redistribute_route_map, null) != null ? "rtmap" : try(vrf.redistribute_prefix_list, null) != null ? "pflist" : null

    group_limits = length(try(vrf.group_limits, [])) > 0 ? { for gl in try(vrf.group_limits, []) : gl.source => {
      maximum_groups = try(gl.limit, null)
    } } : null

    peers = length(try(vrf.peers, [])) > 0 ? { for peer in try(vrf.peers, []) : peer.address => {
      admin_state         = try(peer.shutdown, null) == null ? null : (try(peer.shutdown) ? "disabled" : "enabled")
      remote_as           = try(peer.remote_as, null) != null ? tostring(peer.remote_as) : null
      description         = try(peer.description, null)
      keepalive_interval  = try(peer.keepalive_interval, null)
      keepalive_timeout   = try(peer.keepalive_timeout, null)
      source_active_limit = try(peer.sa_limit, null)
      source_interface    = try(peer.connect_source_interface_type, null) != null ? "${local.intf_prefix_map[try(peer.connect_source_interface_type)]}${try(peer.connect_source_interface_id, "")}" : null

      # The device only applies the type-3 encrypted key
      authentication_key      = try(peer.password, null)
      authentication_type     = try(peer.password, null) != null ? "md5" : null
      authentication_keychain = try(peer.keychain, null)

      mesh_group_name = try(peer.mesh_group, null)

      # ip msdp sa-policy <peer> {<rm> | prefix-list <pl>} {in | out}
      sa_policies = anytrue([for dir in ["in", "out"] : try(peer["sa_policy_${dir}"], null) != null || try(peer["sa_policy_${dir}_prefix_list"], null) != null]) ? { for dir in ["in", "out"] : dir => {
        route_map   = try(peer["sa_policy_${dir}"], null)
        prefix_list = try(peer["sa_policy_${dir}_prefix_list"], null)
      } if try(peer["sa_policy_${dir}"], null) != null || try(peer["sa_policy_${dir}_prefix_list"], null) != null } : null
    } } : null
  } }

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
    nxos_ipv4.ipv4,
    nxos_keychain.keychain,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_route_policy.route_policy,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
