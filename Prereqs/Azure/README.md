# Azure Kubernetes Service Cluster Creation

## Prerequisites

- [terraform](https://developer.hashicorp.com/terraform/downloads)
- [kubectl cli](https://kubernetes.io/docs/reference/kubectl/)
- [krew](https://krew.sigs.k8s.io/)
- [konfig](https://krew.sigs.k8s.io/) 
- [git](https://git-scm.com/)
- An Azure account
- A command shell that supports simple Linux commands such as export

## Prerequisites

1. Clone this repository:
```
git clone https://github.com/chrisadkin/Consul-Peering.git
```
2. Change directory into the Azure-Prereqs directory

3. The default variable settings will result in the deployment of two AKS clusters, each:
- With one node
- A node VM size of Standard_D3_v2
- Deployed to the "US West 2" region

  change the values of these in the variables.tf file if so required using the text editor of your choosing

4. Create a file called terraform.tfvars, add a single line to this as follows:
```
kubeconfig_directory = <path to your .kube directory>
```
   The convention is for a .kube directory to exist or be created under your home directory, for example if this is
   /Users/chris.adkin, the terraform.tfvars file would contain:
```
   /Users/chris.adkin/.kube
```

5. Install the terraform plugins:
```
terraform init
```

6. Set the environment variables with the values of your Azure subscription id and tennant id:
```
export ARM_SUBSCRIPTION_ID=<your Azure subscription id goes here>
export ARM_TENANT_ID=<your Azure tenant id goes here>
```

7. Apply the terraform configuration:
```
terraform apply -auto-approve
```

8. Change directory to one specified in the terraform.tfvars file.

9. The kube config directory should contain two new files: 
- dc1.config
- dc2.config

  If you already have a config file, create a backup copy of it:
```
cp config config.bak
```

  Merge these into the config file as follows:
```
kubectl konfig import -s dc1.config
kubectl konfig import -s dc2.config
```

10. Check that you have a cluster context for each cluster:
```
kubectl config get-contexts
```
   This should produce output which looks like the following:
```
CURRENT   NAME             CLUSTER          AUTHINFO                                NAMESPACE
*         aks-consul-dc1   aks-consul-dc1   clusterUser_aks-consul_aks-consul-dc1   
          aks-consul-dc2   aks-consul-dc2   clusterUser_aks-consul_aks-consul-dc2 
```
    
