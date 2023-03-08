- Minikube Cluster Creation

-- Running The Terraform Configuration 

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
   the EC2 instance:
   
