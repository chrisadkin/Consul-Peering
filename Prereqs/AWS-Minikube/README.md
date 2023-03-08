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
