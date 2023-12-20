# Proves en servidors remots II

## Afegir un tercer node al clúster

Instal·lar a la nova màquina kubeadm, seguint els passos d'aquest enllaç: [kubeadm](/local_test/kubeadm/#worker1){:target="_blank"}

Configurar el firewall del nou node, obrir el port 8472/udp (que utilitza [cilium](https://docs.cilium.io/en/stable/network/concepts/routing/){:target="_blank"}) 

```bash
sudo ufw allow 10250/tcp
sudo ufw allow 30000:32767/tcp
sudo ufw allow 8472/udp
```

Executar la següent instrucció  al controlplane, 

```bash
kubeadm token create --print-join-command

```

Al worker2 executar el resultat de la comanda anterior que ha generat un nou token per unir el nou node al clúster.

```bash
kubeadm join --token token_exemple controlplane:6443 \
--discovery-token-ca-cert-hash sha256:hash_exemple 
```

## Instal·lació d'influxdb

[chart-influxdb2](https://github.com/influxdata/helm-charts/tree/master/charts/influxdb2){:target="_blank"}

```bash
helm repo add influxdata https://helm.influxdata.com/
helm repo update
helm install influxdb influxdata/influxdb2 --set persistence.enabled=false

# token
echo $(kubectl get secret influxdb-influxdb2-auth -o "jsonpath={.data['admin-password']}" --namespace default | base64 --decode)

```

Entrar amb l'usuari/contrassenya i crear una organització, un bucket i un API token.

* Automatitzar crear organització test

```bash
influx org create -n test

```

* Automatitzar crear bucket test

```bash
influx bucket create \
  --name my_schema_bucket \
  --schema-type explicit
```

* Automatitzar crear un API token de test

```bash
influx auth create \
  --org test \
  --read-bucket 03a2bbf46309a000 \
```

## Instal·lació de telegraf

```bash
helm repo add influxdata https://helm.influxdata.com/
helm repo update
helm install telegraf -f apps/config/telegraf-config.yaml --set tplVersion=2 influxdata/telegraf
```
Fitxer de configuració de telegraf

Modificar inputs i outputs

inputs amb el plugin [kube_inventory](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/kube_inventory){:target="_blank"}


```yaml
# telegraf-config.yaml
## Default values.yaml for Telegraf
## This is a YAML-formatted file.
## ref: https://hub.docker.com/r/library/telegraf/tags/

replicaCount: 1
image:
  repo: "docker.io/library/telegraf"
  tag: "1.29-alpine"
  pullPolicy: IfNotPresent
podAnnotations: {}
podLabels: {}
imagePullSecrets: []
## Configure args passed to Telegraf containers
args: []
# The name of a secret in the same kubernetes namespace which contains values to
# be added to the environment (must be manually created)
# This can be useful for auth tokens, etc.

# envFromSecret: "telegraf-tokens"
env:
  - name: HOSTNAME
    value: "telegraf-polling-service"
# An older "volumeMounts" key was previously added which will likely
# NOT WORK as you expect. Please use this newer configuration.

# volumes:
# - name: telegraf-output-influxdb2
#   configMap:
#     name: "telegraf-output-influxdb2"
# mountPoints:
# - name: telegraf-output-influxdb2
#   mountPath: /etc/telegraf/conf.d
#   subPath: influxdb2.conf

## Configure resource requests and limits
## ref: http://kubernetes.io/docs/user-guide/compute-resources/
resources: {}
# requests:
#   memory: 128Mi
#   cpu: 100m
# limits:
#   memory: 128Mi
#   cpu: 100m

## Node labels for pod assignment
## ref: https://kubernetes.io/docs/user-guide/node-selection/
nodeSelector: {}
## Affinity for pod assignment
## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
##
affinity: {}
## Tolerations for pod assignment
## Ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
##
tolerations: []
# - key: "key"
#   operator: "Equal|Exists"
#   value: "value"
#   effect: "NoSchedule|PreferNoSchedule|NoExecute(1.6 only)"

## Configure the updateStrategy used to replace Telegraf Pods
## See https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/
updateStrategy: {}
#  type: RollingUpdate|Recreate
#  rollingUpdate:
#    maxUnavailable: 1
#    maxSurge: 1

service:
  enabled: true
  type: ClusterIP
  annotations: {}
rbac:
  # Specifies whether RBAC resources should be created
  create: true 
  # Create only for the release namespace or cluster wide (Role vs ClusterRole)
  clusterWide: false
  # Rules for the created rule
  # rules: []
  rules:
# When using the prometheus input to scrape all pods you need extra rules set to the ClusterRole to be
# able to scan the pods for scraping labels. The following rules have been taken from:
# https://github.com/helm/charts/blob/master/stable/prometheus/templates/server-clusterrole.yaml#L8-L46
    - apiGroups:
        - ""
      resources:
        - nodes
        - nodes/proxy
        - nodes/metrics
        - services
        - endpoints
        - pods
        - ingresses
        - configmaps
      verbs:
        - get
        - list
        - watch
    - apiGroups:
        - "extensions"
      resources:
        - ingresses/status
        - ingresses
      verbs:
        - get
        - list
        - watch
          #    - nonResourceURLs:
          #        - "/metrics"
      verbs:
        - get
serviceAccount:
  # Specifies whether a ServiceAccount should be created
  create: true 
  # The name of the ServiceAccount to use.
  # If not set and create is true, a name is generated using the fullname template
  name: 
  # Annotations for the ServiceAccount
  annotations: {}
## Exposed telegraf configuration
## For full list of possible values see `/docs/all-config-values.yaml` and `/docs/all-config-values.toml`
## ref: https://docs.influxdata.com/telegraf/v1.1/administration/configuration/
config:
  agent:
    interval: "10s"
    round_interval: true
    metric_batch_size: 1000
    metric_buffer_limit: 10000
    collection_jitter: "0s"
    flush_interval: "10s"
    flush_jitter: "0s"
    precision: ""
    debug: false
    quiet: false
    logfile: ""
    hostname: "$HOSTNAME"
    omit_hostname: false
  processors:
    - enum:
        mapping:
          field: "status"
          dest: "status_code"
          value_mappings:
            healthy: 1
            problem: 2
            critical: 3
  outputs:
    - influxdb_v2:
        urls:
          - "https://influxdb.josanesc.com"
        bucket: "test"
        organization: "test"
        token: "ySJC4OJkaNcPbSZkmFvevXOEnReWx70Lvl9_NJ5mlWYPjQ4yhP2ivbNHzio6VIhX3lk2X667wp42E6tr2qWPDg=="
        timeout: "5s"
        insecure_skip_verify: false


  inputs:
    - kube_inventory:
        url: ""

    - http_response :
        urls: ["https://k8s-tfg.josanesc.com", "https://dashboard.josanesc.com", "https://chat-ai.josanesc.com", "https://repository.josanesc.com", "https://grafana.josanesc.com", "https://codeserver.josanesc.com", "https://docs.josanesc.com", "https://influxdb.josanesc.com"]
        method: "GET"
        follow_redirects: true 

    - statsd:
        service_address: ":8125"
        percentiles:
          - 50
          - 95
          - 99
        metric_separator: "_"
        allowed_pending_messages: 10000
        percentile_limit: 1000
metrics:
  health:
    enabled: false
    service_address: "http://:8888"
    threshold: 5000.0
  internal:
    enabled: true
    collect_memstats: false
# Lifecycle hooks
# hooks:
#   postStart: ["/bin/sh", "-c", "echo Telegraf started"]
#   preStop: ["/bin/sh", "-c", "sleep 60"]

## Pod disruption budget configuration
##
pdb:
  ## Specifies whether a Pod disruption budget should be created
  ##
  create: true
  minAvailable: 1
  # maxUnavailable: 1
```

Executar el pod:

```bash
kubectl exec -i -t --namespace default $(kubectl get pods --namespace default -l app.kubernetes.io/name=telegraf -o jsonpath='{.items[0].metadata.name}') /bin/sh

```
Veure logs:

```bash
kubectl logs -f --namespace default $(kubectl get pods --namespace default -l app.kubernetes.io/name=telegraf -o jsonpath='{ .items[0].metadata.name }')
```
## Instal·lació  de Grafana

```bash
helm upgrade --install grafana grafana/grafana

# token
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
