#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker and Git
sudo apt-get install -y docker.io git


cd /tmp

wget --header="Metadata-Flavor: Google" -O key.json http://metadata.google.internal/computeMetadata/v1/instance/attributes/service-account-key

#decrypt the key to its json format
cat key.json | base64 -d > sa.json

#Activate service account with key

gcloud auth activate-service-account --key-file=sa.json

#Authenticate to Docker
echo "y" | gcloud auth configure-docker us-east1-docker.pkg.dev


# Login
cat key.json | docker login -u _json_key_base64 --password-stdin \
https://us-eastl-docker.pkg.dev


# pull node.js app

sudo docker pull moelshafei/nodeapp:latest

sudo docker tag moelshafei/nodeapp:latest "us-east1-docker.pkg.dev/gcp-terraform-as/gcp-terraform-as-repo/node-app:latest"

sudo docker push "us-east1-docker.pkg.dev/gcp-terraform-as/gcp-terraform-as-repo/node-app:latest"

sudo docker pull bitnami/mongodb:4.4.4

sudo docker tag bitnami/mongodb:4.4.4 "us-east1-docker.pkg.dev/gcp-terraform-as/gcp-terraform-as-repo/mongodb:latest"

sudo docker push "us-east1-docker.pkg.dev/gcp-terraform-as/gcp-terraform-as-repo/mongodb:latest"

# Deploy the proxy 
sudo apt install tinyproxy -y

# Open the Tinyproxy configuration file with sudo and append 'Allow localhost' to it
sudo sh -c "echo 'Allow localhost' >> /etc/tinyproxy/tinyproxy.conf"

# Restart tinyproxy
sudo service tinyproxy restart

# Install the kubernetes commandline client
sudo apt update

sudo apt-get install kubectl 
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin 

export KUBECONFIG=$HOME/.kube/config
# Get cluster credentials and set kubectl to use internal ip
gcloud container clusters get-credentials workload-cluster --zone us-central1 --project gcp-terraform-as --internal-ip

# Enabling control plane private endpoint global access
gcloud container clusters update workload-cluster --zone us-central1 --enable-master-global-access