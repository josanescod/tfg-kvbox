# Desplegament d'un clúster de Kubernetes amb k0s

Vídeo a la prova realitzada: <a href="" target="_blank">Desplegament d'un clúster de Kubernetes en entorn locall amb k0s</a>

## Objectiu

![](../img/)

L'objectiu és desplegar un clúster de kubernetes amb la distribució k0s i practiar els conceptes de Ingress, Ingress Controller, Persistent Volume,
Persistent Volume Claim, i LoadBalancer.

## Creació del clúster

```
# al control plane
mkdir -p /etc/k0s
k0s config create > /etc/k0s/k0s.yaml
sudo k0s install controller -c /etc/k0s/k0s.yaml
sudo k0s start
sudo k0s token create --role=worker

# al worker
sudo k0s install worker --token-file /path/to/token/file
sudo k0s start
```

## Ingress (recurs de Kubernetes)

```

```

## Ingress Controller

```

```

## Persistence Volume

```

```

## Persistence Volume Claim

```

```

## Load Balance 