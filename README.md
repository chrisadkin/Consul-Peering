# Cluster Peering Failover Demonstration

## Directory Structure

### Peering of DCs

- Helm chart in the DC1 directory and the config files are all in DC1/01-AP-default-default-failover/countingapp
- Helm chart in the DC2 directory and the config files are all in DC2/01-AP-default-default-failover/countingapp
```
DC1 configuration -----> DC1/01-AP-default-default-failover/
DC2 configuration -----> DC2/01-AP-default-default-failover/
```
### Admin Partition on client clusters

Helm chart in the DC1 directory and the config files are all in DC1/02-AP-diffAP-failover/countingapp
- Helm chart in the DC2 directory and the config files are all in DC2/02-AP-diffAP-failover/countingapp
```
DC1 configuration -----> DC1/02-AP-diffAP-failover/
DC2 configuration -----> DC2/02-AP-diffAP-failover/
DC3 configuration -----> DC3/01-AP-default-default-failover/
```
This demo will showcase the ability to failover services between two Consul datacenters (dc1 and dc2) that have been connected via Cluster peering. 
We will deploy a counting app where a dashboard service will connect to the upstream counting service. Both services will reside on dc1.

In this demo another instance of the counting service runs on dc2 a failure of the counting service on dc1 will be simulated by taking down the whole counting service deployment. 

Failover to the counting service residing on dc2 can be observed via the dashboard.

# Prerequisites

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
1. At present there are two Terraform configurations for provisioning the base infrastructure: 
- [Azure Kubernetes Services](https://github.com/chrisadkin/Consul-Peering/tree/main/Prereqs/Azure)  
- [Minikube on AWS EC2 instances](https://github.com/chrisadkin/Consul-Peering/tree/main/Prereqs/AWS-Minikube)  

[2. Deploy Consul](https://github.com/chrisadkin/Consul-Peering/tree/main/Installation)  

[3. Create the Cluster Peering Connection](https://github.com/chrisadkin/Consul-Peering/tree/main/Installation)  

[4. Run the demonstration](https://github.com/chrisadkin/Consul-Peering/tree/main/Running-The-Demo)  
