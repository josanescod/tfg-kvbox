# Desplegament d'un clúster de Kubernetes amb Kind

Vídeo a la prova realitzada: <a href="" target="_blank">Desplegament d'un servei web en un entorn local amb Kind</a>

## Objectiu

![](../img/demo3.png)

Crear un clúster amb Kind i provar alguns dels recursos de la seva API: daemonSet, job, cronjob, configmap i secret.

Com que Kind és una distribució de Kubernetes basada en contenidors docker, en aquesta ocasió només s'utilitzarà una màquina
virtual de l'entorn de proves.


## Creació del clúster

Creem un fitxer kind-example-config.yaml amb el següent contingut:

``` 
apiVersion: kind.x-k8s.io/v1alpha4
kind: Cluster
nodes:
- role: control-plane
- role: worker
- role: worker
```

kind create cluster --config kind-example-config.yaml

export KUBECONFIG per poder utilizar kubectl

## Etiquetes de rol als dos nodes workers
```
kubectl label node kind-worker node-role.kubernetes.io/worker=worker
kubectl label node kind-worker2 node-role.kubernetes.io/worker=worker

```

## Crear un DaemonSet amb Fluentd

Un DaemonSet és un recurs de Kubernetes que s'assegura que a cada node del clúster es desplegui una còpia d'un pod. 
S'utilitza per recol·lecció de logs, monitoratge de nodes o per executar processos relacionats amb volums, en segon pla. 

```


```

## Job

Un Job és un recurs que pot crear 1 o més pods per executar tasques en paral.lel. S'utilitza en casos que es requereix executar processos
batch, càlculs d'operacions que requereixen gran quantitat de recursos de computació. Alguns exemples són: càlculs de decimals del nombre pi,
consultes a bases de dades, renderització, etc.

```


```

## Cronjob

Un Cronjob és similar a un Job, però que es planifica perquè es repeteixi periòdicament.

```


```

## ConfigMap

Un ConfigMap és

```


```

## Secret

Un Secret és

```


```

## Secret encriptat amb kubeseal

Com que els secrets estan codificats en base64, per afegir una capa extra de seguretat es poden
encriptar amb eines com [kubeseal](https://github.com/bitnami-labs/sealed-secrets){:target="_blank"}. 

Aquesta eina permet encriptar secrets amb un certificat, i després el propi clúster s'encarrega de desencriptar-lo. Pot ser una bona pràctica quan es pujen secrets a repositoris (encara que siguin privats).

Exemple:



