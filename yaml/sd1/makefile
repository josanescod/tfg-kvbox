# Makefile to manage Kubernetes commands

# Variables
NAMESPACE=default
# APP_NAME=my-app
KUBECTL=kubectl
FOLDER_APPS=/home/josan/manifests/apps
FOLDER_CONFIG=/home/josan/manifests/config

# Targets
.PHONY: help
help:
	@echo "Usage: make <target>"
	@echo "Available targets:"
	@echo "  cluster-up or c-up          Bring up necessary services in the cluster"
	@echo "  cluster-down or c-down      Delete services brought up in the cluster"
	@echo "  cluster-watch or c-watch    Watch pods, services and ingress"
	
# Bring up necessary services in the cluster
.PHONY: cluster-up c-up
cluster-up c-up:
	$(KUBECTL) apply -f $(FOLDER_CONFIG)/ingress-nginx-controller.yaml
	$(KUBECTL) apply -f $(FOLDER_APPS)
	sleep 30 
	$(KUBECTL) apply -f $(FOLDER_CONFIG)/ingress.yaml
	helm repo add influxdata https://helm.influxdata.com/
	helm repo update
	helm install influxdb influxdata/influxdb2 --set persistence.enabled=false
#	helm install telegraf -f apps/config/telegraf-config.yaml --set tplVersion=2 influxdata/telegraf
	helm install grafana grafana/grafana
	kubectl get secret --namespace default influxdb-influxdb2-auth -o jsonpath="{.data.admin-password}" | base64 --decode > /home/josan/manifests/influxdb-token.txt
	kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode > /home/josan/manifests/grafana-token.txt

# Delete services brought up in the cluster
.PHONY: cluster-down c-down
cluster-down c-down:
	$(KUBECTL) delete -f $(FOLDER_CONFIG)/ingress.yaml
	$(KUBECTL) delete -f $(FOLDER_APPS)
	$(KUBECTL) delete -f $(FOLDER_CONFIG)/ingress-nginx-controller.yaml &
	helm uninstall telegraf
	helm uninstall influxdb
	helm uninstall grafana
	rm influxdb-token.txt grafana-token.txt
	
# Watch cluster
.PHONY: cluster-watch c-watch
cluster-watch c-watch:
	$(KUBECTL) get pods -n default 
	$(KUBECTL) get svc -n default 
	$(KUBECTL) describe ingress
	$(KUBECTL) get pods -n ingress-ngin

# telegraf 
.PHONY: telegraf 
telegraf:
	helm install telegraf -f apps/config/telegraf-config.yaml --set tplVersion=2 influxdata/telegraf

