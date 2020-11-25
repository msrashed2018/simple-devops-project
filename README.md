# DevOps CI\CD Tools Implementation On Kubernetes Cluster (AWS EKS) 

This repo is to create Kubernetes Cluster which will have needed deployments for Devops CI\CD tools (Jenkins, Nexus):

1. Implement and configure secure Kubernetes cluster on AWS EKS using Terraform.
2. Deploy Jenkins, Nexus on the created Cluster using Ansible.
3. Implement a CICD pipeline for a simple application (Java Spring boot) using the tools and the platform implemented from the previous steps this pipeline should be using groovy scripting Jenkins file.

## Pre-requisites
1. An AWS Account
2. Required Tools: AWS CLI, Kubectl CLI, Terraform CLI & Ansible.


## Implement and configure secure Kubernetes cluster on AWS EKS using Terraform

After installing the AWS CLI. Configure it to use your credentials.

```shell
$ aws configure
AWS Access Key ID [None]: <YOUR_AWS_ACCESS_KEY_ID>
AWS Secret Access Key [None]: <YOUR_AWS_SECRET_ACCESS_KEY>
Default region name [None]: <YOUR_AWS_REGION>
Default output format [None]: json
```

This enables Terraform access to the configuration file and performs operations on your behalf with these security credentials.

After you've done this, go to `terraform` directory and initalize your Terraform workspace `terraform init`, which will download 
the provider and initialize it with the values provided in the `terraform\terraform.tfvars` file.

Then, provision your EKS cluster by running `terraform apply`. This will 
take approximately 10 minutes.


### Configure kubectl

To configure kubetcl so you can deal direct with the cluster, you need both [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html).

The following command will get the access credentials for your cluster and automatically
configure `kubectl`.

```shell
$ aws eks --region $(terraform output region) update-kubeconfig --name $(terraform output cluster_name)
```

The Kubernetes cluster name and region correspond to the output variables showed after the successful Terraform run.

You can view these outputs again by running:

```shell
$ terraform output
```

You can also show cluster configuration by run `kubectl config view`.


## Deploy Jenkins & Nexus on the created Cluster using Ansible.

Ansible is an open-source automation platform. It is very, very simple to set up and yet powerful. Ansible can help you with configuration management, application deployment, task automation.

After you've install it, go to `ansible` directory and run the below commands to deploy CI\CD tools (Jenkins, Nexus) on the created cluster

- `ansible-play -i hosts jenkins-deployment.yaml`: to deploy jenkins
- `ansible-play -i hosts jenkins-service.yaml`: to deploy jenkins Service which will expose Jenkins port 8080 on the Cluster Node port 30000
- `ansible-play -i hosts jenkins-jnlp-service.yaml`: to deploy jenkins JNLP Service which will expose Jenkins JNLP port 50000 on the Cluster Node port 50000
- `ansible-play -i hosts jnexus-deployment.yaml`: to deploy Nexus server
- `ansible-play -i hosts jnexus-service.yaml`: to deploy nexus Service which will expose Nexus Server port 8081 on the Cluster Node port 32000

To verify that all components have been deployed, run `kubectl get all` to see all Kubernetes Objects created on the cluster.


Now you should able to access Jenkins by hitting the url `https:\\{CLUSTER_ENDPOIND}:30000` on the browser and Nexus by hitting `https:\\{CLUSTER_ENDPOIND}:32000`



## Implement a Jenkins CICD pipeline for a simple application

The `jenkins` directory contains Jenkinsfile (i.e. Pipeline) you'll be creating yourself on jenkins portal after configure Global Tool Configuration related to Git, Maven & JDK.


The pipeline is to auta continous delivery of a [Simple Application](https://github.com/msrashed2018/simple-application) with below stages
- Stage1 (Preparation): getting the source code from github https://github.com/msrashed2018/simple-application
- Stage2 (Build): building the application (ignoring tests) using maven
- Stage3 (Test): test (Junit) the application using maven
- Stage4 (Nexus Repository): upload the application into the nexus server.
