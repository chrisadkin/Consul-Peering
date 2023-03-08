# Deploy Consul on first Kubernetes cluster (dc1)

1. If required there is a Terraform code to deploy a cluster ---> DC1/DC1-K8cluster

2. You can run terraform plan and deploy within the directory to build a cluster will take several minutes

3. Set environemetal variables for kubernetes cluster dc1 and dc2 (Optional)

```
export dc1=<your-kubernetes context-for-dc1>
export dc2=<your-kubernetes context-for-dc2>
export VERSION=1.0.0
```

4. Set context and deploy Consul on dc1

```
kubectl config use-context $dc1
``` 

5. Create the secret that contains the license key string for Consul
```
kubectl create ns consul
secret=$(cat consul.hclic)
kubectl create secret generic consul-ent-license --from-literal="key=${secret}" -n consul
```

6. Deploy the Consul Helm chart

```
cd DC1/01-AP-default-default-failover/
helm install $dc1 hashicorp/consul --version $VERSION --values config-dc1.yaml --namespace consul --wait                                 
```

7. Confirm Consul deployed sucessfully

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
cd DC1/01-AP-default-default-failover/countingapp

6. Deploy both dashboard and counting service on dc1
```
files located in DC1/01-AP-default-default-failover/countingapp/
kubectl apply -f dashboard.yaml --context $dc1
kubectl apply -f counting.yaml --context $dc1
```
![image](https://user-images.githubusercontent.com/81739850/221881212-5bc9696b-1bb9-44ed-8ca7-3ab5b28c4406.png)



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

![image](https://user-images.githubusercontent.com/81739850/221881398-042c9425-217a-4684-a16d-3e1872d1aea0.png)



# Deploy Consul on second Kubernetes cluster (dc2).


8. Set context and deploy Consul on dc2 ----> Terraform files to build a cluser can be found in DC2/02-AP-diffAP-failover/DC2-K8cluster/

```
kubectl config use-context $dc2
```
```
helm install $dc2 hashicorp/consul --version $VERSION --values config-dc2.yaml --set global.datacenter=dc2
```

Note: Run 

```kubectl get crd``` 

and make sure that exportedservices.consul.hashicorp.com, peeringacceptors.consul.hashicorp.com, and peeringdialers.consul.hashicorp.com  exist.    
If not, you need to upgrade your helm deployment:  

```
helm upgrade $dc2 hashicorp/consul  --version $VERSION --values config-dc2.yaml
```

9. Deploy counting service on dc2. This will be the failover service instance.

files can be located in DC2/01-AP-default-default-failover/countingapp/

```
kubectl apply -f counting.yaml --context $dc2
```
