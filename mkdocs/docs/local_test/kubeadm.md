# Desplegament d'un clúster de Kubernetes amb kubeadm

Vídeo a la prova realitzada: <a href="" target="_blank">Desplegament d'un clúster de Kubernetes amb kubeadm</a>

## Objectiu

![](../img/demo6.png)

Desplegar un clúster de Kubernetes amb kubeadm i practicar els conceptes metalLoadBalancer, Nginx Ingress Controller.

## Instal·lació pas a pas de kubernetes amb kubeadm

### Controlplane

Mode root

```
sudo -i
```

Actualitzar el sistema

```
apt update && apt upgrade -y
```

Instal·lar paquets necessaris

```
apt install curl apt-transport-https vim git wget \
software-properties-common lsb-release ca-certificates -y
```

Desactivar swap

```
swapoff -a
```

Carregar els següents mòduls:

```
modprobe overlay
modprobe br_netfilter
```

Actualitzar el kernel per permetre el tràfic

```
cat << EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

Verificar que els canvis s'han realitzat

```
sysctl --system
```

Instal·lar la clau necessària per a la instal·lació

```
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \ "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Instal·lar containerd

```
apt-get update && apt-get install containerd.io -y
containerd config default | tee /etc/containerd/config.toml
sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
systemctl restart containerd
```

Crear un nou repositori per a Kubernetes

```
echo 'deb https://packages.cloud.google.com/apt kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list

```

Afegir la clau GPG per als paquets:

```
curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg
```

Actualitzar i instal·lar kubeadm, kubectl i kubelet

```
apt update -y
apt install kubeadm kubectl kubelet
```

Configurar els paquets perquè no s'actualitzin

```
apt-mark hold kubelet kubeadm kubectl
```

Afegir un DNS local al servidor controlplane

```
# editar /etc/hosts

172.16.2.5  controlplane
```

Crear un fitxer de configuració pel clúster

```
# vim kubeadm-config.yaml

apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: 1.28.2
controlPlaneEndpoint: "controlplane:6443"
networking:
  podSubnet: 172.16.2.0/24 
```

Inicialitzar el node controlplane

```
kubeadm init --config=kubeadm-config.yaml --upload-certs | tee kubeadm-init.out
```

Logout root i configurar l'usuari com administrado del clúster

```
exit
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
less $HOME/.kube/config
```

Instal·lar el gestor de paquets Helm

```
wget https://get.helm.sh/helm-v3.13.2-linux-amd64.tar.gz
tar -zxvf helm-v3.13.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
```

Seleccionar un pod de xarxa per al CNI (Container Networking Interface) hi ha diversos, Cilium o Calico són bastant populars.

```
helm repo add cilium https://helm.cilium.io/
helm repo update
helm template cilium cilium/cilium --namespace kube-system > cilium.yaml
kubectl apply -f cilium.yaml
```

Instal·lar autocompletat

```
sudo apt-get install bash-completion -y
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> $HOME/.bashrc
```

### Worker1

Repetir els mateixos passos que al node anterior des de l'inici fins a afegir un DNS local al node worker

Mode root

```
sudo -i
```

Actualitzar el sistema

```
apt update && apt upgrade -y
```

Instal·lar paquets necessaris

```
apt install curl apt-transport-https vim git wget \
software-properties-common lsb-release ca-certificates -y
```

Desactivar swap

```
swapoff -a
```

Carregar els següents mòduls

```
modprobe overlay
modprobe br_netfilter
```

Actualitzar el kernel per permetre el tràfic

```
cat << EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

Verificar que els canvis s'han realitzat

```
sysctl --system
```

Instal·lar la clau necessària per a la instal·lació

```
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \ "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install containerd

```
apt-get update && apt-get install containerd.io -y
containerd config default | tee /etc/containerd/config.toml
sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
systemctl restart containerd
```

Crear un nou repositori per a Kubernetes

```
echo 'deb https://packages.cloud.google.com/apt kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list

```

