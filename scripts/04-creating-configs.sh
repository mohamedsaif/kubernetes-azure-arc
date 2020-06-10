ARC_PREFIX=gbb-arc
ARC_LOCATION=westeurope
ARC_LOCATION_CODE=weu
RG_ARC=$ARC_PREFIX-rg-$ARC_LOCATION_CODE
ARC_SP_NAME=$ARC_PREFIX-sp
K8S_NAME=$CLUSTER1

REPO_URL="https://github.com/mohamedsaif/cluster-config"

# Note that there currently 2 types of Kubernetes clusters, AKS (Azure Kubernetes Service) or all others (connected cluster)
# You can specify the type in the clusterType

# All K8S clusters (except AKS)
sudo az k8sconfiguration create \
    --name cluster-config \
    --cluster-name $K8S_NAME \
    --resource-group $RG_ARC \
    --operator-instance-name cluster-config \
    --operator-namespace cluster-config \
    --repository-url $REPO_URL \
    --cluster-scoped --debug

# validate the config application
az k8sconfiguration show --resource-group $RG_ARC \
    --name default-cluster-config \
    --cluster-name $K8S_NAME
  
# Append the following on AKS clusters
# --cluster-type managedclusters \
# az k8sconfiguration create \
#     --name global-config \
#     --cluster-name $K8S_NAME --resource-group aksadv-rg \
#     --operator-instance-name global-config \
#     --operator-namespace global-config \
#     --repository-url $REPO_URL \
#     --cluster-type managedclusters \
#     --cluster-scoped

# If you have a lot of evicted metrics pods, use the following commands to clean them out (deleting them)
kubectl get pods --all-namespaces -ojson \
  | jq -r '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) | .metadata.name + " " + .metadata.namespace' \
  | xargs -n2 -l bash -c 'kubectl delete pods $0 --namespace=$1'
