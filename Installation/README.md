# Deploy Consul on first Kubernetes cluster (dc1).

1. Clone this repo
```
git clone https://github.com/chrisadkin/Cluster-Peering.git
```

2. Nagivate to the **cluster-peering-failover-demo/countingapp** folder. 

```
cd Cluster-Peering/Manifests
```

3. Set environemetal variables for kubernetes cluster dc1 and dc2

```
export dc1=<your-kubernetes context-for-dc1>
export dc2=<your-kubernetes context-for-dc2>
export VERSION=1.0.0
```

4. Set context and deploy Consul on dc1

```
kubectl config use-context $dc1
``` 

```
helm install $dc1 hashicorp/consul --version $VERSION --values consul-values.yaml                                  
```

5. Confirm Consul deployed sucessfully

```
kubectl get pods --context $dc1
NAME                                               READY   STATUS    RESTARTS   AGE

dc1-consul-connect-injector-6694d44877-jvp4s       1/1     Running   0          2m
dc1-consul-mesh-gateway-747c58b75c-s68n7           2/2     Running   0          2m
dc1-consul-server-0                                1/1     Running   0          2m
dc1-consul-webhook-cert-manager-669bb6d774-sb5lz   1/1     Running   0          2m
```  
Note: Run ```kubectl get crd``` and make sure that exportedservices.consul.hashicorp.com, peeringacceptors.consul.hashicorp.com, and peeringdialers.consul.hashicorp.com  exist.    
If not, you need to upgrade your helm deployment:  
    
```
helm upgrade $dc1 hashicorp/consul  --version $VERSION --values consul-values.yaml
```

6. Deploy both dashboard and counting service on dc1
```
kubectl apply -f dashboard.yaml --context $dc1
kubectl apply -f counting.yaml --context $dc1
```

7. Using your browser, check the dashboard UI and confirm the number displayed is incrementing. 
   You can get the dashboard UI's EXTERNAL IP address with command below. Make sure to append port :9002 to the browser URL.  
```   
kubectl get service dashboard --context $dc1
```

Example: 
```
kubectl get service dashboard --context $dc1
NAME        TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)          AGE
dashboard   LoadBalancer   10.0.179.160   40.88.218.67  9002:32696/TCP   22s
```


![alt text](https://github.com/vanphan24/cluster-peering-failover-demo/blob/main/images/dashboard-beofre.png)


**This is your current configuration:**  
![alt text](https://github.com/vanphan24/cluster-peering-failover-demo/blob/main/images/diagram-before2.png)



# Deploy Consul on second Kubernetes cluster (dc2).


1. Set context and deploy Consul on dc2

```
kubectl config use-context $dc2
```
```
helm install $dc2 hashicorp/consul --version $VERSION --values consul-values.yaml --set global.datacenter=dc2
```

Note: Run ```kubectl get crd``` and make sure that exportedservices.consul.hashicorp.com, peeringacceptors.consul.hashicorp.com, and peeringdialers.consul.hashicorp.com  exist.    
If not, you need to upgrade your helm deployment:  

```
helm upgrade $dc2 hashicorp/consul  --version $VERSION --values consul-values.yaml
```

2. Deploy counting service on dc2. This will be the failover service instance.

```
kubectl apply -f counting.yaml --context $dc2
```
