# MicroCRM Front-end

## Démarrer depuis les packages officiels

Les packages Back-end sont disponible [ici](https://github.com/Project6-Organisation/Project6-Application/pkgs/container/project6-application%2Frontend)

Au préalable, s'assurer que le service Docker est correctement démarré

Remplacer vx.x.x par la version souhaitée

```shell
# Terminal
docker run --name microcrm-front -it --rm -p 80:80 -p 443:443 ghcr.io/project6-organisation/project6-application/frontend:vx.x.x
```

L'application Front-end est disponible à l'adresse http://localhost

### Configurer https

1. Lancer le conteneur avec un volume pour récupérer le certificat Caddy

```shell
# Terminal depuis le répertoire de l'application
docker run -d --name microcrm-front -p 80:80 -p 443:443 -v caddy-data:/home/appuser/.local/share/caddy ghcr.io/project6-organisation/project6-application/frontend:vx.x.x
```

2. Copier le certificat racine root.crt depuis le conteneur vers Windows

```shell
# Terminal depuis le répertoire de l'application
docker cp microcrm-front:/home/appuser/.local/share/caddy/pki/authorities/local/root.crt .
```

3. Installer le certificat dans Windows (En PowerShell Administrateur)

```shell
# Terminal depuis le répertoire de l'application
Import-Certificate -FilePath .\root.crt -CertStoreLocation Cert:\LocalMachine\Root
```

4. Supprimer et relancer le conteneur (avec le volume)

```shell
# Terminal depuis le répertoire de l'application
docker rm -f microcrm-front
docker run -d --name microcrm-front -p 80:80 -p 443:443 -v caddy-data:/home/appuser/.local/share/caddy ghcr.io/project6-organisation/project6-application/frontend:vx.x.x
```

L'application Front-end est disponible à l'adresse http://localhost ou https://localhost:443

Note : Le certificat est valide, il n'y a plus de warning. Cependant l'application est toujours marquée 'non sécurisée'

## Démarrer depuis le répertoire de l'application

### Build image Docker

Au préalable, s'assurer que le service Docker est correctement démarré

```shell
# Terminal depuis le répertoire de l'application
cd front
docker build -t microcrm-front .
```

### Démarrer le conteneur

```shell
# Terminal depuis le répertoire de l'application
cd front
docker run -it --rm -p 80:80 microcrm-front
```

ou en mode détaché

```shell
# Terminal depuis le répertoire de l'application
cd front
docker run -d --name microcrm-front -p 80:80 microcrm-front
```

L'application Front-end est disponible à l'adresse http://localhost

### Configurer https

1. Lancer le conteneur avec un volume pour récupérer le certificat Caddy

```shell
# Terminal depuis le répertoire de l'application
cd front
docker run -d --name microcrm-front -p 80:80 -p 443:443 -v caddy-data:/home/appuser/.local/share/caddy microcrm-front
```

2. Copier le certificat racine root.crt depuis le conteneur vers Windows

```shell
# Terminal depuis le répertoire de l'application
cd front
docker cp microcrm-front:/home/appuser/.local/share/caddy/pki/authorities/local/root.crt .
```

3. Installer le certificat dans Windows (En PowerShell Administrateur)

```shell
# Terminal depuis le répertoire de l'application
cd front
Import-Certificate -FilePath .\root.crt -CertStoreLocation Cert:\LocalMachine\Root
```

4. Supprimer et relancer le conteneur (avec le volume)

```shell
# Terminal depuis le répertoire de l'application
cd front
docker rm -f microcrm-front
docker run -d --name microcrm-front -p 80:80 -p 443:443 -v caddy-data:/home/appuser/.local/share/caddy microcrm-front
```

L'application Front-end est disponible à l'adresse http://localhost ou https://localhost:443

Note : Le certificat est valide, il n'y a plus de warning. Cependant l'application est toujours marquée 'non sécurisée'