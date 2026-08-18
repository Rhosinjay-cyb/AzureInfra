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

The Dev team of a fictional organization has always reported the issue of infrastructure deployments with inherent security misconfigurations due to manual deployments alongside longer (mean-time-to-deploy) MTTD. This has affected the productivity of the team as well as undermining the security posture of the company's digital environment. Finding the solution to the problem was the motivation for this project. This project utilizes Terraform IaC for provisioning of Azure infrastructure through a GitHub Action CI/CD pipeline. It equally integrates Checkov to the workflow to detect misconfigurations before deployment alongside an approval ensuring every deployments are reviewed and authorised.

The general workflow of this project starts when a push is made to the GitHub branch, this triggers the workflow to run each of the actions specified in it. The main action in the workflow is to logging-in to Azure, Setting-up Terraform and deploying the infrastructure into Azure. A storage account was provisioned to store the terrfaform state, this helps terraform to keep an inventory of infrastructure already provisioned, this prevents conflict during deployments thereby strengthening the reliability of this solution.

Afterwards, security checks was also integrated into the workflow using Checkov to identify misconfigurations and eliminate them before deployments. To make this solution fit for production standard the terraform files are being formatted and the workflow was modified to require approval before deployment. 

## Steps Taken

The steps taken are in the following order.

###  Creation of GitHub Workflow and Terraform files 

The Terraform file (main.tf) which contains the infrastructure to be deployed to Azure and the workflow file (Deploy.yml) were created in the repository. The GitHub Action is the CI/CD tool used in this project to automate the deployment of infrastructure specified in main.tf file to Azure. Hence, the Deploy.yml file relies on GitHub Action to execute each of the jobs specified in it. 

 ![image](Images/Githubfile.png)

Note: The workflow file must be in the .github/workflows folder for the worflow to work effectively.

Here is a snippet of what the terraform files looks like

 ![image](Images/Deployments1.png)
 ![image](Images/Deployments2.png)

### App Registration (GitHub Workflow) on Microsoft Entra ID

For seamless operation of the GitHub workflow, it is first of all registered in Microsoft Entra ID as a service principal using 'App Registrations'. This identity (service principal) will be used to authenticate to Azure, Terraform will then make use of the session to deploy the infrastructure in Azure.

![image](Images/AppReg.png)

After registering the service principal, it is assigned a unique application (client) ID. The next step is to configure a certificate (authentication) for the service principal.

![image](Images/Config_cert.png)

### Configuring OIDC Authentication

The identity is being configured to authenticate seamlessly against Azure via Open-ID connect by adding a credential and specifying its purpose, basically to deploy Azure resources.

![image](Images/Config_cert2.png)
![image](Images/Config_cert3.png)

Afterwards, the identity is also configured with respect to branch where the workflow originates from.

![image](Images/Config_cert4.png)
![image](Images/Config_cert5.png)


### Role Assignment of the identity of the GitHub Workflow

The service principal was assigned the appropriate Azure role-based access control (RBAC), basically the role that will required to deploy the infrastructure to Azure. In this case, the service principal is assigned the contributor role.

![image](Images/Assignrole.png)
![image](Images/Assignrole2.png)
![image](Images/Assignrole3.png)
![image](Images/Assignrole4.png)
![image](Images/Assignrole5.png)

### Secrets Management on Github

The secrets that would be used in the OIDC to Azure are stored in GitHub. Likewise, the password of one the infrastucture (virtual machine) to be deployed were stored as a secret on Azure. During the deployments the password would be integrated with the virtual machine.

![image](Images/Config_secret.png)
![image](Images/Secrets.png)

The application (client) and tenant (directory) ID are gotten from the registered app while the Azure Subscription ID is obtain from the Azure Subsrciption's page. The Azure Subscription ID is used to identify where to provision the resources while the other IDs are used to identify the service principal and the directory that will provide the token session during authentication.

![image](Images/AzureSub.png)

### Secret Reference in the Github workflow Deploy.yml file

The secrets stored in the repository secret on GitHub are referenced in the Deploy.yml file while the password is referenced in the main.tf file. The former is utilized by the workflow to authenticate against Azure while the latter will be loaded to the Virtual machine during deployment allowing access to the VM.

![image](Images/ymfile2.png)

