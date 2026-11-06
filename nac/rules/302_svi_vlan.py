from nac_validate import RuleBase, Violation


class Rule(RuleBase):
    id = "302"
    description = "Verify VLAN interface references VLAN definition"
    severity = "HIGH"

    title = "VLAN INTERFACE WITHOUT VLAN DEFINITION"
    affected_items_label = "VLAN interfaces without a VLAN"
    explanation = """\
A VLAN interface (SVI) can only be created for a VLAN that exists on the
device. If the VLAN is not defined under vlan.vlans, the SVI cannot be
applied."""
    recommendation = """\
Define the VLAN on the same device as the VLAN interface:

  nxos:
    devices:
      - name: LEAF1
        configuration:
          vlan:
            vlans:
              - id: 10
          interfaces:
            vlans:
              - id: 10"""

    @classmethod
    def match(cls, inventory):
        violations = []
        for device in (inventory.get("nxos") or {}).get("devices") or []:
            device_name = device.get("name", "")
            config = device.get("configuration") or {}
            vlan_ids = {
                vlan.get("id")
                for vlan in (config.get("vlan") or {}).get("vlans") or []
                if vlan.get("id") is not None
            }
            for svi in (config.get("interfaces") or {}).get("vlans") or []:
                svi_id = svi.get("id")
                if svi_id is None or svi_id in vlan_ids:
                    continue
                violations.append(
                    Violation(
                        message=f"VLAN {svi_id} is not defined in vlan.vlans",
                        path=(
                            f"nxos.devices[name={device_name}].configuration"
                            f".interfaces.vlans[id={svi_id}]"
                        ),
                        details={"device": device_name, "vlan_id": svi_id},
                    )
                )
        return violations
