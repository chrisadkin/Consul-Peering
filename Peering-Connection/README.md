# Create cluster peering connection

You can establish the peering connections using the Consul UI or using Kubernetes CRDs. The steps using the UI are extremely easy and straight forward so we will focus on using the Kubernetes CRDs in this section.

1. If your Consul clusters are on different non-routable networks (no VPC/VPN peering), then you will need to set the Consul servers (control plane) to use mesh gateways to request/accept peering connection. Just apply the meshgw.yaml file on both Kubernetes cluster. 

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

2. Create Peering Acceptor on dc1 using the provided acceptor-on-dc1-for-dc2.yaml file.
Note: This step will establish dc1 as the Acceptor.
```
kubectl apply -f  acceptor-on-dc1-for-dc2.yaml --context $dc1
```

3. Notice this will create a CRD called peeringacceptors.
```
kubectl get peeringacceptors --context $dc1
NAME   SYNCED   LAST SYNCED   AGE
dc2    True     2m46s         2m47s
```

Notice a secret called peering-token-dc2 is created.
```
kubectl get secrets --context $dc1
```

4. Copy peering-token-dc2 from dc1 to dc2.
```
kubectl get secret peering-token-dc2 --context $dc1 -o yaml | kubectl apply --context $dc2 -f -
```

5. Create Peering Dialer on dc2 using the provided dialer-dc2.yaml file.  

Note: This step will establish dc2 as the Dialer and will connect Consul on dc2 to Consul on dc1 using the peering-token.
```
kubectl apply -f  dialer-dc2.yaml --context $dc2
```

6. Export counting service from dc2 to dc1.

```
kubectl apply -f exportedsvc-counting.yaml --context $dc2
```

7. Apply service-resolver file on dc1. This service-resolver.yaml file will tell Consul on dc1 how to handle failovers if the counting service fails locally. 

Note: Make sure the name of the peer in the service-resolver file matches the name to gave for each peer when you established peering (either in the UI or using CRD acceptor and dialer files).

```
kubectl apply -f service-resolver.yaml --context $dc1
```

8. If you have deny-all intentions set or if ACL's are enabled (which means deny-all intentions are enabled), set intentions using intention.yaml file.  

Note: The UI on Consul version 1.14 does not yet recognize peers for Intention creation. Therefore apply intentions using the CLI, API, or CRDs.

```
kubectl apply -f intentions.yaml --context $dc2
```

9. Apply the proxy-defaults on both datacenters to ensure data plane traffic goes via local mesh gateways 
```
kubectl apply -f proxydefaults.yaml --context $dc1
kubectl apply -f proxydefaults.yaml --context $dc2
```
