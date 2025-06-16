locals {
  service_hypershield = flatten([
    for device in local.devices : [
      {
        key                = format("%s", device.name)
        device             = device.name
        source_interface   = try(local.device_config[device.name].hypershield.source_interface, null)
        https_proxy_port   = try(local.device_config[device.name].hypershield.https_proxy_port, null)
        https_proxy_server = try(local.device_config[device.name].hypershield.https_proxy_server, null)
        admin_state        = try(local.device_config[device.name].hypershield.admin_state == "in-service" || local.device_config[device.name].hypershield.admin_state == null ? "in-service" : local.device_config[device.name].hypershield.admin_state, null)
        vrfs               = try(local.device_config[device.name].hypershield.vrfs, [])
    }]
  ])

}


resource "nxos_rest" "service_system_hypershield_sas_sas" {
  for_each = { for v in local.service_hypershield : v.key => v }

  dn         = "sys/sas"
  class_name = "sasSas"

}

resource "nxos_rest" "service_system_hypershield_sas_svc" {
  for_each = { for v in local.service_hypershield : v.key => v }

  dn         = "sys/sas/svc"
  class_name = "sasSvc"

  depends_on = [nxos_rest.service_system_hypershield_sas_sas]

}

resource "nxos_rest" "service_system_hypershield_sas_svc_instance" {
  for_each = { for v in local.service_hypershield : v.key => v }

  dn         = "sys/sas/svc/svcinst-hypershield"
  class_name = "sasSvcInstance"

  content = {
    cpSrcInterface = each.value.source_interface
    name           = "hypershield" # This is the sevice name and must be set to hypershield - This line refers to the "service system hypershield" command
  }

  depends_on = [nxos_rest.service_system_hypershield_sas_svc]
}

resource "nxos_rest" "service_system_hypershield_sas_svc_scontroller" {
  for_each = { for v in local.service_hypershield : v.key => v }

  dn         = "sys/sas/svc/svcinst-hypershield/scontroller"
  class_name = "sasSController"
  content = {
    httpsProxyPort = each.value.https_proxy_port
    httpsProxySvr  = each.value.https_proxy_server
  }

  depends_on = [nxos_rest.service_system_hypershield_sas_svc_instance]

}

resource "nxos_rest" "service_system_hypershield_sas_svc_fw_policy" {
  for_each = { for v in local.service_hypershield : v.key => v }

  dn         = "sys/sas/svc/svcinst-hypershield/fwpolicy"
  class_name = "sasFwSvcPolicy"
  content = {
    adminState = each.value.admin_state
  }

  lifecycle {
    precondition {
      condition     = each.value.admin_state == "in-service" || each.value.admin_state == null
      error_message = "Allowed values: `in-service` or null"
    }
  }


  depends_on = [nxos_rest.service_system_hypershield_sas_svc_instance]

}

locals {
  service_hypershield_vrfs = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].hypershield.vrfs, []) : {
        key      = format("%s_vrf_%s", device.name, vrf.name)
        device   = device.name
        vrf_name = vrf.name
        affinity = try(contains([0, 1, 2, 3, 4], vrf.affinity) ? vrf.affinity : (vrf.affinity == "dynamic" || vrf.affinity == null ? "0" : vrf.affinity), "0")
      }
    ]
  ])
}


resource "nxos_rest" "service_system_hypershield_sas_svc_fw_policy_ip_vrf" {
  for_each = { for v in local.service_hypershield_vrfs : v.key => v }

  dn         = "sys/sas/svc/svcinst-hypershield/fwpolicy/ipvrf/dom-[${each.value.vrf_name}]"
  class_name = "sasDom"
  content = {
    name     = each.value.vrf_name
    affinity = each.value.affinity
  }

  lifecycle {
    precondition {
      condition     = contains(["0", "1", "2", "3", "4", null, "dynamic"], each.value.affinity)
      error_message = "Allowed values: 1, 2, 3, 4. For dynamic affinity use `dynamic`, 0, or null"
    }
  }

  depends_on = [nxos_rest.service_system_hypershield_sas_svc_fw_policy]

}