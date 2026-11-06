<!-- BEGIN_TF_DOCS -->
# NX-OS System Configuration Example

This example configures the hostname and system MTU of an NX-OS device using [Network as Code](https://netascode.cisco.com). See the [First Steps](https://netascode.cisco.com/docs/start/nxos/first_steps/) guide for a complete walkthrough and the [system data model](https://netascode.cisco.com/docs/data_models/nxos/system/system/) for all available attributes.

NX-API must be enabled on the device (`feature nxapi`) and credentials provided via the `NXOS_USERNAME` and `NXOS_PASSWORD` environment variables.

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example will create resources. Resources can be destroyed with `terraform destroy`.

#### `system.nac.yaml`

```yaml
nxos:
  devices:
    - name: Switch1
      url: https://1.2.3.4
      configuration:
        system:
          hostname: Switch1
          mtu: 9216
```

#### `main.tf`

```hcl
module "nxos" {
  source  = "netascode/nac-nxos/nxos"
  version = ">= 0.1.0"

  yaml_files = ["system.nac.yaml"]
}
```
<!-- END_TF_DOCS -->