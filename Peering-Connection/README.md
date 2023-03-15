# Create cluster peering connection

You can establish the peering connections using the Consul UI or using Kubernetes CRDs. The steps using the UI are extremely easy and straight forward so we will focus on using the Kubernetes CRDs in this section.

10. If your Consul clusters are on different non-routable networks (no VPC/VPN peering), then you will need to set the Consul servers (control plane) to use mesh gateways to request/accept peering connection. Just apply the meshgw.yaml file on both Kubernetes cluster. 


```
kubectl apply -f meshgw.yaml --context $dc1
kubectl apply -f meshgw.yaml --context $dc2
```


**If you prefer to use the UI to establish the peered connection, the general steps are:**
  - Log onto Consul UI for dc1, navigate to the Peers side tab on the left hand side.
  - Click on **Add peer connection***
  - Enter a name you want to represent the peer that you are connecting to. 
  - Click **Generate token**
  - Copy the newly created token.
  - Log onto Consul UI for dc2, navigate to the Peers side tab on the left hand side.
  - Click on **Add peer connection***
  - Click on **Establish peering**
  - Enter a name you want to represent the peer that you are connecting to.
  - Paste the token and click **Add peer**
  - Your peering connection should be established.


**To establish the peered connection using Kubernetes CRDs, the steps are:**


11. Create Peering Acceptor on dc1 using the provided acceptor-on-dc1-for-dc2.yaml file.
Note: This step will establish dc1 as the Acceptor.
```
kubectl apply -f  acceptor-on-dc1-for-dc2.yaml --context $dc1
```

12. Notice this will create a CRD called peeringacceptors.
```
kubectl get peeringacceptors --context $dc1
NAME   SYNCED   LAST SYNCED   AGE
dc2    True     2m46s         2m47s
```

Notice a secret called peering-token-dc2 is created.
```
kubectl get secrets --context $dc1
```

13. Copy peering-token-dc2 from dc1 to dc2.
```
kubectl get secret peering-token-dc2 --context $dc1 -o yaml | kubectl apply --context $dc2 -f -
```

14. Create Peering Dialer on dc2 using the provided dialer-dc2.yaml file.  

Note: This step will establish dc2 as the Dialer and will connect Consul on dc2 to Consul on dc1 using the peering-token.
```
kubectl apply -f  dialer-dc2.yaml --context $dc2
```

15. Export counting service from dc2 to dc1.

```
kubectl apply -f exportedsvc-counting.yaml --context $dc2
```

16. Apply service-resolver file on dc1. This service-resolver.yaml file will tell Consul on dc1 how to handle failovers if the counting service fails locally. 

Note: Make sure the name of the peer in the service-resolver file matches the name to gave for each peer when you established peering (either in the UI or using CRD acceptor and dialer files).

```
kubectl apply -f service-resolver.yaml --context $dc1
```

17. If you have deny-all intentions set or if ACL's are enabled (which means deny-all intentions are enabled), set intentions using intention.yaml file.  

Note: The UI on Consul version 1.14 does not yet recognize peers for Intention creation. Therefore apply intentions using the CLI, API, or CRDs.

```
kubectl apply -f intentions.yaml --context $dc2
```

18. Apply the proxy-defaults on both datacenters to ensure data plane traffic goes via local mesh gateways 
```
kubectl apply -f proxydefaults.yaml --context $dc1
kubectl apply -f proxydefaults.yaml --context $dc2
```

19. Delete the counting service on dc1
```
kubectl delete -f counting.yaml --context $dc1
```

20. Observe the dashboard service on your browser. You should notice that the counter has restarted since the dashboard is connecting to different counting service instance.

![alt text](https://github.com/vanphan24/cluster-peering-failover-demo/blob/main/images/dashboard-failover.png)

**This is your current configuration:**  
![alt text](https://github.com/vanphan24/cluster-peering-failover-demo/blob/main/images/Screen%20Shot%202022-09-13%20at%205.13.46%20PM.png "Cluster Peering Demo")


21. Bring counting service on dc1 back up.
```
kubectl apply -f counting.yaml --context $dc1
```


22. Observe the dashboard service on your browser. Notice the the dashboard URL shows the counter has restarted again since it automatically fails back to the original service on dc1.


# (Optional) Deploy Consul (dc3) on EKS Cluster and peer between dc1 as dc3.


This portion is optional if you want to failover to AWS Elastic Kubernetes Service (EKS).   
We will create a peering connection between dc1 and dc3 (on EKS) and failover the counting service to dc3.
This portion assumes you already have an Elastic Kubernetes Service (EKS) cluster deployed on AWS.  

![image](https://github.com/vanphan24/cluster-peering-failover-demo/blob/main/images/Screen%20Shot%202022-09-22%20at%2011.02.29%20AM.png)


1. Connect your local terminal to your EKS cluster.

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
helm install $dc3 hashicorp/consul --version $VERSION --values consul-values.yaml --set global.datacenter=dc3
```
  

Note: Run ```kubectl get crd``` and make sure that exportedservices.consul.hashicorp.com, peeringacceptors.consul.hashicorp.com, and peeringdialers.consul.hashicorp.com  exist.  
	
	If not, you need to upgrade your helm deployment:    
	
	```helm upgrade $dc3 hashicorp/consul --version $VERSION --values consul-values.yaml```

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


