# Setting the name of the Arc resources
ARC_PREFIX=gbb-arc
ARC_LOCATION=westeurope
ARC_LOCATION_CODE=weu
RG_ARC=$ARC_PREFIX-rg-$ARC_LOCATION_CODE
ARC_SP_NAME=$ARC_PREFIX-sp

# Creating resource group for saving the Azure Arc registered clusters
az group create --name $RG_ARC -l $ARC_LOCATION -o table

# Service Principal 
# SP will allow your kubernetes cluster to access Azure Arc (with minimum required permissions)
# Arc extension can create the SP automatically (your account should have access to provision SP)
# If not, you can create it separately then provide the details via -onboarding-spn-id and --onboarding-spn-secret

# Creating new SP (with no permissions)
ARC_SP=$(az ad sp create-for-rbac -n $ARC_SP_NAME --skip-assignment)
echo $ARC_SP | jq
ARC_SP_ID=$(echo $ARC_SP | jq -r .appId)
ARC_SP_PASSWORD=$(echo $ARC_SP | jq -r .password)
echo $ARC_SP_ID
echo $ARC_SP_PASSWORD

# OR you can retrieve back existing SP any time:
# ARC_SP=$(az ad sp show --id http://$ARC_SP_NAME)
# ARC_SP_ID=$(echo $ARC_SP | jq -r .appId)
# ARC_SP_PASSWORD="REPLACE_SP_PASSWORD"

# Granting permissions to the SP
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Service principal can register any cluster in an existing Resource Group in the given subscription
az role assignment create \
    --role 34e09817-6cbe-4d01-b1a2-e0eac5743d41 \
    --assignee $ARC_SP_ID \
    --scope /subscriptions/$SUBSCRIPTION_ID

# OR
# Service principal can only register clusters in the Resource Group $RG_ARC
az role assignment create \
    --role 34e09817-6cbe-4d01-b1a2-e0eac5743d41 \
    --assignee $ARC_SP_ID \
    --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG_ARC

az role assignment list \
    --all \
    --assignee $ARC_SP_ID \
    --output json | jq '.[] | {"principalName":.principalName, "roleDefinitionName":.roleDefinitionName, "scope":.scope}'