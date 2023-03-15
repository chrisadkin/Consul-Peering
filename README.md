# Cluster Peering Failover Demonstration

## Prerequisites

## Client Tools Requirements

- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
- [Helm version 3.6 or above](https://helm.sh/docs/intro/quickstart/)
- A command shell that supports basic Linux commands such as export

## Kubernetes Requirements

* A minimum of two Kubernetes cluster with one worker node per cluster
* Node resource requirements are detailed in the [System Requirements section of this Consul reference architecture document](https://developer.hashicorp.com/consul/tutorials/production-deploy/reference-architecture) , the minimum requirements for a node are: 
  * 2 logical processors
  * 8GB RAM
  * 100GB storage
  * Storage performance of 3000 IOPS
  * Storage IO throughput of 75 MB/s

![image](https://github.com/chrisadkin/Consul-Peering/blob/main/images/01-two-dc-configuration.png)

# Instructions for Deploying and Running The Demonstration
[1. At present there are two Terraform configurations for provisioning the base infrastructure:](https://github.com/chrisadkin/Consul-Peering/tree/main/Prereqs) 
- [Azure Kubernetes Services](https://github.com/chrisadkin/Consul-Peering/tree/main/Prereqs/Azure)  
- [Minikube on AWS EC2 instances](https://github.com/chrisadkin/Consul-Peering/tree/main/Prereqs/AWS-Minikube)  

[2. Deploy Consul](https://github.com/chrisadkin/Consul-Peering/tree/main/Installation)  

[3. Create the Cluster Peering Connection](https://github.com/chrisadkin/Consul-Peering/tree/main/Peering-Connection)  

[4. Run the demonstration](https://github.com/chrisadkin/Consul-Peering/tree/main/Running-The-Demo)  
