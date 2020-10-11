# Traefik-v2

Mise en place de la terminaison TLS sur Traefik v2 en utilisant cert-manager 

# Context


# Prérequis 

- Cluster kubernetes 

- [**helm v3**](https://helm.sh/docs/intro/install/)



# Dépoiement de Cert-manager

## Création du Namespace

```
# kubectl create namespace cert-manager
```

## Rajouter le dépot jetstack au cache helm 

```
# helm repo add jetstack https://charts.jetstack.io
# helm tepo update 
```

## Installer cert-manager

```
# helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --version v1.0.2 \
    --set installCRDs=true
```


## Création du ClusterIssuer 

```
# kubectl apply -f clusterissuer.yaml
```

# Dépoiement traefik v2 

## Création du Namespace 

```
# kubectl create namespace traefik
```

## Rajouter le dépot traefik au cache helm 

```
# helm repo add traefik https://helm.traefik.io/traefik
# helm repo update
```


## Deux cas d'usage 

- Certificat porté par traefik 
- Certificat porté par le pod applicatif (recommondée)  


## Installer Traefik  

```
# helm install traefik traefik/traefik --namespace=traefik 
```










## sources 
[Cert-manager](https://cert-manager.io/docs/installation/kubernetes/)
[Trafik](https://doc.traefik.io/traefik/getting-started/install-traefik/)