# Desplegament d'un clúster de Kubernetes amb kubeadm

Vídeo a la prova realitzada: <a href="" target="_blank">Desplegament d'un clúster de Kubernetes amb kubeadm en un entorn local</a>

## Objectiu

![](../img/)

Desplegar un clúster de Kubernetes amb kubeadm i practicar els conceptes metalLoadBalancer, Nginx Ingress Controller.

## Instal·lació pas a pas de kubernetes amb kubeadm

### Controlplane

* Mode root

```
sudo -i
```

* Actualitzar el sistema

```
apt update && apt upgrade -y
```

* Instal·lar paquets necessaris

```
apt install curl apt-transport-https vim git wget \
software-properties-common lsb-release ca-certificates -y
```

* Desactivar swap

```
swapoff -a
```

* Carregar els següents moduls:

```
modprobe overlay
modprobe br_netfilter
```

* Actualitzar el kernel per permetre el trafic

```
cat << EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

* Verificar que els canvis s'han realitzat

```
sysctl --system
```

* Instal·lar la clau necessària per la instal·lació

```
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \ "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

* Instal·lar containerd

```
apt-get update && apt-get install containerd.io -y
containerd config default | tee /etc/containerd/config.toml
sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
systemctl restart containerd
```

* Crear un nou repositori per a Kubernetes

```
echo 'deb https://packages.cloud.google.com/apt kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list

```

* Afegir la clau GPG per als paquets:

```
curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg
```

* Actualitzar i instal·lar kubeadm, kubectl i kubelet

```
apt update -y
apt install kubeadm kubectl kubelet
```

* Configurar els paquets perque no s'actualitzin

```
apt-mark hold kubelet kubeadm kubectl
```

* Afegir un DNS local al servidor controlplane

```
# editar /etc/hosts

172.16.2.5  controlplane
```

* Crear un fitxer de configuració pel cluster

```
# vim kubeadm-config.yaml

apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: 1.27.1
controlPlaneEndpoint: "k8scp:6443"
networking:
  podSubnet: 172.16.2.0/24 
```

* Inicialitzar el node controlplane

```
kubeadm init --config=kubeadm-config.yaml --upload-certs | tee kubeadm-init.out
```

* Logout root i configurar l'usuari com administrado del clúster

```
logout
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
less .kube/config
```

* Instal·lar el gestor de paquets Helm

```
wget https://get.helm.sh/helm-v3.13.2-linux-amd64.tar.gz
tar -zxvf helm-v3.13.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/helm
```

* Seleccionar un pod de xarxa per al CNI (Container Networkin Interface) hi ha diversos, Cilium o Calico són bastant populars.

```
helm repo add cilium https://helm.cilium.io/
helm repo update
helm template cilium cilium/cilium --namespace kube-system > cilium.yaml
kubectl apply -f cilium.yaml
```

* Instal.lar autocompletat

```
sudo apt-get install bash-completion -y
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> $HOME/.bashrc
```

### Worker1

* Repetir els mateixos passos que al node anterior des de l'inici fins a afegir un DNS local al node worker

* Mode root

```
sudo -i
```

* Actualitzar el sistema

```
apt update && apt upgrade -y
```

* Instal·lar paquets necessaris

```
apt install curl apt-transport-https vim git wget \
software-properties-common lsb-release ca-certificates -y
```

* Desactivar swap

```
swapoff -a
```

* Carregar els següents moduls:

```
modprobe overlay
modprobe br_netfilter
```

* Actualitzar el kernel per permetre el trafic

```
cat << EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

* Verificar que els canvis s'han realitzat

```
sysctl --system
```

* Instal·lar la clau necessària per la instal·lació

```
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \ "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

* Install containerd

```
apt-get update && apt-get install containerd.io -y
containerd config default | tee /etc/containerd/config.toml
sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
systemctl restart containerd
```

* Crear un nou repositori per a Kubernetes

```
echo 'deb https://packages.cloud.google.com/apt kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list

```

* Afegir la clau GPG per als paquets:

```
curl -fsSL "https://packages.cloud.google.com/apt/doc/apt-key.gpg" | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg
```

* Actualitzar i instal·lar kubeadm, kubectl i kubelet

```
apt update -y
apt install kubeadm kubectl kubelet
```

* Configurar els paquets perque no s'actualitzin

```
apt-mark hold kubelet kubeadm kubectl
```

* Afegir un DNS local al servidor controlplane

```
# editar /etc/hosts

172.16.3.5  worker1
```

* Per unir el worker al cluster del controlplane es pot utilitzar el token inicial que mostra la primera vegada el controlplane o bé generar un nou token
```
sudo kubeadm token list
```

* Creació d'un nou token (al controlplane)

```
sudo kubeadm token create
```

*  Generació del discovery token CA cert hash per permetre la unió del node worker

```
openssl x509 -pubkey \
-in /etc/kubernetes/pki/ca.crt | openssl rsa \
-pubin -outform der 2>/dev/null | openssl dgst \
-sha256 -hex | sed 's/^.* //'
```

* Utilitzar el token i el discovery token al worker node

```
sudo -i
kubeadm join --token 27eee4.6e66ff60318da929 controlplane:6443 \
--discovery-token-ca-cert-hash sha256:6d541678b05652e1fa5d43908e75e67376e994c3483d6683f2a18673e5d2a1b0
```

* Anar al controlplane i verificar que tot funciona correctament

```
kubectl get node
kubectl describe node controlplane
```

* Permetre que controlplane pugui contenir pods que no siguin del sistema

```
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

* Verificar que cilium i coredns funcionen correctament

```
kubectl get pods --all-namespaces
```

* Verificar si s'ha creat un nou tunel
```
kubectl get pods --all-namespaces
```

* Actualització de crictl

```
sudo crictl config --set \
runtime-endpoint=unix:///run/containerd/containerd.sock \
--set image-endpoint=unix:///run/containerd/containerd.sock

sudo cat /etc/crictl.yaml
```

### Desplegar una aplicació de prova

``` 
kubectl create deployment nginx --image=nginx
kubectl get deployments
kubectl describe deployment nginx
kubectl get events
kubectl get deployment nginx -o yaml > nginx.yaml
kubectl delete deployment nginx
```

## MetalLB (loadbalancer)

* Verificar si kube-proxy es troba en mode IPVS

```
kubectl get configmap kube-proxy -n kube-system -o yaml

```

* En cas afirmatiu afegir la següent configuració afegir strictARP: true

```
kubectl edit configmap -n kube-system kube-proxyapiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: "ipvs"
ipvs:
  strictARP: true
```

* Instal·lar MetalLB

```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml
```


* Crear el fitxer de configuració amb el pool d'adreces

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

k apply -f configmap-metallb
```


## Nginx Ingress Controller 

* Instal.lació Nginx Ingress Controller

``` 
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

```

## Verificació

* Els pods haurien de mostrar EXTERNAL-IP

```
kubectl get node
```

* Ingress-nginx service hauria de ser de tipus LoadBalancer i tenir EXTERNAL IP

```
kubectl -n ingress-nginx get svc

curl -D- http://172.16.2.250 -H 'Host: myapp.example.com'
```