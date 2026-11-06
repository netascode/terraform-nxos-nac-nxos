*** Settings ***
Documentation   Verify Bridge Domain Configuration
Suite Setup     Login NXOS
Default Tags    nxos   config   bridge_domain
Resource        ../nxos_common.resource

*** Test Cases ***
{% for device in nxos.devices | default([]) %}
{% if device.configuration.vlan.vlans is defined or device.configuration.vlan.configurations is defined %}

Get Config {{ device.name }}
    ${r}=   NXOS Get Subtree   NXOS_{{ device.name }}   /api/mo/sys/bd.json   l2BD,l2VlanConfig
    Set Suite Variable   $r   ${r}

{% if device.configuration.system.interface_vlan_autostate is defined %}
Verify SVI Autostate Device {{ device.name }}
    ${bd}=   Set Variable   imdata[0].bdEntity.attributes
    Should Be Equal Value Json String   ${r}   ${bd}.sysDefaultSVIAutostate   {{ "enable" if device.configuration.system.interface_vlan_autostate else "disable" }}

{% endif %}
{% for vlan in device.configuration.vlan.vlans | default([]) %}
Verify Bridge Domain {{ vlan.id }} Device {{ device.name }}
    ${bd}=   Set Variable   imdata[0].bdEntity.children[?l2BD.attributes.fabEncap=='vlan-{{ vlan.id }}'] | [0].l2BD.attributes
    Should Be Equal Value Json String   ${r}   ${bd}.fabEncap   vlan-{{ vlan.id }}
    Should Be Equal Value Json String   ${r}   ${bd}.name   {{ vlan.name | default() }}
    Should Be Equal Value Json String   ${r}   ${bd}.accEncap   {{ "vxlan-" ~ (vlan.vn_segment | default()) if vlan.vn_segment is defined else "" }}
    {% set val = vlan.state_active | default() %}
    Should Be Equal Value Json String   ${r}   ${bd}.adminSt   {{ "active" if val is true else ("suspend" if val is false else "") }}
    Should Be Equal Value Json String   ${r}   ${bd}.bridgeMode   {{ vlan.bridge_mode | default() }}
    Should Be Equal Value Json String   ${r}   ${bd}.ctrl   {{ (([("policy-enforced" if vlan.policy_enforce_vlan | default(false) else ""), ("untagged" if vlan.untagged | default(false) else "")] | reject("equalto", "") | sort | join(",")) if (vlan.policy_enforce_vlan is defined or vlan.untagged is defined) else "") }}
    Should Be Equal Value Json Bool   ${r}   ${bd}.longName   {{ vlan.long_name | default() }}
    Should Be Equal Value Json Bool   ${r}   ${bd}.macPacketClassify   {{ vlan.mac_packet_classify | default() }}
    Should Be Equal Value Json String   ${r}   ${bd}.mode   {{ vlan.mode | default() | replace("ce", "CE") | replace("fabricpath", "FabricPath") }}
    Should Be Equal Value Json String   ${r}   ${bd}.vrfName   {{ vlan.vrf | default() }}
    Should Be Equal Value Json Bool   ${r}   ${bd}.xConnect   {{ vlan.cross_connect | default() }}
    Should Be Equal Value Json Bool   ${r}   ${bd}.isolate   {{ vlan.isolate | default() }}

{% endfor %}
{% for config in device.configuration.vlan.configurations | default([]) %}
Verify VLAN Configuration {{ config.id }} Device {{ device.name }}
    ${vc}=   Set Variable   imdata[0].bdEntity.children[?l2VlanConfig.attributes.accEncap=='vlan-{{ config.id }}'] | [0].l2VlanConfig.attributes
    Should Be Equal Value Json String   ${r}   ${vc}.accEncap   vlan-{{ config.id }}
    Should Be Equal Value Json Bool   ${r}   ${vc}.vlanMacLearn   {{ config.mac_learn | default() }}

{% endfor %}
{% endif %}
{% endfor %}
