# IBM Schematics Tutorial
## Introduction

IBM Cloud Schematics delivers Terraform-as-a-Service so that you can use a high-level scripting language to model the resources that you want in your IBM Cloud environment, and enable Infrastructure as Code (IaC). Terraform is an Open Source software that is developed by HashiCorp that enables predictable and consistent resource provisioning to rapidly build complex, multi-tier cloud environments.

**What is Infrastructure as Code?**
Infrastructure as Code (IaC) helps you codify your cloud environment so that you can automate the provisioning and management of your resources in the cloud. Rather than manually provisioning and configuring infrastructure resources or using scripts to adjust your cloud environment, you use a high-level scripting language to specify your resource and its configuration. Then, you use tools like Terraform to provision the resource in the cloud by leveraging its API. Your infrastructure code is treated the same way as your app code so that you can apply DevOps core practices such as version control, testing, and continuous monitoring.

**How is IBM Cloud Schematics different from Terraform?**
With IBM Cloud Schematics, you can organize your IBM Cloud resources across environments by using workspaces. Every workspace is connected to a GitHub repository that contains a set of Terraform configuration files, which build a Terraform template. You can choose to create your own Terraform template, or use one of the pre-defined templates that are provided by IBM. Workspaces allow for the separation of concerns for cloud resources and can be individually managed with IBM Cloud Identity and Access Management. To use IBM Cloud Schematics, you don't need to install the Terraform CLI or the IBM Cloud Provider plug-in for Terraform. 

This Tutorial will introduce you to the concepts within Schematics and how to create a VPC, set up 2 zones each with a subnet, and place a virtual instance in each Zone as well as deploy a load balancer attached to the servers. A simple cloud-init script will install nginx, just to showcase an http response for proving out the Tutorial.

![Workspace Architecture](docs/workspace-architecture.png)


## Prerequisites

1. You must have an IBM Cloud account. You can sign up for a trial account if you do not have an account. The account will require the IBMid. If you do not have an IBMid, register and one will be created.

2. You will need to have an Infrastructure Username and API Key as well as an IBM Cloud API Key. Additionally, you should have the IBM Cloud CLI installed.

