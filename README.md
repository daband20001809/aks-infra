# AKS Lab – Terraform (modular)

```
.
├── main.tf              # resource group + module calls
├── providers.tf
├── variables.tf
├── outputs.tf
├── terraforms.tfvars
└── modules/
    ├── network/         # VNet, snet-aks, snet-appgw
    ├── monitoring/      # Log Analytics workspace
    ├── acr/             # Container Registry
    ├── appgw/           # WAF policy, Public IP, App Gateway WAF_v2, diagnostic setting
    ├── aks/             # AKS (Azure CNI + Calico, AGIC, Container Insights) + role assignments
    └── dns/             # DNS zone + A record (enabled by use_azure_dns)
```

## Module dependencies

```
network ──► appgw ──► aks ◄── acr
   │          ▲        ▲
   └──────────┼────────┘
monitoring ───┴────────┘
appgw (public IP) ──► dns
```

## Usage

```bash
terraform init
terraform plan  -var-file=terraforms.tfvars
terraform apply -var-file=terraforms.tfvars
```

> Terraform only auto-loads `terraform.tfvars` / `*.auto.tfvars`. Either keep
> passing `-var-file=terraforms.tfvars` or rename the file to `terraform.tfvars`.
