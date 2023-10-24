# GCP Terraform Project
This project holds declarations for resources to create and deploy infrastructure for your project. it has a 3-node cluster each holds a node app and stateful MongoDB.
We will break it down so you can create your own infrastructure using this repo.

## Tools & prerequisites: 

- [x] Terraform installed. [Terraform Official Page](https://www.terraform.io/)
- [x] VS Code - to edit the code or any text editor you like. [VS Code Download Page](https://code.visualstudio.com/Download)
- [x] Account on GCP (Google Cloud Platform) to create a project [Google Console](https://console.cloud.google.com/?hl=en)
- [x] Linux OS or Windows ( but Linux is preferred)
- [x] Google SDK installed [Installation Page](https://cloud.google.com/sdk/docs/install)
- [X] Allow some APIs from the GCP Console
  - Compute Engine API: to create an instance, GKE, and Network.
  - Kubernetes Engine API
  - Artifact Registry API: to allow pushing to the Artifact Repo.

## Service Account in Terraform

After you completed the prerequisites, now it is time to kick off. 
Firstly, go to [IAM and Admin](https://cloud.google.com/iam/docs/understanding-roles?hl=en&_ga=2.78860308.-1259743793.1696456487&_gac=1.16844747.1697486513.CjwKCAjwvrOpBhBdEiwAR58-3N1gjCWR2DmCANH4ix00IrGV--9v6cnsLcAZmzavDXeJOm1a9QUlcBoC1IcQAvD_BwE#predefined_roles)
and create a new service account on the panel on the left. give it a role **Editor**. At this point, you created the service account; therefore, you need to create the key and download it.

> [!WARNING]
> **Warning:** Security Issue.
> Please ensure that no one has this file but you, because it will be used to create the resources and you don't want anyone use the account to create **their resources**

### Use Service Account Key:

To use this key after you clone the project, head to the `secrets` directory and paste your key file. make sure it is named correctly in the `1-provider.tf` file.

Now you are good to go to create the resources.

### Service Account Roles:
1. Editor: to create Resources.
2. Project IAM Admin: to create and assign roles for other accounts will be created.

## IaC

now it is the part when we will talk about what we are going to deploy.
1. VPC: this is the network we will be using to deploy the resources.
2. Subnets: we have two subnets: one for the management instance and one for the workload cluster GKE we will be creating.
3. Nat Service: to allow the management instance to download the required packages and push docker images to the artifact repo.
4. Firewall Rules: to deny all incoming traffic to machines, and only allow IAP ( Identity-Aware Proxy)
5. Management Instance: This will hold the point of access to the cluster and will do most of the logical work for us.
6. GKE: the Cluster for Kubernetes on GCP and a service account associated with it to download the docker images will be pushed on Artifact Registry.
7. Artifact Repo: will create a repo on Artifact Registry and a service account attached to the management instance to push images to the repo.

We also have a list of variables that will be used for the project like project_id. it is already simple.

## Use Case: 

We, as developers, will connect using ssh into the management instance but using IAP by the following command: 
`gcloud compute ssh MANAGEMENT_INSTANCE_NAME --tunnel-through-iap --project=PROJECT_ID --zone=ZONE_GOES_HERE`
this will open a tunnel to log into the machine without a public IP. this is more secure. 

> [!NOTE]
> **Note** IAP Documentation
> Please go to the following link if you want to read more about the IAP [IAP Documentation](https://cloud.google.com/iap?hl=en)

Then we have a startup script, which we will talk about soon, that will run when the instance is up. it does many things: one of them is to dockerize images and push them to Artifact Repo to be used in the GKE.

Then we have the `k8s` Directory that will hold the declaration for Kubernetes deployment and application.

one way to use this is by proxy to the management machine we created before and let it carry the commands and files to the private GKE we created earlier. we will touch on this part later on. 

## Startup Script

This startup script is taking a crucial step in the project. The script simply initializes the management instance, Pulling and Pushing images into the Artifact Repository. 
So here is a breakdown of what the startup script does.

- [x] Updating Package
- [X] Install Docker
- [x] Downloading service account key associated with the instance. This service account has a set of roles to allow the pushing of images and managing GKE:
  - "roles/source.reader"
  - "roles/artifactregistry.writer"
  - "roles/container.clusterAdmin"
  - "roles/container.admin"
- [x] Authenticating connection with Google Services and Project.
- [x] Pulling, Taging, and Pushing Docker images to Artifact Registry.
- [x] Installing Tinyproxy Package to use the instance as a proxy server.
- [x] Kubectl to manage Kubernetes
- [x] Authenticating with Google services and opening a proxy to the cluster.

## Why adopt this behavior? 
This way is more secure. we connect to the management instance with IAP( Identity-Aware Proxy ) so we only allow the employees in charge of using this instance to connect it with no public IP. In summary, it is more secure than a bastion host. Also, the GKE is private and to access it, we used the management instance as a proxy server to carry out our command and local files like k8s files to the cluster.

## Kubernetes Configurations 
> [!NOTE]
> **Images Used** 
> The images used in the two applications below are retrieved from the Artifact Registry.

### MongoDB
The next list points to the file names in this repo.

1. Contains namespace configuration
2. Passwords for Database and root name
3. Service account to provide the namespace with the required permissions.
4. Environment Variables and Scripts to mark the pods as primary DB or secondary DB as we have two moods for the database.
5. Contains the number of replicas and  the logic of the statfulset of the application
6. Cluster IP to make sure the requests from nodes are defined between nodes and to nodes

### Node App

The following list defines the configuration for the Node App.

1. Contains namespace configuration
2. Has Database Password.
3. Deployment of the application and replicas.
4. Load Balancer Service to balance the traffic to the nodes.


## GKE

This is the left-brain part of the project. the resource is defined in Terraform and with the help of Terraform it makes the cluster configuration readable. So here is a breakdown of the configuration of the cluster.

### Network

The cluster is located in the second subnet in the network that was created earlier and it is private.

```
private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = var.gke_cider
  }
  master_authorized_networks_config {
      cidr_blocks {
          cidr_block = var.first_cider
          display_name = "vm"
      }
    }
```
we also created a cider for the GKE to place its pods and allowed connection to the control plane from the management subnet.

### Deletion

for testing purposes, the cluster does not have deletion protection stated in this line `deletion_protection = false` this allows us to delete the cluster after we are done.

### Node Pool

The cluster has 3 nodes, one in each zone. and named this pool as `my-node-pool`


### Node Configuration

Each node is `preempitible` which means Google can destroy it while I am working and give it to someone else to lower the cost. As mentioned earlier, that was for testing purposes, it was the choice to reduce the cost of the application. 

and gave the disk size of 15 GB to store the items in DataBase.

```
    node_config {
      preemptible  = true
      machine_type = "e2-small"
      disk_type    = "pd-standard"
      disk_size_gb = 15
      service_account = google_service_account.gke-reader-sa.email
      oauth_scopes    = [ 
      "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
```

### Service Account

To make the cluster get images from the Artifact Registry, we need to create a service account and give it an id

```
resource "google_service_account" "gke-reader-sa" {
  account_id   = "gke-reader-sa"
  display_name = "GKE SA to read Images"
}
```

and here is the time to add the role for the email and make it alive

```
resource "google_project_iam_member" "artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.gke-reader-sa.email}"
}
```
## Application Deployment

After we talked about each part of the application, now is the time to run the app
### Authenticate with Google Services

To Authenticate with cluster to allow the proxy, we used the following command 
`gcloud container clusters get-credentials CLUSTER_NAME --zone CLUSTER_REGION --project PROJECT_ID --internal-ip
`

### Proxy from LocalHost
to proxy from your localhost to the cluster, you need to run the following command
`gcloud compute ssh INSTANCE_NAME --tunnel-through-iap --project=PROJECT_ID --zone=VM_ZONE --ssh-flag="-4 -L8888:localhost:8888 -N -q -f"`
this opens the proxy server to forward your commands from local host to the cluster.

To test it, run `kubectl get ns` to get namespaces from the cluster.

### Deploy Kubernetes Files

After Verification form the last step, use the following command to deploy the k8s files.

use one of the following options:
- in the path of `k8s/mongo-db` in the project files, you can run `kubectl apply -f .` where **.** symbolizes the current directory and files.
- in the project root path, run `kubectl apply -f k8s/mongo-db`

The same goes for `node-files`, run `kubectl apply -f k8s/node-files`
# Project Overview

Now after a rich walkthrough of the whole project, you should have done the following:

- Knowledge of the application infrastructure.
- Applied best security practices.
- Launched a management instance and workload cluster.
- Established a proxy connection to the management instance to send commands from localhost to the private cluster.
- Deployed a fully functioning project online that can be used from the NodeJS index.js for frontend and send requests to the database cluster.

# Appreciation

Thanks for following up and i hope you deployed your project as you wanted. In case of any inquiry, please contact me, you can find the contacts on my profile page here 😄 [Profile](https://github.com/abdelrahman-saad)
