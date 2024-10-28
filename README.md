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
├── core-platform/           # Core platform components
│   ├── cert-manager         # Certificate management
│   ├── external-dns         # DNS automation
│   ├── external-secrets     # Secrets management
│   └── karpenter            # Kubernetes node provisioning
├── service-mesh/            # Service mesh components
│   ├── istio                # Service mesh control plane
│   ├── jeager               # Distributed tracing
│   └── kong-gw              # API gateway
├── observability/           # Monitoring and observability
│   ├── kubecost             # Cost monitoring
│   └── loki-stack           # Log aggregation
├── platform-tools/          # Platform utilities
│   ├── airflow              # Workflow automation
│   ├── argocd               # GitOps deployment
│   ├── atlantis             # Terraform automation
│   └── vault                # Secrets management
└── ci-cd-templates/         # Reusable CI/CD workflows
```

## 🚀 Prerequisites

- Terragrunt >= v0.60.0
- Terraform >= v1.5.0
- AWS CLI configured
- kubectl configured
- Helm v3.x

## 🔑 Configuration

### Common Configuration (common.hcl)
```hcl
locals {
  platform_vars     = yamldecode(file(("platform_vars.yaml")))
  eks_cluster_name  = local.platform_vars.common.eks_cluster_name
  environment       = get_env("ENV", "dev")
  aws_region        = local.platform_vars.common.aws_region
  tags              = local.platform_vars.common.common_tags 
}
```

### Platform Variables (platform_vars.yaml)
```yaml
aws_region:       "us-east-2"
eks_cluster_name: "dev-eks-cluster"
environment:      "dev"
domain_name:      "cloudon.work"
common_tags:
    Environment:  "dev"
    Owner:        "cloudon"
    ManagedBy:    "Terragrunt"
    Team:         "platform"
    ClusterName:  "dev-eks-cluster"
...
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
include "common" {
  path = find_in_parent_folders("common.hcl")
}

terraform {
  source = "git::https://git@github.com/cloudon-one/k8s-platform-modules.git//k8s-platform-argocd?ref=dev"
}

locals {
  platform_vars = yamldecode(file(find_in_parent_folders("platform_vars.yaml")))
  tool          = basename(get_terragrunt_dir())
}

inputs = merge(
  local.platform_vars.Platform.Tools[local.tool].inputs,
  {
    environment         = local.platform_vars.common.environment
    eks_cluster_name    = local.platform_vars.common.eks_cluster_name
  }
)
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

## 🔧 CI/CD Integration
The repository includes reusable CI/CD templates for:

- Docker image building (ci-cd-templates/reusable-docker-build.yaml)
- Terragrunt operations (ci-cd-templates/terragrunt-plan-apply.yaml)
- Environment variable management (ci-cd-templates/get-env-func.yaml)

Additionally, test coverage action templates are available for multiple languages:

- Java
- .NET
- Node.js
- Python

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
| ArgoCD    | v2.7.x  | >= 2.0.0 | 5.46.x |
| Istio     | 1.19.x  | >= 2.0.0 | 1.19.x |
| Vault     | 1.15.x  | >= 2.0.0 | 0.25.x |
| Kong      | 3.5.x   | >= 2.0.0 | 2.25.x |