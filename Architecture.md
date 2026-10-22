# AKS Lab – Azure Infrastructure

Azure infrastructure for the AKS lab (frontend/backend, Ingress, WAF, custom domain).

---

## 1. Infrastructure Diagram

```mermaid
%%{init: {"theme": "base", "themeVariables": {"fontFamily": "Segoe UI, Arial", "fontSize": "15px", "lineColor": "#334155", "primaryTextColor": "#0f172a"}}}%%
flowchart TB
    user([👤 Internet User])

    subgraph SUB["☁️ Azure Subscription"]
        direction TB

        subgraph RG["Resource Group: rg-aks-lab"]
            direction TB

            dns["Azure DNS Zone<br/>example.com<br/>A record: app → PIP"]
            pip["Public IP<br/>pip-appgw (Standard, Static)"]
            waf["WAF Policy<br/>OWASP 3.2 – Prevention"]
            acr[("Azure Container Registry<br/>acrakslab")]

            subgraph VNET["VNet: vnet-aks-lab — 10.0.0.0/16"]
                direction LR

                subgraph SNAGW["Subnet: snet-appgw — 10.0.1.0/24"]
                    nsgagw{{"NSG: nsg-appgw"}}
                    agw["Application Gateway<br/>WAF_v2"]
                end

                subgraph SNAKS["Subnet: snet-aks — 10.0.4.0/22"]
                    nsgaks{{"NSG: nsg-aks"}}
                    aks["AKS Cluster: aks-lab<br/>System node pool (VMSS)"]
                    ilb["Internal Load Balancer<br/>(Ingress IP)"]
                end
            end
        end

        subgraph MCRG["Node Resource Group: MC_rg-aks-lab_aks-lab_region"]
            direction LR
            vmss["VM Scale Set<br/>AKS nodes"]
            lb["Load Balancer<br/>(egress)"]
            disks["Managed Disks"]
        end
    end

    user -- "HTTPS app.example.com" --> dns
    dns -.-> pip
    pip --> agw
    waf -. "attached to" .-> agw
    agw -- "backend pool → ILB IP" --> ilb
    ilb --> aks
    aks -- "AcrPull (managed identity)" --> acr
    aks -. "AKS-managed resources" .-> MCRG

    %% ---------- Styles ----------
    classDef ext      fill:#f1f5f9,stroke:#475569,stroke-width:2px,color:#0f172a
    classDef network  fill:#dbeafe,stroke:#1d4ed8,stroke-width:2px,color:#0f172a
    classDef security fill:#fee2e2,stroke:#b91c1c,stroke-width:2px,color:#0f172a
    classDef compute  fill:#dcfce7,stroke:#15803d,stroke-width:2px,color:#0f172a
    classDef storage  fill:#fef3c7,stroke:#b45309,stroke-width:2px,color:#0f172a

    class user ext
    class dns,pip,ilb,lb network
    class agw,waf,nsgagw,nsgaks security
    class aks,vmss compute
    class acr,disks storage

    style SUB   fill:#ffffff,stroke:#0f172a,stroke-width:2px,color:#0f172a
    style RG    fill:#f8fafc,stroke:#64748b,stroke-width:2px,stroke-dasharray:6 4,color:#0f172a
    style VNET  fill:#eff6ff,stroke:#2563eb,stroke-width:2px,color:#1e3a8a
    style SNAGW fill:#fff5f5,stroke:#dc2626,stroke-width:1.5px,color:#7f1d1d
    style SNAKS fill:#f0fdf4,stroke:#16a34a,stroke-width:1.5px,color:#14532d
    style MCRG  fill:#f8fafc,stroke:#94a3b8,stroke-width:1.5px,stroke-dasharray:4 4,color:#334155

    linkStyle default stroke:#334155,stroke-width:2px
```

**Legend:** 🟦 Network · 🟥 Security (WAF, NSG) · 🟩 Compute · 🟨 Storage/Registry

> Mermaid diagrams render natively in GitHub and Azure DevOps READMEs.

### Plain-text version

```
Internet ──HTTPS──► Azure DNS (app.example.com) ──► Public IP
                                                      │
┌──────────── Resource Group: rg-aks-lab ─────────────┼──────────────────┐
│                                                     ▼                  │
│  ┌──────── VNet: vnet-aks-lab (10.0.0.0/16) ─────────────────────────┐ │
│  │                                                                   │ │
│  │  snet-appgw (10.0.1.0/24)  [NSG]                                  │ │
│  │   └─ Application Gateway WAF_v2  ◄── WAF Policy (OWASP)           │ │
│  │              │                                                    │ │
│  │              ▼                                                    │ │
│  │  snet-aks (10.0.4.0/22)    [NSG]                                  │ │
│  │   ├─ Internal Load Balancer (Ingress IP)                          │ │
│  │   └─ AKS cluster – system node pool (VMSS)                        │ │
│  └───────────────────────────────┬───────────────────────────────────┘ │
│                                  │ AcrPull                             │
│  Azure Container Registry ◄──────┘                                     │
└────────────────────────────────────────────────────────────────────────┘

MC_rg-aks-lab_aks-lab_<region>  (created by AKS): VMSS, Load Balancer, Disks
```

---

## 2. Resources

| Resource | Name (example) | Notes |
|---|---|---|
| Resource Group | `rg-aks-lab` | Holds all lab resources |
| Virtual Network | `vnet-aks-lab` | `10.0.0.0/16` |
| App Gateway subnet | `snet-appgw` | `10.0.1.0/24`, dedicated to Application Gateway |
| AKS subnet | `snet-aks` | `10.0.4.0/22`, hosts nodes and the internal LB |
| NSG | `nsg-appgw`, `nsg-aks` | `nsg-appgw` must allow ports 65200–65535 from `GatewayManager` |
| Public IP | `pip-appgw` | Standard SKU, static |
| Application Gateway | `agw-aks-lab` | WAF_v2 SKU, terminates TLS for the custom domain |
| WAF Policy | `waf-aks-lab` | OWASP CRS, Prevention mode |
| AKS | `aks-lab` | System node pool on VMSS, Azure CNI networking |
| Internal Load Balancer | (created by the Ingress Service) | Private IP in `snet-aks`, used as the App Gateway backend |
| Container Registry | `acrakslab` | AKS is granted the `AcrPull` role |
| DNS Zone | `example.com` | A record `app` points to `pip-appgw` |
| Node Resource Group | `MC_rg-aks-lab_aks-lab_<region>` | Created and managed by AKS (VMSS, LB, disks) |

---

## 3. Traffic Flow

1. The user browses to `https://app.example.com`; Azure DNS resolves it to `pip-appgw`.
2. Application Gateway terminates TLS and the WAF Policy inspects the request.
3. Allowed requests are forwarded to the **Internal Load Balancer** (Ingress IP) in `snet-aks`.
4. The Ingress Controller on AKS routes the request to the frontend or backend.

---

## 4. Cost Notes

- Application Gateway WAF_v2 is billed hourly even with no traffic — **delete or stop it** when the lab isn't in use.
- Use `az aks stop` to pause the cluster.
