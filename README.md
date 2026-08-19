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
* integrating Security to the workflow with Checkov
* Integrating Terraform file formatting and Manual Approval to the Pipeline


## Background

The Dev team of a fictional organization has always reported the issue of infrastructure deployments with inherent security misconfigurations due to manual deployments alongside longer (mean-time-to-deploy) MTTD. This has affected the productivity of the team as well as undermining the security posture of the company's digital environment. Finding the solution to this challenge was the motivation for this project. This project utilizes Terraform IaC for provisioning of Azure infrastructure through a GitHub Action continuous integration & continuous delivery (CI/CD) pipeline. It equally integrates Checkov to the workflow to detect misconfigurations before deployment alongside an approval request ensuring every deployments are reviewed and authorised.

The general workflow of this project starts when a push is made to the GitHub branch, this triggers the workflow to run each of the actions specified in it. The main actions in the workflow includes the workflow logging-in to Azure, Setting-up Terraform and deploying the infrastructure into Azure. In addition, a storage account was provisioned to store terrfaform state, this helps terraform to keep an inventory of infrastructure already provisioned, this prevents conflict during deployments thereby enhancing the reliability of this solution.

Afterwards, security checks was also integrated into the workflow using Checkov to identify misconfigurations and eliminate them before deployments. To make this solution fit for production standard the terraform file was formatted and the workflow was modified to require approval before deployment thereby preventing unauthorised deployments and other associated risks. 

## Steps Taken

The steps taken are in the following order.

###  Creation of GitHub Workflow and Terraform files 

The Terraform file (main.tf) which contains the infrastructure to be deployed to Azure and the workflow file (Deploy.yml) were created in the GitHub repository (AzureInfra). The GitHub Action is the CI/CD tool used in this project to automate the deployment of infrastructure specified in terraform file. Hence, the workflow file relies on GitHub Action to execute each of the actions specified in it. 

 ![image](Images/Githubfile.png)

Note: The workflow file must be in the .github/workflows folder for the worflow to work effectively.

Here is a snippet of what the terraform file containing the list of resources to deployed to Azure looks like

 ![image](Images/Deployments1.png)
 ![image](Images/Deployments2.png)

### App Registration (GitHub Workflow) on Microsoft Entra ID

For seamless operation of the GitHub workflow, it was firstly registered in Microsoft Entra ID as a service principal using 'App Registrations'. This identity (service principal) will be used to authenticate against Microsoft Entra ID which provides Azure access token, Terraform then uses this authenticated session through the AzureRM provider to communicate with Azure Resource Manager and deploy the infrastructure defined in the Terraform file.

![image](Images/AppReg.png)

After registering the service principal, it is assigned a unique application (client) ID. The next step is to configure a certificate (authentication) for the service principal.

![image](Images/Config_cert.png)

### Configuring OIDC Authentication

The identity is being configured to authenticate seamlessly against, Microsoft Entra ID using Open-ID connect. This was achieved clicking on 'add a credential' and specifying its purpose, basically to deploy Azure resources.

![image](Images/Config_cert2.png)
![image](Images/Config_cert3.png)

Afterwards, the identity was also configured with respect to branch where the workflow originates from.

![image](Images/Config_cert4.png)
![image](Images/Config_cert5.png)


### Role Assignment of the identity of the GitHub Workflow

The service principal was assigned the appropriate Azure role-based access control (RBAC). Basically, the role that will required to deploy the infrastructure to Azure. In this case, the service principal was assigned the contributor role.

![image](Images/Assignrole.png)
![image](Images/Assignrole2.png)
![image](Images/Assignrole3.png)
![image](Images/Assignrole4.png)
![image](Images/Assignrole5.png)

### Secrets Management on Github

The secrets that would be used in the OIDC were stored in GitHub. Likewise, the password of one the infrastucture (virtual machine) to be deployed was also stored as a secret on GitHUb. During the deployments the password would be integrated with the virtual machine.

![image](Images/Config_secret.png)
![image](Images/Secrets.png)

The application (client) and tenant (directory) IDs are obtained from the registered app while the Azure Subscription ID was obtained from the Azure Subsrciption's page. The Azure Subscription ID was used to identify which subscription to provision the resources while the other IDs are used to identify the service principal and the directory that will provide the access token during authentication.

![image](Images/AzureSub.png)

### Secret Reference in the Github workflow Deploy.yml file

The secrets stored in the repository secret on GitHub are referenced in the workflow file while the password is referenced in the terraform file. The former is utilized by the workflow to authenticate against Microsoft Entra ID while the latter was loaded to the Virtual machine during deployment allowing access to the VM.

