# EC2 Instance Creation 

1. Clone this repository:
```
git clone https://github.com/chrisadkin/Consul-Peering.git
```

2. Change directory 
```
cd Prereqs/AWS-Minikube
```

3. Setup the AWS environment variables required by the AWS provider:
```
export AWS_ACCESS_KEY_ID=<your AWS ACCESS KEY ID goes here>
export AWS_SECRET_ACCESS_KEY=<your ACCESS KEY SECRET goes here>
export AWS_SESSION_TOKEN=<your AWS SESSION TOKEN goes here>
export AWS_SESSION_EXPIRATION=<your AWS SESSION EXPIRATION string goes here>
```

4. Initialise the configuration in order to download and installed the required providers:
```
terraform init
```

5. Apply the configuration:
```
terraform apply -auto-approve
```

** Note that this configuration has been tested with the variables specified in the variables.tf file as follows:**
- vpc_cidr                          = "10.11.0.0/16"
- public_subnet_cidr                = "10.11.1.0/24"
- aws_region                        = "us-west-2"
- linux_instance_type               = "t3a.xlarge"
- linux_associate_public_ip_address = true
- linux_root_volume_size            = 20
- linux_root_volume_type            = "gp2"
- linux_data_volume_size            = 10
- linux_data_volume_type            = "gp2"

6. Once the configuration has been applied, make a note of the output string, this is the ssh command that should be used for connecting to
   the EC2 instance, below is an example of what this looks like:
```
Outputs:

ssh_command = "ssh -i linux-key-pair.pem ec2-user@54.200.208.185"
```

7. Change the permissions on the linux-key-pair.pem file, note that ssh'ing into your EC2 instance will not work until this is done:
```
chmod 400 linux-key-pair.pem
```
   
# Minikube Cluster Creation

1. Use the ssh command obtained from applying the Terraform configuration to log into the EC2 instance, e.g.:
```
ssh -i linux-key-pair.pem ec2-user@54.200.208.185
```

2. Note the contents of the minikube_setup.sh file, this is what will be used to:

- Install docker
- Install minikube
- Create two minikube instances

3. Run the following commands in the exact order they appear in here to install docker:
```
sudo yum update -y
sudo yum install -y yum-utils
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
sudo dnf install --best --assumeyes docker-ce
sudo usermod -aG docker $USER && newgrp docker
sudo systemctl start docker
```

4. To install minikube run the following commands, again, this should be done in the same exact order in which they ar listed:
```
sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo rpm -Uvh minikube-latest.x86_64.rpm
sudo yum update -y
```

5. Create the two minikube cluster, one for each consul dc:
```
minikube start -p dc1
minikube start -p dc2
```

# Configure MetalLb

1. Check that the minikube metallb add on is available for the dc1 cluster:
```
minikube addons -p dc1 list | grep metallb
```
   This is the expected output: 
```
| metallb                     | dc1     | disabled     | 3rd party (MetalLB)            |
```

2. Enable metallb for cluster dc1:
```
minikube addons -p dc1 enable metallb
```

3. Configure the IP address pool for metallb:
```
minikube addons -p dc1 configure metallb
```
   Below are example values used for dc1 and output, the IP address range will be dependant upon the EC2 instance VPC:
```
-- Enter Load Balancer Start IP: 10.11.1.70
-- Enter Load Balancer End IP: 10.11.1.80
    ▪ Using image docker.io/metallb/speaker:v0.9.6
    ▪ Using image docker.io/metallb/controller:v0.9.6
✅  metallb was successfully configured
```

4. Check that configuration details entered are reflected in the metallb config map:

```
kubectl config use_context dc1
kubectl get configmap/config -n metallb-system -o yaml
```
   Example output:   
```
apiVersion: v1
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.11.1.70-10.11.1.80
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"config":"address-pools:\n- name: default\n  protocol: layer2\n  addresses:\n  - 10.11.1.70-10.11.1.80\n"},"kind":"ConfigMap","metadata":{"annotations":{},"name":"config","namespace":"metallb-system"}}
  creationTimestamp: "2023-03-08T13:18:17Z"
  name: config
  namespace: metallb-system
  resourceVersion: "3302"
  uid: f8e38c33-88f4-4a56-8e6b-751e61091bb6
```

5. Repeat steps 1 through to 3, replacing all references to **dc1** with **dc2**, also the IP address range used when configuring metallb
   should not overlap the range used for 

# Install Client Tools

1. Install kubectl:
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

2. Test kubectl:
```
kubectl config get-contexts
```
This should result in the following output:
```
CURRENT   NAME   CLUSTER   AUTHINFO   NAMESPACE
          dc1    dc1       dc1        default
*         dc2    dc2       dc2        default
```

3. Install Helm:
```
sudo yum install wget
wget https://get.helm.sh/helm-v3.11.1-linux-amd64.tar.gz
tar xvf helm-v3.11.1-linux-amd64.tar.gz
cd linux-amd64/
sudo mv helm /usr/local/bin/.
```

4. Install git:
```
sudo yum install git
```
