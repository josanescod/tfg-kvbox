# Proves en servidors remots II

## Instal·lació d'influxdb

[chart-influxdb2](https://github.com/influxdata/helm-charts/tree/master/charts/influxdb2){:target="_blank"}

```
helm upgrade --install influxdb influxdata/influxdb2 --set persistence.enabled=false 
```