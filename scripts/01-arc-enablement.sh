#********* Subscription Resource Providers for Arc *********#

#################################
# Azure CLI                     #
#################################
# Installation docs: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest
# (no need for it if you are using Azure Cloud Shell or have it already installed)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Or update existing Azure CLI (currently I'm using 2.3.0+)
sudo apt-get update && sudo apt-get install --only-upgrade -y azure-cli

###################################
# Register Arc Resource Providers #
###################################
az feature register --namespace Microsoft.Kubernetes --name previewAccess
az feature register --namespace Microsoft.KubernetesConfiguration --name sourceControlConfiguration

# Verify private access
az feature list -o table | grep Kubernetes
# You should see:
# Microsoft.Kubernetes/previewAccess                                                Registered
# Microsoft.KubernetesConfiguration/SourceControlConfiguration                      Registered

# Check the registration status (look for RegistrationState is Registered)
az provider show -n Microsoft.Kubernetes -o table
az provider show -n Microsoft.KubernetesConfiguration -o table

#################################
# Get the extensions            #
#################################
az extension add --name connectedk8s
az extension add --name k8sconfiguration

# Check installed extensions
az extension list -o table
# False           whl              k8sconfiguration   /home/localadmin/.azure/cliextensions/k8sconfiguration   True       0.1.8  
# False           whl              connectedk8s       /home/localadmin/.azure/cliextensions/connectedk8s       True       0.2.1  

# if you have existing extensions installed but need update
az extension update --name connectedk8s
az extension update --name k8sconfiguration

#################################
# Helm 3                        #
#################################
# Helm 3 Installation (https://helm.sh/docs/intro/install/)
wget https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod -R +x .
./get-helm-3

# OR
# curl -sL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | sudo bash

helm version
# version.BuildInfo{Version:"v3.1.2", GitCommit:"d878d4d45863e42fd5cff6743294a11d28a9abce", GitTreeState:"clean", GoVersion:"go1.13.8"}

#********* Subscription Resource Providers for Arc *********#