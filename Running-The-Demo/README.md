# Cluster Peering Failover Demonstration

## DIRECTORY INDEX

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

[1. Deploying Consul](https://github.com/chrisadkin/Consul-Peering/tree/main/Installation)  

[2. Cluster Peering Connection Creation](https://github.com/chrisadkin/Consul-Peering/tree/main/Installation)  


19. Delete the counting service on dc1
```
kubectl delete -f counting.yaml --context $dc1
```

20. Observe the dashboard service on your browser. You should notice that the counter has restarted since the dashboard is connecting to different counting service instance.

![alt text](https://github.com/vanphan24/cluster-peering-failover-demo/blob/main/images/dashboard-failover.png)

**This is your current configuration:**  
![alt text](https://github.com/vanphan24/cluster-peering-failover-demo/blob/main/images/Screen%20Shot%202022-09-13%20at%205.13.46%20PM.png "Cluster Peering Demo")


![image](https://user-images.githubusercontent.com/81739850/221921318-28751993-df61-416e-9469-6b51728b8c7c.png)


21. Bring counting service on dc1 back up.
```
kubectl apply -f counting.yaml --context $dc1
```
![image](https://user-images.githubusercontent.com/81739850/221921950-3a5b5d38-496c-4ead-92c2-7d044a9623c3.png)


22. Observe the dashboard service on your browser. Notice the the dashboard URL shows the counter has restarted again since it automatically fails back to the original service on dc1.


# (Optional) Deploy Consul (dc3) on EKS Cluster and peer between dc1 as dc3.

![image](https://user-images.githubusercontent.com/81739850/221881568-a6f11dc6-dacf-4f7b-9c8e-c570ebe822eb.png)


This portion is optional if you want to failover to AWS Elastic Kubernetes Service (EKS).   
We will create a peering connection between dc1 and dc3 (on EKS) and failover the counting service to dc3.
This portion assumes you already have an Elastic Kubernetes Service (EKS) cluster deployed on AWS.  


1. Connect your local terminal to your EKS cluster.

Terraform files can be located DC3/DC3-K8cluster to build a cluster

```
aws eks --region <your-aws-region> update-kubeconfig --name <your-eks-cluster-name>
```

2. Set environment variable for your dc3 context.  
   Note: You can find your EKS context using ```kubectl config get-contexts```

```
export dc3=<your EKS cluster context>
```

3. Set context and deploy Consul **dc3** onto your EKS cluster.

```
kubectl config use-context $dc3
``` 
```
helm install $dc3 hashicorp/consul --version $VERSION --values apservice-dc3.yaml.yaml --set global.datacenter=dc3
```
  

Note: Run ```kubectl get crd``` and make sure that exportedservices.consul.hashicorp.com, peeringacceptors.consul.hashicorp.com, and peeringdialers.consul.hashicorp.com  exist.  
	
	If not, you need to upgrade your helm deployment:    
	
	```helm upgrade $dc3 hashicorp/consul --version $VERSION --values apservice-dc3.yaml.yaml```

5. A

```
kubectl apply -f meshgw.yaml --context $dc1
```


5. Establish Peering connection between dc1 and dc3. This time, we can use the Consul UI.

  - Log onto Consul UI for dc1, navigate to the Peers side tab on the left hand side.
  - Click on **Add peer connection***
  - Enter a name you want to represent the peer that you are connecting to (ex: dc3). 
  - Click **Generate token**
  - Copy the newly created token.
  - Log onto Consul UI for dc3, navigate to the Peers side tab on the left hand side.
  - Click on **Add peer connection***
  - Click on **Establish peering**
  - Enter a name you want to represent the peer that you are connecting to (ex: dc1).
  - Paste the token and click **Add peer**
  - Your peering connection should be established.

**Peering Connection is how established between dc1 and dc3**

5. Configure Consul to use mesh gateway to establish the cluster peering.

```
kubectl apply -f meshgw.yaml --context $dc3
```

7. Deploy counting service on dc3.
```
kubectl apply -f counting.yaml --context $dc3
```
8. Export counting services from dc3 to dc1 using the same exportedsvc-backend.yaml file. This will allow the the counting service to be reachable by the dashboard service in dc1
```
kubectl apply -f exportedsvc-counting.yaml --context $dc3
```

9. Edit the service-resolver.yaml file by adding ```- peer: 'dc3'``` as one of the targets. 


It should look like below. Make sure the name of the peer in the service-resolver file matches the name to gave for each peer when you established peering (either in the UI or using CRD acceptor and dialer files).
```
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceResolver
metadata:
  name: counting
spec:
  connectTimeout: 15s
  failover:
    '*':
      targets:
        - peer: 'dc2'
        - peer: 'dc3'
```

10. Apply the file to dc1
```
kubectl apply -f service-resolver.yaml --context $dc1
```

	
11. If you have deny-all intentions set or if ACL's are enabled (which means deny-all intentions are enabled), set intentions using intention.yaml file.
```
kubectl apply -f intentions.yaml --context $dc3
```

12. Now let's test the failover by failing the counting service on both dc1 and dc2.
```
kubectl delete -f counting.yaml --context $dc1
kubectl delete -f counting.yaml --context $dc2
```

13. Back on your browser, check the dashboard UI to see the counter has reset and is running.


cluster-client-connectivity & failover-demo
This demo will showcase the ability to connect a client kubernetes cluster into DC1 and failover services between two Consul clusters (default and partition1) that have been connected via consuld ataplane. 

# Deploy Consul on client Kubernetes cluster to connect to kubernetes server cluster (dc1).

1 If required there is a Terraform code to deploy a cluster ---> DC3/DC3-K8cluster

2 You can run terraform plan and deploy within the directory to build a cluster will take several minutes

3. Copy the server certificate to the non-default partition cluster running your workloads

```
kubectl get secret --namespace consul consul-ca-cert -o yaml | \
kubectl --context arn:aws:eks:us-east-2:711129375688:cluster/<cluster name> apply --namespace consul -f -
```

4. Copy the server key to the non-default partition cluster running your workloads.

```
kubectl get secret --namespace consul consul-ca-key -o yaml | \
kubectl --context arn:aws:eks:us-east-2:711129375688:cluster/<cluster name> apply --namespace consul -f -
```
5. If ACLs were enabled in the server configuration values file, copy the token to the non-default partition cluster running your workloads.

```
kubectl get secret --namespace consul consul-partitions-acl-token -o yaml | \
kubectl --context arn:aws:eks:us-east-2:711129375688:cluster/<cluster name>  apply --namespace consul -f -

```

6. Find expose server in DC1 to establish connection from client cluster

```
kubectl get svc -n consul # on DC1

NAME                             TYPE           CLUSTER-IP       EXTERNAL-IP                                                               PORT(S)
consul-consul-expose-servers     LoadBalancer   172.20.230.215   a1fecfc8ccdd74b37b5273d7da904e79-1244336522.us-east-2.elb.amazonaws.com   8501:31424/TCP,8301:30094/TCP,8300:31439/TCP,8502:31755/TCP

```

7. find kubernetes master on the client side kubernetes cluster, place the master aputput into the k8sAuthMethodHost: 


```
kubectl cluster-info 

Kubernetes master is running at https://6FA8E20A2D3D90DC7DFC6B39B761BE52.sk1.us-east-2.eks.amazonaws.com
CoreDNS is running at https://6FA8E20A2D3D90DC7DFC6B39B761BE52.sk1.us-east-2.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

```
```
helm install -f config.yaml consul hashicorp/apservice-dc3.yaml -n consul --debug

kubectl get pods -n consul

NAME                                 READY   STATUS      RESTARTS   AGE
consul-consul-partition-init-zzmsz   0/1     Completed   0          3h52m

```
 
