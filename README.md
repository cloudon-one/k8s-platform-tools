## Architecture

### High-Level Platform Architecture

The platform consists of multiple layers working together to provide a complete Kubernetes infrastructure:

```mermaid
flowchart TD
    subgraph "Infrastructure Layer"
        EKS[EKS Cluster]
        VPC[VPC]
        IAM[IAM Roles/Policies]
    end

    subgraph "Service Mesh & Networking"
        ISTIO[Istio Service Mesh]
        KONG[Kong Ingress]
        DNS[External DNS]
    end

    subgraph "Security & Certificates"
        CERT[Cert Manager]
        SEC[External Secrets]
        style CERT fill:#f9f,stroke:#333
        style SEC fill:#f9f,stroke:#333
    end

    subgraph "Observability"
        LOKI[Loki Stack]
        JAEGER[Jaeger]
        KUBECOST[Kubecost]
        style LOKI fill:#bbf,stroke:#333
        style JAEGER fill:#bbf,stroke:#333
        style KUBECOST fill:#bbf,stroke:#333
    end

    subgraph "Platform Tools"
        ARGO[ArgoCD]
        AIRFLOW[Airflow]
        style ARGO fill:#bfb,stroke:#333
        style AIRFLOW fill:#bfb,stroke:#333
    end

    %% Connections
    EKS --> ISTIO
    EKS --> CERT
    ISTIO --> KONG
    KONG --> DNS
    CERT --> KONG
    SEC --> ARGO
    SEC --> AIRFLOW
    ISTIO --> JAEGER
    LOKI --> KUBECOST
```

This diagram shows:
- Infrastructure foundation (EKS, VPC, IAM)
- Service mesh and networking components
- Security and certificate management
- Observability stack
- Platform tools integration

### Deployment Flow

The following sequence diagram shows the deployment order and dependencies:

```mermaid
sequenceDiagram
    participant TG as Terragrunt
    participant AWS as AWS Services
    participant K8S as Kubernetes
    participant TOOLS as Platform Tools

    TG->>AWS: Deploy IAM Roles
    TG->>K8S: Deploy Cert Manager
    TG->>K8S: Deploy External Secrets
    TG->>K8S: Deploy Istio
    K8S->>TOOLS: Initialize Service Mesh
    TG->>K8S: Deploy Kong Ingress
    TG->>K8S: Deploy Monitoring Stack
    TG->>K8S: Deploy ArgoCD
    TOOLS->>K8S: Start GitOps Deployments
    K8S->>AWS: Configure External DNS
```

Key deployment stages:
1. Infrastructure prerequisites
2. Security components
3. Networking layer
4. Observability tools
5. Platform services

### Network Architecture

The network architecture shows how traffic flows through the platform:

```mermaid
flowchart LR
    subgraph Internet
        Client
    end

    subgraph "AWS VPC"
        subgraph "Public Subnets"
            ALB[Application Load Balancer]
        end

        subgraph "Private Subnets"
            subgraph "Service Mesh"
                INGRESS[Kong Ingress]
                MESH[Istio Proxy]
            end

            subgraph "Applications"
                APP1[Service 1]
                APP2[Service 2]
            end
        end
    end

    Client --> ALB
    ALB --> INGRESS
    INGRESS --> MESH
    MESH --> APP1
    MESH --> APP2
```

Features:
- Load balancer in public subnet
- Service mesh in private subnet
- Ingress controller integration
- Secure application access

### Observability Architecture

The observability stack provides comprehensive monitoring and logging:

```mermaid
flowchart TD
    subgraph "Log Collection"
        APP[Applications]
        PROM[Prometheus]
        LOKI_A[Loki]
    end

    subgraph "Processing"
        ALERT[AlertManager]
        JAEGER_P[Jaeger]
    end

    subgraph "Visualization"
        GRAF[Grafana]
        KIALI[Kiali]
        COST[Kubecost UI]
    end

    APP --> PROM
    APP --> LOKI_A
    APP --> JAEGER_P
    PROM --> ALERT
    PROM --> GRAF
    LOKI_A --> GRAF
    JAEGER_P --> KIALI
    PROM --> COST
```

Components:
- Metrics collection (Prometheus)
- Log aggregation (Loki)
- Tracing (Jaeger)
- Visualization (Grafana, Kiali)
- Cost monitoring (Kubecost)

### Security Architecture

The security architecture ensures comprehensive protection:

```mermaid
flowchart TD
    subgraph "Authentication"
        OIDC[OIDC Provider]
        OAUTH[OAuth2 Proxy]
    end

    subgraph "Authorization"
        RBAC[Kubernetes RBAC]
        POLICY[Network Policies]
    end

    subgraph "Secrets Management"
        EXTERN[External Secrets]
        CERT_M[Cert Manager]
        VAULT[HashiCorp Vault]
    end

    OIDC --> OAUTH
    OAUTH --> RBAC
    RBAC --> POLICY
    EXTERN --> VAULT
    CERT_M --> VAULT
```

Security layers:
- Authentication with OIDC
- Kubernetes RBAC
- Network policies
- Secrets management
- Certificate automation

## Component Relationships

The platform components are designed to work together:

1. **Service Mesh Integration**
   - Istio provides the service mesh foundation
   - Kong Ingress handles external traffic
   - External DNS manages DNS records

2. **Security Integration**
   - Cert Manager works with Let's Encrypt
   - External Secrets integrates with AWS Secrets Manager
   - OIDC provides authentication

3. **Observability Integration**
   - Prometheus collects metrics
   - Loki aggregates logs
   - Jaeger traces requests
   - Grafana visualizes everything

4. **Platform Tools Integration**
   - ArgoCD manages deployments
   - Airflow orchestrates workflows
   - Karpenter handles scaling