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
