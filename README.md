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

Then we have `k8s` Directory that will hold the declaration for Kubernetes deployment and application.

one way to use this is by proxy to the management machine we created before and let it carry the commands and files to the private GKE we created earlier. we will touch this part later on. 