3. Check to make certain you have the appropriate role access on your account to provision infrastructure. If you are assigned an IBM Cloud Schematics service access role, you can view, create, update, or delete workspaces in IBM Cloud Schematics. To provision the IBM Cloud resources that you defined in your Terraform template, you must be assigned the IAM platform or service access role that is required to provision the individual resource. Refer to the [documentation](https://cloud.ibm.com/docs/home/alldocs) for your resource to determine the access policies that you need to provision and work with your resource. To successfully provision IBM Cloud resources, users must have access to a paid IBM Cloud account. Charges incur when you create the resources in the IBM Cloud account, which is initiated by clicking the Apply plan button. Here's a link to the docs for [Schematics Access](https://cloud.ibm.com/docs/schematics?topic=schematics-access).

4. In this Tutorial we will be using the following resources:
- Schematics
- VPC Infrastructure

![IAM Access](docs/schematics-iam-access.png)

5. If you want to modify the variables for Image and Compute Profile, you will need to obtain these values from the CLI.
For Gen2 resource interaction via the CLI, you are required to have the infrastructure-services plugin.

`ibmcloud plugin install infrastructure-service`

This Tutorial will be using Gen 2 of the VPC. Set your CLI to target Gen2.

`ibmcloud is target --gen 2`

List the available images, and record the ID of the image in which you wish to use. Ubuntu 18.04 is set by default.

`ibmcloud is images list`

List the available Compute profiles and record the Name of the profile in which you wish to use. cx2-2x4 is set by default.

`ibmcloud is instance-profiles`

6. If you choose to do the optional steps at the end of the Tutorial, you must fork the project into your own repo so that you can make the required modifications and push back into your repo. If you choose to not do the additional steps, or do not have a Github account available, you can just use the Tutorial Git url, but will not have the ability to modify any of the plan. All modifications will only be done via the variables available.

## Task 1: Get Familiar with the Terraform Templates
Within the project, there are various files in which you will need to have familiarity with, as well as know which variables you will be required to specify values for.  Each of the files below are well documented to enhance your understanding of how the files work.

- **provider.tf** - Setup for the IBM Provider as well as the required credentials to be used.
- **variables.tf** - Holds the variables and possible default values to be used for the plan.
- **main.tf** - This file holds the majority of the resources to be created, including the VPC and virtual instances.
- **lb.tf** - This file holds the Load Balancer resource as well as defining the pool members. 
- **cloud-init-apptier.tf** - This file contains the Cloud-Init script to be used for each virtual instance to install a simple nginx service.
- **outputs.tf** - This file contains the output variables that we want to see when the plan is executed and completed. 

## Task 2: Create a new Workspace

A Workspace is the defining environment in which you want to provision within Schematics. The resources defined by the Terraform templates will make up this Workspace. The Terraform templates reside within a GitHub or GitLab repository. For this lab, we will be using this GitHub repository ([https://github.com/Cloud-Schematics/fs2020](https://github.com/Cloud-Schematics/fs2020)) containing the Terraform template files to provision resources. 

1. Login in to your IBM Cloud account via the portal. Navigate to the menu and select [Schematics](https://cloud.ibm.com/schematics).

![Schematics](docs/schematics-menu.png)

- Click the ![Create Workspace](docs/create-workspace.png) button.
- Provide a Workspace Name.
- Enter any tags in which you would like to specify.
- Select the Resource Group, this can also be reflected in the Plan variables.
- Add a description of your choice.

![Workspace Name](docs/workspace-name-group-description.png)

- Add the Github URL to this lab, or the forked URL from your own repository if you chose to use a fork.
- A personal access token should not be required since this lab uses a public GitHub repository.
- Click the "Retrieve input variables" button.

![Workspace Repo URL](docs/workspace-repo-url.png)

2. Upon clicking the "Retrieve input variables" button, Schematics will go out to the provided Github URL and retrieve the template files, also extracting out the variables that have been defined. You should now see the variables populated in a table on your screen. Update any variables for the items in which you choose to modify by entering a new value in the "Override value" textbox. Most variables will already have a default value assigned. You will also notice a sensitive checkbox for each variable. You should not need to secure any of these variables, but if you choose this option, the value will be hidden from the UI later.
- **ibmcloud_region** - Select the region in which you want to deploy the VPC into, default set to Dallas
- **vpc_name** - Provide a name for your VPC, this will also be used to prefix some other resources
- **zone1** - Enter the initial Zone to use within your region. default: us-south-1
- **zone2** - Enter a secondary Zone to use within the region. default: us-south-2
- **zone1_cidr** - Provide a valid CIDR block to use for your VPC
- **zone2_cidr** - Provide a valid CIDR block to use for your VPC
- **ssh_public_key** - Enter the contents of your SSH Public key to be used for the Virtual instances
- **image** - Provide the ID of the OS Image you wish to use
- **profile** - Provide the name of the Instance Profile type you wish to provision

![Workspace Variables](docs/workspace-variables.png)

Once all of the values have been entered, click the "Create" button to finalize the new Workspace. This will not create any resources at this time. In the next steps we will look at executing the Plan.

![Workspace Create Order](docs/workspace-order-create.png)

## Task 3: Apply the Plan

You now should have a Workspace created. The next step will be to Generate a Plan of your workspace template. Click "Generate plan" to create a Terraform execution plan. No resources will actually be created, but Schematics will go through the process of simulating the resource creation for the plan.

![Workspace Generate Plan](docs/generate-plan-execution.png)

Click on the "View log" link to see the progress of the executing plan. The log will tail as each of the resources go through their steps. When the log completes, you should see a log output stating the number of resources that will be added, changed and destroyed. For this plan, only resources should be added.

![Workspace Plan Log](docs/generate-plan-execution-log.png)


![Workspace Summary](docs/workspace-summary.png)

Now let's execute the plan to create the resources. Click the "Apply plan" button. Resources should now start provisioning. Like the "Generating Plan" step, you can also view the progress within the "View log" link while resources are being created. If any errors arise, you should see the reason within the log. This initial plan template should not have any issues, so if you have an issue, you may need to check your permissions and credentials.

## Task 4: Delete Resources and Workspace

In this lab you have successfully built an initial 2 zone environment, attached a load balancer, and optionally learned how to add an additional zone to the plan. To finish up with this lab, all you need to do now is delete your resources. You can also delete the Workspace if you choose to not keep it.

1. Select the "Delete" option in the Action Menu to begin the process.

![Workspace Delete](docs/workspace-action-delete.png)

2. In the popup, select if you wish to remove the workspace or just the resources. Once you have made your selections, click the "Delete" button. This will begin the process of removing resources. Once it is started, you can follow the log to watch the progress of this step and wait for completion. 

![Workspace Delete](docs/workspace-delete-popup.png)

## Tutorial Complete

Congratulations, you have completed the Tutorial. You created a VPC, set up 2 zones each with a subnet, and placed a virtual instance in each Zone as well as deployed a load balancer.  All resources should now be removed.  Now that you are familiar with IBM Schematics, visit https://www.ibm.com/demos/collection/IBM-Cloud-Virtual-Private-Cloud-(VPC) to learn more about IBM Cloud VPC and Terraform.