![image](Images/ymfile2.png)

### Terraform State Configuration with a storage account 

For every deployment, terraform runs on an ephemeral runner, as a result the terraform state are not stored. The drawback of this method is that deployment conflicts will arise if the terraform file contains infrastructure that are already deployed, this method also prevents the reusability of the file. Getting around this will require the provisioning of a terraform state to store the details of every provisioning made by terraform.

Firstly, a new resource group was created, then a storage account and then a container. 

![image](Images/rgtfstate.png)
![image](Images/satfstate.png)
![image](Images/contfstate.png)

Afterwards, the new provision was referenced in the terraform file by updating the main.tf file, this ensures terraform refreshes its state during deployments 

![image](Images/reftfstate.png)

The main function of this provisioning was to store terraform state. This state is refreshed during a new deployment to acquire an inventory of existing infrastructure and compares it with what it is about to deploy (output of 'terraform plan' command), it ignores the infrastructure that are common to both parties and deploy ('terraform apply') the unique ones, thereby preventing conflict during provisioning and enhancing the reliability of this solution.

 ### Testing of the CI/CD pipeline

As mentioned earlier that this workflow is triggered whenever a push is made to its main branch. The main.tf file was just updated with the terraform state and pushing it to the main branch simply triggers and run the workflow. Afterwards the workflow could be seen running.

![image](Images/sucrun.png)
![image](Images/sucrun2.png)

Here is the result of the workflow in Azure, showing the succesful deployment of the infrastructure.

![image](Images/sucrun3.png)

Attempt was made to logon to the VM, but was unsuccessful.

![image](Images/unable2connect2.png)

This error was troubleshot and it was discovered that the RDP port of the VM was not exposed to the internet. To expose the port, an NSG was created and associated with the subnet of the VM then a security rule was created to expose the port to the internet.

To accomplish this task easily, the main.tf file was updated with the new infrastructure and pushed to the main branch, thereby triggering the workflow. 

![image](Images/AttachNSG2.png)

Here the benefit of the terraform state is been demonstrated as only the newly added infrastructure was provisioned, thereby preventing conflict and saving time.

![image](Images/sucrun4.png)

Over here is the newly created NSG and its security rule.

![image](Images/NSGsuc.png)

Had it been that the terraform state was not provisioned and attempt to update and reuse the main.tf file would have led into an error just like the one below.

![image](Images/AttachNSGError.png)

Note: Updating the main.tf file triggered the GitHub workflow which could be seen running. The results showed that the terraform state helped terraform to identify that other resources already exists in Azure while NSG is missing. This led to the deployment of NSG only. This terraform state did not only prevent deployment conflict but also saved time and allowed for thehe reusage of the terraform file. 

With the implementation of the NSG and the appropriate security rule, the VM was successfully logged-on.

![image](Images/conn.png)
![image](Images/logonsuc.png)

### integrating Security to the Workflow with Checkov

In integrating security with the workflow using Checkov, the resource group containing the infrastructure was deleted to start afresh. The main function of Checkov is to scan through the terraform file (main.tf) to identify any misconfiguration or security weakness. If any of iwas found as a failed check, the workflow stops immediately; requiring the rectification of the misconfiguration manually. Sometimes, the failed checks could also be skipped if it seems not to be applicable. 

Checkov is being integrated to the workflow. 

![image](Images/chkv.png)

In this new workflow, Checkov is being installed to scan the terraform files before terraform plan occurs. This allow Checkov to detect misconfigurations before 'terraform plan' command and 'terraform apply' thereafter.

With the modification of the workflow file, a new push is made to the branch which triggers the workflow. The workflow then started to run but stop after a while. This was due to failed checks flagged by Checkov.

![image](Images/chkv2.png)

Three failed checks were found in total. Two of them are not applicable while the last one was. The last one requires that the NIC of the virtual machine should not be assigned a public IP. This security check will prevent internet-routed traffic to the VM thereby reducing surface attack.

![image](Images/chkverr.png)
![image](Images/chkverr2.png)
![image](Images/chkverr3.png)

Removing the public address from the infrastructure and disassociating it from the NIC will prevent further connection to the VM via RDP over the internet. To maintain seamless access to the VM, Azure Bastion is provisioned.

![image](Images/chkvrem.png)
![image](Images/chkvrem5.png)

Similarly other failed checks are skipped.

![image](Images/chkvrem.png)

