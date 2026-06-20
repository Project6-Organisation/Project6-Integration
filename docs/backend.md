# MicroCRM Back-end

## Démarrer depuis les packages officiels

Les packages Back-end sont disponible [ici](https://github.com/Project6-Organisation/Project6-Application/pkgs/container/project6-application%2Fbackend)

Au préalable, s'assurer que le service Docker est correctement démarré

Remplacer vx.x.x par la version souhaitée

```shell
# Terminal
docker run --name microcrm-back -it --rm -p 8080:8080 ghcr.io/project6-organisation/project6-application/backend:vx.x.x
```

L'application Back-end est disponible à l'adresse http://localhost:8080

## Démarrer depuis le répertoire de l'application

### Build image Docker

Au préalable, s'assurer que le service Docker est correctement démarré

```shell
# Terminal depuis le répertoire de l'application
cd back
docker build -t microcrm-back .
```

### Démarrer le conteneur

```shell
# Terminal depuis le répertoire de l'application
cd back
docker run -it --rm -p 8080:8080 microcrm-back
```

ou en mode détaché

```shell
# Terminal depuis le répertoire de l'application
cd back
docker run -d --name microcrm-back -p 8080:8080 microcrm-back
```

L'application Back-end est disponible à l'adresse http://localhost:8080