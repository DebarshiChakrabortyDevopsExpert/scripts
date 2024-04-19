https://docs.microsoft.com/en-us/azure/container-registry/container-registry-helm-repos
https://opensource.com/article/20/5/helm-charts

article to create helm chart

## To install the custom helm chart use the command mentioned below

helm install chartname chartpath --values chartpath/values.yaml

helm install my-cherry-chart compliance-scanner --values compliance-scanner/values.yaml

## To upgrade the existing chart without deleteing the pods

helm upgrade chartname chartpath

helm upgrade my-cherry-chart compliance-scanner

## We can also check the old registry and do a rollback to old helm version

helm history <chart-name>
helm rollback <release-name> <revision-number>
helm rollback deployed-mdm 1

## To push the helm chart to azure registry 

We can simply go ahead and create a package of the helm chart

helm package chartpath

## It will save a tgz file 

helm registry login $ACR_NAME.azurecr.io \
  --username $USER_NAME \
  --password $PASSWORD

## login to the ACR with the command mentioned above
Push the chart to the registry

helm push hello-world-0.1.0.tgz oci://$ACR_NAME.azurecr.io/helm

<!-- For installing the helm chart use the command mentioned below  -->

helm install myhelmtest oci://$ACR_NAME.azurecr.io/helm/hello-world --version 0.1.0s

kubectl exec -it podname bash
kubectl get pods -o wide
kubectl attach podname
kubectl describe pod podname
kubectl get service,deployments,pod -namespace -o wide
kubectl get logs podname
kubectl get nodes -o wide