The terraform file was updated to add Azure Bastion including its subnet (AzureBastionSubnet). The workflow was triggered with the new update hence its began to ran.

![image](Images/chkvrem2.png)
![image](Images/chkvrem3.png)

Another failed check was flagged by checkov, this time around it was because the AzureBastionSubnet was not associated with an NSG. Attaching every subnet to a particular NSG will allow an NSG security rule to be applied to the subnet or the infrastructure in it. To reduce the complexity of this solution the failed check was skipped.

![image](Images/chkvrem6.png)
![image](Images/chkvrem7.png)

Having skipped the failed check, the workflow was triggered to run again but failed because two resources which are dependent on each other were deployed concurrently. To prevent this error, the workflow was updated to ensure the resources were deployed simultaneously.

![image](Images/chkvrem9.png)

With the new update, the workflow ran successfully.

![image](Images/chkvrem10.png)

Here is the list of resources being deployed in Azure

![image](Images/infra2.png)

An attempt to logon to the VM via Azure Bastion was succesful.

![image](Images/LVBastion.png)
![image](Images/logonsuc2.png)
![image](Images/logonsuc3.png)

### Integrating Terraform file formatting and Manual Approval to the Pipeline

Having successfully integrated security to the workflow, extra efforts was spent in making the solution fit for production standard. Basically, this involves formating the terraform file and requiring approval for deployments. The deployed infrastructure were also deleted and this project starts with no infrastructure in place.

The terraform file was formatted with the 'terraform fmt -recursive' command on codespace. 

![image](Images/cdsp.png)

However, some essential libraries including terraform were installed before running the command.

![image](Images/cdsp2.png)
![image](Images/cdsp3.png)

After formatting the terraform file, the update was committed and pushed to the main branch.

![image](Images/cdsp4.png)
![image](Images/cdsp5.png)

To modify the workflow for the new development, the 'terraform fmt check' command was added to the workflow, this command checks if the terraform file is formatted, and proceeds to the next action if 'true' and exits if false. 

The second development is to enable the workflow request for approval before implementing the 'terraform apply' command, basically, deploying the infrastructure.

To achieve this, a new environment (Production) is created on GitHub. 

![image](Images/newenv2.png)

Then the protection of the environment is configured, this include assigning users to review the approval and specifying a timeline for the approval. 

![image](Images/newenv3.png)

Afterwards, a federated certifiate is created for it in Microsoft Entra ID while using the earlier registered app. This allows the Production environment to connect to Azure to deploy the infrastructure having authenticated against Microsoft Entra ID with this newly created credential.

![image](Images/newenv4.png)
![image](Images/newenv5.png)

Additionally, the workflow is updated with the new development. The workflow now has two jobs, the first job is to run the steps from the initial stage up to 'terraform plan' command. Then the next job is to run the 'terraform apply' command on the output of the previous stage.

The first part of the job

![image](Images/manapproval.png)
![image](Images/manapproval2.png)

The second part of the job.

![image](Images/manapproval3.png)

Updating the workflow file triggers the GitHub workflow, while the workflow is running, a relationship is observed between the two jobs on GitHub.

![image](Images/manapproval4.png)

The first job has been completed, now requesting approval for the second job.

![image](Images/manapproval5.png)

Here is the artifact- output of the 'terraform plan' command, this gives the reviewver a glimpse of the infrastructure to be deployed. So the request could either be approved or canceled.

![image](Images/manapproval8.png)

Providing the approval,

![image](Images/manapproval6.png)

After providing the approval the next job starts running

![image](Images/manapproval7.png)

Both jobs have now been completed

![image](Images/manapproval9.png)
![image](Images/manapproval10.png)

With the successful completion of the jobs, the infrastructure are now deployed in Azure.

![image](Images/infra3.png)

The virtual machine was logged-on via Azure Bastion succesfully, emphasizing the succesful implementation of the dependencies of this solution.

![image](Images/logonsuc4.png)
![image](Images/logonsuc5.png)

## Conclusion

This project was succesfully completed demonstrating the relevance of automating infrastructure deployment with Terraform and GitHub Action, it also entails the integration of security checks with Checkov to detect security misconfigurations and weaknesses before deployment enabling a secured deployment of infrastructure. This project also covers improving the reliability of this solution making it fit for use in a production environment. It also utilizes a terraform state to keep an inventory of deployed infrastructure thereby preventing deployment conflict and allowing the reusability of the terraform file for new deployments . Other enahancement of this solution is configuring it to request approval before the final deployment of resources enforcing security control and enhancing the security of the digital environment.





