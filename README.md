## Project Title

DevSecOps Pipeline for Secure Azure Infrastructure Provisioning 

## Objective

This project demonstrates an Infrastructure-as-Code (IaC) DevSecOps pipeline that automates the secure provisioning of Azure infrastructure using Terraform. The pipeline integrates open-ID connect (OIDC) authentication, security validation, policy enforcement and manual approval before deploying resources into Azure.

## Tools Used

Azure, Checkov, Codespace, GitHub GitHub Action, Microsoft Entra ID, Terraform


## Lab Setup

* Creation of GitHub Workflow and Terraform files 
* App Registration ( GitHub Workflow) on Microsoft Entra ID
* Configuring OIDC Authentication
* Role Assignment of the identity of the GitHub Workflow
* Secrets Management on Github
* Secret Reference in the Github workflow yaml file
* Terraform State Configuration with Backend 
* Testing of the CI/CD pipeline
* integrating Security to the Pipeline with Checkov
* Integrating Terraform file formatting and Manual Approval to the Pipeline


## Background

The Dev team of a fictional organization has always reported the issue of infrastructure deployments with inherent security misconfigurations due to manual deployments alongside longer (mean-time-to-deploy) MTTD. This has affected the productivity of the team as well as undermining the security posture of the company's digital environment. Finding the solution to the problem was the motivation for this project. This project utilizes Terraform IaC for provisioning of Azure infrastructure through a GitHub Action CI/CD pipeline. It equally integrates Checkov to the workflow to detect misconfigurations before deployment alongside an approval ensuring every deployments are reviewed and authorised.

The general workflow of this project starts when a push is made to the GitHub branch, this triggers the workflow to run each of the actions specified in it. The main action in the workflow is to logging-in to Azure, Setting-up Terraform and deploying the infrastructure into Azure. A storage account was provisioned to store the terrfaform state, this helps terraform to keep an inventory of infrastructure already provisioned, this prevents conflict during deployments thereby strengthening the reliability of this solution.

Afterwards, security checks was also integrated into the workflow using Checkov to identify misconfigurations and eliminate them before deployments. To make this solution fit for production standard the terraform files are being formatted and the workflow was modified to require approval before deployment. 

## Steps Taken

The steps taken are in the following order.

###  Creation of GitHub Workflow and Terraform files 

The Terraform file (main.tf) which contains the infrastructure to be deployed to Azure and the workflow file (Deploy.yml) were created in the repository. The GitHub Action is the CI/CD tool used in this project to automate the deployment of infrastructure specified in main.tf file to Azure. Hence, the Deploy.yml file relies on GitHub Action to execute each of the jobs specified in it. 

Note: The workflow file must be in the .github/workflows folder for the worflow to work effectively.

### App Registration (GitHub Workflow) on Microsoft Entra ID

For seamless operation of the GitHub workflow, it is first of all registered in Microsoft Entra ID as a service principal using 'App Registrations'. This identity (service principal) will be used to authenticate to Azure, Terraform will then make use of the session to deploy the infrastructure in Azure.


The registered service principal is 

### Configuring OIDC Authentication

After the identity has been registered, it was also configured for its purpose. The identity is being configured to connect to Azure via Open-ID connect. The purpose, basically to deploy resources was specified in the options.

Afterwards, the identity is also configured with respect to branch where the workflow originates.

### Role Assignment of the identity of the GitHub Workflow

The service principal was assigned the appropriate Azure RBAC 

![image](Images/A.Rule.png)

