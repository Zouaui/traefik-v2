# Traefik-v2

Mise en place de la terminaison TLS sur Traefik v2 en utilisant cert-manager 

# Context


# Prérequis 

- Cluster kubernetes 

- [**helm v3**](https://helm.sh/docs/intro/install/)
  
- [**kubens**](https://blog.zwindler.fr/2018/08/28/utiliser-kubectx-kubens-pour-changer-facilement-de-context-et-de-namespace-dans-kubernetes/) 
    changer de namespace facilement 



# Déploiment de Cert-manager

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

Péréraquis : 

- Utilisateur IAM 
- Enregistrement Dns 


### Création de l'utilisateur Iam pour le DNS Challenge 

Afin de mettre en place le DNS Challenge nous avons besoin d'un utilisateur iam avec les droits suivants : 
```
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "route53:GetChange",
      "Resource": "arn:aws:route53:::change/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    },
    {
      "Effect": "Allow",
      "Action": "route53:ListHostedZonesByName",
      "Resource": "*"
    }
  ]
}
```

L'access key, secret key sont utilisées dans le ClusterIssuer

### Création de la secret kubernetes avec la secret access key 

```
# kubens cert-manager 
# kubectl create secret generic secret-key  --from-literal='cert-manager-secret-key=#your secret key'
```

### Récupération de la hostedZone 

```
aws route53 list-hosted-zones | jq -r '.HostedZones[] | select(.Name == "fayit.lab.") | .Id' | awk -F "/" '{print $3}'
```


### Création du ClusterIssuer 

```
kubectl apply -f clusterissuer.yaml
```



# Dépoiement traefik v2 

## Création du Namespace 

```
# kubectl create namespace traefik
```


## Création du certificat 

```
kubectl apply -f certificat.yaml
```

## Rajouter le dépot traefik au cache helm 

```
# helm repo add traefik https://helm.traefik.io/traefik
# helm repo update
```


## Deux cas d'usage 

- Certificat porté par traefik 
- Certificat porté par le pod applicatif (recommandé)  


## création de la configmap avec la conf tls 

``` 
# kubectl create configmap configs --from-file=./conf.toml
```

## Installer Traefik  

```
# helm install traefik traefik/traefik --values=./values.yaml --set="additionalArguments={--providers.file.filename=conf.toml}"
```

## Test
Pour faire un test de cette configuration vous pouvez déployer l'appliaction whoami
```
# kubectl apply -f whomai.yaml
```

![alt text](https://github.com/Zouaui/traefik-v2/blob/main/infra/whoami.png)


## sources 

[Cert-manager](https://cert-manager.io/docs/installation/kubernetes/)

[Trafik](https://doc.traefik.io/traefik/getting-started/install-traefik/)