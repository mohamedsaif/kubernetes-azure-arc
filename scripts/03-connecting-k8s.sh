# Setting the name of the Arc resources
ARC_PREFIX=gbb-arc
ARC_LOCATION=westeurope
ARC_LOCATION_CODE=weu
RG_ARC=$ARC_PREFIX-rg-$ARC_LOCATION_CODE
ARC_SP_NAME=$ARC_PREFIX-sp

# Have a look your current contexts
kubectl config get-contexts

# Connecting your first cluster
K8S_NAME=$CLUSTER1
K8S_NAME=$CLUSTER2

# If you need to change context to a specific one
kubectl config use-context $K8S_NAME

sudo az connectedk8s connect \
    --name $K8S_NAME \
    --resource-group $RG_ARC \
    --onboarding-spn-id $ARC_SP_ID \
    --onboarding-spn-secret $ARC_SP_PASSWORD \
    --kube-context $K8S_NAME

# Check the list of connected clusters
az connectedk8s list -o table

# Adding kube-context if you have all contexts saved in the local machine
# --kube-context K8S_NAME

# NOTE: if you faced helm chart not found error, you might want to run the above command with sudo

# If you want automatic generation of the SP, use:
# az connectedk8s connect --name $RG_ARC --resource-group $RG_ARC

# On Azure portal Arc resource gorup, you will find the cluster
# Also running hte following commands to explorer what was deployed:

helm list
# NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
# azure-arc       default         1               2020-03-09 06:52:38.9366404 +0400 +04   deployed        azure-arc-k8sagents-0.1.18      1.0

kubectl get deployments,secrets -n azure-arc
# NAME                                       READY   UP-TO-DATE   AVAILABLE   AGE
# deployment.extensions/config-agent         1/1     1            1           21m
# deployment.extensions/connect-agent        1/1     1            1           21m
# deployment.extensions/controller-manager   1/1     1            1           21m
# deployment.extensions/metrics-agent        1/1     1            1           21m

# NAME                                      TYPE                                  DATA   AGE
# secret/azure-arc-connect-privatekey       Opaque                                1      19m
# secret/azure-arc-onboarding               Opaque                                1      21m
# secret/azure-arc-operatorsa-token-wwlwp   kubernetes.io/service-account-token   3      21m
# secret/default-token-fs67k                kubernetes.io/service-account-token   3      21m

kubectl get pods -n azure-arc

# Review the container logs
kubectl -n azure-arc logs -l app.kubernetes.io/component=connect-agent -c connect-agent

# DANGER ZONE

sudo az connectedk8s delete \
  --name $K8S_NAME \
  --resource-group $RG_ARC \
  --kube-context $K8S_NAME \
  --yes

# Check the list of connected clusters
az connectedk8s list -o table

# If you wish to remove Azure Arc, you can simply delete the helm installation
helm delete azure-arc

# Diagnostics after removal:
NAMESPACE=itops
kubectl proxy & kubectl get namespace $NAMESPACE -o json | jq '.spec = {"finalizers":[]}' > temp.json
curl -k -H "Content-Type: application/json" -X PUT --data-binary @temp.json 127.0.0.1:8001/api/v1/namespaces/$NAMESPACE/finalize

# If you have evicted pods, delete them via
kubectl get pods -n azure-arc -ojson \
  | jq -r '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) | .metadata.name + " " + .metadata.namespace' \
  | xargs -n2 -l bash -c 'kubectl delete pods $0 --namespace=$1'


# To force delete the azure-arc namespace (last resort if arc namespace stuck in terminating state):
kubectl delete namespace azure-arc --grace-period=0 --force