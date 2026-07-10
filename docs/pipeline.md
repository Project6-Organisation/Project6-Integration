## Structure du pipeline CI/CD

Le pipeline automatise la compilation, les tests, l’analyse de qualité, la construction et l’analyse de sécurité des images Docker, puis leur déploiement sur les environnements AWS EKS de staging et de production. Les résultats des déploiements alimentent également les métriques DORA exposées dans Grafana.

flowchart TD

    A[Push ou Pull Request] --> B[Déclenchement GitHub Actions]

    B --> C{Branche ou événement}

    C -->|Feature branch| D[Pipeline CI]
    C -->|develop| E[Pipeline CI + Déploiement Staging]
    C -->|main| F[Pipeline CI + Release + Déploiement Production]

    subgraph CI["Intégration continue"]
        D1[Build Back-End<br/>Gradle]
        D2[Tests Back-End<br/>JUnit]
        D3[Analyse Back-End<br/>SonarCloud]
        D4[Build Front-End<br/>Angular]
        D5[Tests Front-End<br/>Karma / ChromeHeadless]
        D6[Contrôle du statut global]

        D1 --> D2
        D2 --> D3
        D4 --> D5
        D3 --> D6
        D5 --> D6
    end

    D --> D1
    E --> D1
    F --> D1

    D6 --> G{Pipeline valide ?}

    G -->|Non| H[Arrêt du pipeline]
    G -->|Oui - develop| I[Build des images Docker]
    G -->|Oui - main| J[Semantic Release]

    J --> K[Création du tag de version]
    K --> I

    I --> L[Scan de sécurité Trivy]
    L --> M{Vulnérabilités bloquantes ?}

    M -->|Oui| H
    M -->|Non| N[Publication des images dans GitHub Packages]

    N --> O{Environnement cible}

    O -->|develop| P[Déploiement Staging]
    O -->|main| Q[Déploiement Production]

    subgraph CD["Déploiement continu"]
        P --> P1[Mise à jour du contexte EKS Staging]
        P1 --> P2[Déploiement Helm<br/>microcrm-staging]
        P2 --> P3[Tests de validation]

        Q --> Q1[Mise à jour du contexte EKS Production]
        Q1 --> Q2[Déploiement Helm<br/>microcrm-prod]
        Q2 --> Q3[Tests de validation]
    end

    P3 --> R[Envoi des métriques DORA]
    Q3 --> R

    R --> S[Pushgateway]
    S --> T[Prometheus]
    T --> U[Grafana]