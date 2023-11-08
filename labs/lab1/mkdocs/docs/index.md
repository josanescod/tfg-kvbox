# Desplegament d'un servei web a un clúster de Kubernetes

Repositori [https://github.com/josanescod/tfg-kvbox](https://github.com/josanescod/tfg-kvbox)

## Objectiu

![](img/mkdocs_service.png)

L'objectiu és crear una documentació de prova que es generarà amb MKDocs, s'afegirà a una imatge Docker, i es desplegarà
com un servei dins d'un clúster de K3s.

## Requisits

- Docker
- Cluster de Kubernetes

## Creació de l'estructura de fitxers amb el contenidor squidfunk/mkdocs-material

```
docker run --rm -it -p 8000:8000 -v "$PWD":/docs squidfunk/mkdocs-material new .

```

## Modificació del contingut en format markdown 

Es modifiquen els fitxers md i el fitxer de configuració mkdocs.yml.

## Generació de la documentació

```
docker run --rm -it -v "$PWD":/docs squidfunk/mkdocs-material build
```

## Creació d'un fitxer manifest per a kubernetes amb un Servei per exposar l'aplicació dins d'un cluster de k3s

```
apiVersion: v1
kind: Pod
metadata:
  name: web1
  labels:
    app: web
spec:
  containers:
    - name: webtest
      image: https:alpine
      ports:
        - containerPort: 80
      volumeMounts:
        - name: html-volume
          mountPath: /usr/local/apache2/htdocs
  volumes:
    - name: html-volume
      hostPath:
        path: /home/vagrant/mkdocs/site

---
apiVersion: v1
kind: Service
metadata:
  name: service1
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

```

## Comanda per desplegar el servei

```
kubectl apply -f docu_service.yaml 
    
```