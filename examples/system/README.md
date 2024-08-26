<!-- BEGIN_TF_DOCS -->
# NX-OS System Configuration Example

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