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