### Terraform State Configuration with a storage account 

For every deployment terraform runs on an ephemeral runner, as a result the terraform state are not stored. The drawback of this situation is that deployment conflicts will arise if the terraform file contains infrastructure that are already deployed which also prevents the reusability of the file. Getting around this will require the provisioning of a terraform state to store the details of already provisioned infrastructure.

Firstly, a new resource group was created, then a storage account and then a container. 

![image](Images/rgtfstate.png)
![image](Images/satfstate.png)
![image](Images/contfstate.png)

Finally, the new provision is referenced in the terraform file by updating the main.tf file, this ensures terraform refreshes its state during deployments 

![image](Images/reftfstate.png)

The main function of this provision to store terraform state. This state is refreshed during a new deployment to acquire an inventory of existing infrastructure and compares it with what it is about to deploy (output of 'terraform plan' command), it ignores the infrastructure that are common to both parties and deploy ('terraform apply') the unique ones, thereby preventing conflict during provisioning and enhancing the reliability of this solution.

 ### Testing of the CI/CD pipeline

As mentioned earlier that this workflow is triggered whenever a push is made to its main branch. The main.tf file was just updated with the terraform state. Pushing it to the main branch simply triggers and run the workflow. Afterwards the workflow could be seen running.

![image](Images/sucrun.png)
![image](Images/sucrun2.png)

Here is the result of the workflow in Azure, showing the succesful deployment of the infrastructure.

![image](Images/sucrun3.png)

Attempt was made to logon to the VM, but was unsuccessful.

![image](Images/unable2connect2.png)

This error was troubleshot and it was discovered that the RDP port of the VM was not exposed to the internet. To expose the port, an NSG was created and associated with the subnet of the VM then a security rule was created to expose the port to the internet.

To accomplish this task easily, the main.tf file was updated with the new infrastructure and pushed to the main branch,thereby triggering the workflow. 

![image](Images/AttachNSG2.png)

Here the benefit of the terraform state is been demonstrated as only the newly added infrastructure was provisioned, thereby preventing conflict and saving time.

![image](Images/sucrun4.png)

Over here is the newly created NSG and its security rule.

![image](Images/NSGsuc.png)

Had it been that the terraform state was not provisioned and attempt to reuse the main.tf file would have led into an error like the one below.

![image](Images/AttachNSGError.png)

Note: Updating the main.tf file triggered the GitHub workflow which could be seen running. The results showed that the terraform state helped terraform to identify that other resources already exists in Azure while NSG is missing. This led to the deployment of NSG only. This terraform state did not only prevent deployment conflict but also saved time and allowed the reusage of the terraform file. 

With the implementation of the NSG and the appropriate security rule, the VM was successfully logged-on.

![image](Images/conn.png)
![image](Images/logonsuc.png)

### integrating Security to the Workflow with Checkov

In integrating security with the workflow using Checkov, the resource group containing the infrastructure was deleted to create a clean slate. The main function of Checkov is to scan through the terraform files (main.tf) to identify any misconfiguration or security weakness. If any of it is found as a failed check, the workflow stops immediately; requiring the rectification of the misconfiguration manually. Sometimes, the failed checks could also be skipped if it seems not to be applicable. 

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





This time around the workflow was succesfully completed.


### Integrating Terraform file formatting and Manual Approval to the Pipeline

Having successfully integrated security to the workflow, extra efforts was spent in making the solution fit for production standard. Basically, this involves formating the terraform files and requiring approval for the deployments. 

The terraform file was formatted with the 'terraform fmt check' command on codespace. However, some essential libraries including terraform were installed before running the command. After formatting the terraform file, the update was committed and pushed to the main branch.

To modify the workflow for the new development, the 'terraform fmt check' command was added to the workflow, this command checks if the terraform file is formatted, and proceeds to thenext action if 'true' and exits if false. 

The second development is to enable the workflow request for approval before implementing the 'terraform apply' command, basically, deploying the infrastructure.

To achieve this, a new environment is created on GitHub and a federated certifiate is created for it in Azure while using the earlier registered app.

Completing the configuration, basically, chosing the user that will approve the deployments. 

Updating this changes led to new updates, and pushing it to the branch triggered the workflow thereby ruuning it.






