#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker and Git
sudo apt-get install -y docker.io git

# clone Node.js Project
git https://github.com/Mostafa-Yehia/simple-node-app.git

# Build a Docker image
cd simple-node-app

docker build -t NodeApp -f ../Dockerfile .

gcloud auth activate-service-account --key-file=../secrets/gcp-terraform-as.json

gcloud auth configure-docker

docker tag NodeApp "us-central1-docker.pkg.dev/gcp-terraform-as/gcp-terraform-as-repo/NodeApp:latest"

docker push "us-central1-docker.pkg.dev/gcp-terraform-as/gcp-terraform-as-repo/NodeApp:latest"
