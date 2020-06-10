# This applies special environment variables for AKS connected clusters

K8S_NAME=$CLUSTER1

SUBSCRIPTION_ACCOUNT=$(az account show)
echo $SUBSCRIPTION_ACCOUNT | jq

# Get the tenant ID
TENANT_ID=$(echo $SUBSCRIPTION_ACCOUNT | jq -r .tenantId)
# or use TENANT_ID=$(az account show --query tenantId -o tsv)
echo $TENANT_ID
# Get the subscription ID
SUBSCRIPTION_ID=$(echo $SUBSCRIPTION_ACCOUNT | jq -r .id)
# or use TENANT_ID=$(az account show --query tenantId -o tsv)
echo $SUBSCRIPTION_ID

export LOCATION=westeurope # Supported prod regions: eastus, westeurope
export MANAGED_CLUSTER_NAME=$K8S_NAME
export MANAGED_CLUSTER_RESOURCE_GROUP=REPLACE


sudo helm upgrade azure-arc azurearcfork8s/azure-k8s-config \
    --install \
    --set global.subscriptionId=${SUBSCRIPTION_ID},global.resourceGroupName=${MANAGED_CLUSTER_RESOURCE_GROUP} \
    --set global.resourceName=${MANAGED_CLUSTER_NAME},global.location=${LOCATION} \
    --set global.tenantId=${TENANT_ID} \
    --debug