Afegir la clau GPG per als paquets:

```
curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg
```

Actualitzar i instal·lar kubeadm, kubectl i kubelet

```
apt update -y
apt install kubeadm kubectl kubelet
```

Configurar els paquets perquè no s'actualitzin

```
apt-mark hold kubelet kubeadm kubectl
```

Afegir un DNS local al servidor controlplane

```
# editar /etc/hosts
172.16.3.5  worker1
172.16.2.5  controlplane
```

Per unir el worker al clúster del controlplane es pot utilitzar la instrucció join amb el token inicial que mostra la primera vegada el controlplane o bé generar un nou token
```
sudo kubeadm token list
```

Creació d'un nou token (al controlplane)

```
sudo kubeadm token create
```

Generació del discovery token CA cert hash per permetre la unió del node worker

```
openssl x509 -pubkey \
-in /etc/kubernetes/pki/ca.crt | openssl rsa \
-pubin -outform der 2>/dev/null | openssl dgst \
-sha256 -hex | sed 's/^.* //'
```

Utilitzar el token i el discovery token al worker node

```
sudo -i
kubeadm join --token 27eee4.6e66ff60318da929 controlplane:6443 \
--discovery-token-ca-cert-hash sha256:6d541678b05652e1fa5d43908e75e67376e994c3483d6683f2a18673e5d2a1b0
```

Anar al controlplane i verificar que tot funciona correctament

```
kubectl get node
kubectl describe node controlplane
```

Permetre que controlplane pugui contenir pods que no siguin del sistema

```
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

Verificar que cilium i coredns funcionen correctament

```
kubectl get pods --all-namespaces
```

Actualització de crictl

```
sudo crictl config --set \
runtime-endpoint=unix:///run/containerd/containerd.sock \
--set image-endpoint=unix:///run/containerd/containerd.sock

sudo cat /etc/crictl.yaml
```

## MetalLB (loadbalancer)

Verificar si kube-proxy es troba en mode IPVS

```
kubectl get configmap kube-proxy -n kube-system -o yaml

```

En cas afirmatiu afegir la següent configuració afegir strictARP: true

```
kubectl edit configmap -n kube-system kube-proxyapiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```

Instal·lar MetalLB

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
```


Crear el fitxer de configuració amb el pool d'adreces

```
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.16.2.240-172.16.2.250
  autoAssign: true
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec:
  ipAddressPools:
  - default
```

k apply -f metallb-config.yaml


## Nginx Ingress Controller 

Instal.lació Nginx Ingress Controller

``` 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

```

Ingress-nginx service hauria de ser de tipus LoadBalancer, tenir EXTERNAL-IP i estar disponible fora del clúster.

```
kubectl -n ingress-nginx get svc

curl -D- http://172.16.2.250 -H 'Host: myapp.example.com'
```

## Desplegar una aplicació de prova

ConfigMap

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-configmap
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
      <title>My HTML Page</title>
    </head>
    <body>
      <h1>Test Ingress Nginx amb External-IP</h1>
      <p>Funciona correctament.</p>
    </body>
    </html>
```

Deployment

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config-volume
          mountPath: /usr/share/nginx/html
      volumes:
      - name: config-volume
        configMap:
          name: my-configmap
          items:
          - key: index.html
            path: index.html
```

Service

```
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 5000
    targetPort: 80
```

Ingress

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations: {}
  name: nginx-server-ingress

spec:
  ingressClassName: nginx
  rules:
  - host: app1.cluster.test
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 5000
```

k apply -f test-configmap.yaml -f test-deployment.yaml -f test-service.yaml -f test-ingress yaml

A la màquina client editar /etc/hosts amb la ip externa de Nginx Ingress Controller proporcionada per MetalLB i el nom del host
que s'ha configurat a la regla Ingress.

```
# /etc/hosts
EXTERNAL-IP app1.cluster.test
```

Realitzar una petició al servei

```
curl -D- http://EXTERNAL-IP -H 'Host: app1.cluster.test'
```