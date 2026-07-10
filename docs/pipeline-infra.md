## Structure du pipeline Infrastructure

L'infrastructure des environnements est provisionnée à l'aide de Terraform via un workflow GitHub Actions dédié, déclenché manuellement.
Le workflow permet de crééer l’infra, mais aussi de modifier l’infra existante, ainsi que de détruire l’infra

Pour lancer un job d'infra :

- Ouvrir le dépôt GitHub et accéder à l'onglet Actions
- Sélectionner le workflow "Trigger infrastructure deployment"
- Cliquer sur "Run workflow"

Choix de l'option

-	plan : Terraform analyse les changements dans le code sans les appliquer
-	apply : Terraform applique les changements dans le code
-	plan-destroy : Terraform analyse la destruction l’appliquer
-	destroy : Terraform détruit l’environnement
 
Choix de l'environnement

- prod / staging

- Cliquer sur "Run workflow"


```mermaid
flowchart TD

    A[Déclenchement manuel<br/>workflow_dispatch]

    A --> B{Choix de l'environnement}

    B -->|staging| C[Environment : staging]
    B -->|prod| D[Environment : prod]

    C --> E{Choix de l'action}
    D --> E

    E -->|plan| F[Terraform Plan]
    E -->|apply| G[Terraform Apply]
    E -->|destroy| H[Terraform Destroy]

    subgraph INIT["Initialisation du job"]
        I[Checkout du dépôt Integration]
        J[Installation de Terraform]
        K[Configuration des identifiants AWS]
        L[Terraform Init<br/>Backend S3 selon environnement]

        I --> J
        J --> K
        K --> L
    end

    F --> I
    G --> I
    H --> I

    L --> M[Chargement du fichier<br/>envs/environment.tfvars]

    M --> N{Action demandée}

    N -->|plan| O[terraform plan<br/>Création de tfplan]
    N -->|apply| P[terraform plan<br/>Création de tfplan]
    N -->|destroy| Q[terraform destroy<br/>auto-approve]

    P --> R[terraform apply<br/>tfplan]

    O --> S[Affichage des changements prévus]
    R --> T[Infrastructure AWS créée ou mise à jour]
    Q --> U[Infrastructure AWS supprimée]

    T --> V[Création du VPC]
    T --> W[Création du cluster EKS]
    T --> X[Création du Node Group]
    T --> Y[Installation des Add-ons EKS]
    T --> Z[Mise à jour du kubeconfig]

    V --> AA[Subnets publics et privés]
    V --> AB[NAT Gateway et routage]

    W --> AC[Control Plane EKS]
    X --> AD[Instances EC2 Worker Nodes]

    Y --> AE[VPC CNI]
    Y --> AF[CoreDNS]
    Y --> AG[kube-proxy]
    
```