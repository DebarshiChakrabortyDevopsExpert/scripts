## Enable istio Service mesh on AKS Cluster
- az aks mesh enable --resource-group aks-cluster-deb-001_group --name aks-cluster-deb-001
- Istio sytem namespace components
![alt text](istio_system.png)
- Istio Ingress namespace components![alt text](istio_ingress_gateway.png)
- Enabled automatic sidecar injection for default namespace![alt text](Automatic_sidecar_inject.png)