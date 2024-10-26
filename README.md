# Kubernetes Platform Terragrunt Configuration

This repository contains Terragrunt configurations for deploying and managing a comprehensive Kubernetes platform with essential services and tools.

## 🏗️ Architecture Overview

```mermaid
graph TB
    subgraph Core["Core Platform"]
        Karpenter["Karpenter<br/>Node Management"]
        ExternalDNS["External DNS"]
        CertManager["Cert Manager"]
        ExtSecrets["External Secrets"]
    end

    subgraph Network["Service Mesh & Networking"]
        Istio["Istio"]
        Kong["Kong Gateway"]
        Jaeger["Jaeger"]
    end

    subgraph Obs["Observability"]
        Loki["Loki Stack"]
        Kubecost["Kubecost"]
    end

    subgraph Tools["Platform Tools"]
        ArgoCD["ArgoCD"]
        Atlantis["Atlantis"]
        Airflow["Airflow"]
        Vault["Vault"]
    end

    CertManager --> Kong
    CertManager --> Istio
    ExternalDNS --> Kong
    ExtSecrets --> Vault
    Istio --> Jaeger
    Kong --> Istio
```

## 📁 Repository Structure

```
.
├── common.hcl                # Common Terragrunt configuration
├── terragrunt.hcl           # Root Terragrunt configuration
├── platform_vars.yaml       # Platform-wide variables
├── core-platform/
│   ├── karpenter/
│   ├── external-dns/
│   ├── cert-manager/
│   └── external-secrets/
├── service-mesh/
│   ├── istio/
│   ├── kong-gw/
│   └── jeager/
├── observability/
│   ├── loki-stack/
│   └── kubecost/
└── platform-tools/
    ├── argocd/
    ├── atlantis/
    ├── airflow/
    └── vault/
```

## 🚀 Prerequisites

- Terragrunt >= v0.45.0
- Terraform >= v1.0.0
- AWS CLI configured
- kubectl configured
- Helm v3.x

## 🔑 Configuration

### Common Configuration (common.hcl)
```hcl
locals {
  platform_vars = yamldecode(file("${get_parent_terragrunt_dir()}/platform_vars.yaml"))
  aws_region   = local.platform_vars.aws_region
  cluster_name = local.platform_vars.cluster_name
  environment  = local.platform_vars.environment
}
```

### Platform Variables (platform_vars.yaml)
```yaml
aws_region: us-west-2
cluster_name: platform-eks
environment: production
domain_name: example.com
```

## 📦 Component Deployment Order

1. **Core Platform**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir core-platform
   ```
   - Karpenter
   - External DNS
   - Cert Manager
   - External Secrets

2. **Service Mesh & Networking**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir service-mesh
   ```
   - Istio
   - Kong Gateway
   - Jaeger

3. **Observability**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir observability
   ```
   - Loki Stack
   - Kubecost

4. **Platform Tools**
   ```bash
   terragrunt run-all apply --terragrunt-working-dir platform-tools
   ```
   - ArgoCD
   - Atlantis
   - Airflow
   - Vault

## 🛠️ Usage Examples

### Deploy All Components
```bash
terragrunt run-all apply
```

### Deploy Specific Component
```bash
cd argocd
terragrunt apply
```

### Plan Changes
```bash
terragrunt run-all plan
```

### Destroy Infrastructure
```bash
terragrunt run-all destroy
```

## 🔧 Component Configuration

### ArgoCD
```hcl
# argocd/terragrunt.hcl
include {
  path = find_in_parent_folders()
}

dependencies {
  paths = ["../cert-manager", "../external-secrets"]
}

terraform {
  source = "git::https://github.com/your-org/k8s-platform-modules.git//k8s-platform-argocd"
}

inputs = {
  enabled = true
  domain  = "argocd.example.com"
}
```

Similar configurations exist for other components.

## 🔒 Security Considerations

1. **IRSA (IAM Roles for Service Accounts)**
   - Used for AWS service integration
   - Defined per component
   - Least privilege principle

2. **Network Security**
   - Service mesh encryption
   - Network policies
   - Ingress configuration

3. **Secret Management**
   - External Secrets integration
   - Vault for sensitive data
   - SOPS encryption

## 📊 Monitoring & Observability

- Loki for log aggregation
- Jaeger for distributed tracing
- Kubecost for cost monitoring
- Custom dashboards in Grafana

## 🔄 Maintenance

### Upgrades
```bash
# Update single component
cd component-name
terragrunt apply

# Update all components
terragrunt run-all apply
```

### Backup
```bash
# Backup state
terragrunt state pull > backup.tfstate
```

## 🐛 Troubleshooting

Common issues and solutions:

1. **State Lock Issues**
   ```bash
   terragrunt force-unlock <LOCK_ID>
   ```

2. **Dependency Errors**
   - Check `dependencies` blocks
   - Verify component order
   - Check for circular dependencies

3. **AWS Authentication**
   - Verify AWS credentials
   - Check IAM roles
   - Validate IRSA configuration

## 📝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

For support, please open an issue in the repository.

## 🔄 Version Matrix

| Component | Version | Terraform Provider | Helm Chart |
|-----------|---------|-------------------|------------|
| ArgoCD | v2.7.x | >= 2.0.0 | 5.46.x |
| Istio | 1.19.x | >= 2.0.0 | 1.19.x |
| Vault | 1.15.x | >= 2.0.0 | 0.25.x |
| Kong | 3.5.x | >= 2.0.0 | 2.25.x |