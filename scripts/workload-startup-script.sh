#!/bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

# Install Docker and Git
sudo apt-get install -y docker.io git

# clone Node.js Project
git clone https://github.com/Mostafa-Yehia/simple-node-app.git

# Build a Docker image
cd simple-node-app

#####################################
# docker script
#####################################

cat > Dockerfile << EOF
# the image used Node which contains version 14 of Node and NPM
FROM node:14

WORKDIR /app

# this file holds declaration for packages
COPY package*.json ./

# Install npm packages
RUN npm install

# Copy application files into the container
COPY . .

# Expose the port 3000 for node app to work
ENV WEBport 3000

# Set MongoDB user, password, and hosts
ENV DBuser test
ENV DBpass test123
ENV DBhosts mongo-0.mongo:27017

# Start your application
CMD ["node", "index.js"]

EOF

###############################
##### End of docker file
###############################

docker build -t node-app -f Dockerfile .



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


sudo docker tag node-app "us-east1-docker.pkg.dev/gcp-terraform-as/gcp-terraform-as-repo/node-app:latest"

sudo docker push "us-east1-docker.pkg.dev/gcp-terraform-as/gcp-terraform-as-repo/node-app:latest"

sudo docker pull bitnami/mongodb:latest

sudo docker tag bitnami/mongodb:latest "us-east1-docker.pkg.dev/gcp-terraform-as/gcp-terraform-as-repo/mongodb:latest"

sudo docker push "us-east1-docker.pkg.dev/gcp-terraform-as/gcp-terraform-as-repo/mongodb:latest"