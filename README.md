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


## Background Information

The Dev team of a fictional organization has always reported the issue of infrastructure deployments with inherent security misconfigurations due to manual deployments alongside longer (mean-time-to-deploy) MTTD. This has affected the productivity of the team as well as undermining the security posture of the company's digital environment. Finding the solution to the problem was the motivation for this project. This project utilizes Terraform IaC for provisioning of Azure infrastructure through a GitHub Action CI/CD pipeline. It equally integrates Checkov to the workflow to detect misconfigurations before deployment alongside an approval ensuring every deployments are reviewed and authorised.

## Steps Taken







![image](Images/A.Rule.png)

