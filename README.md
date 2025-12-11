# SCOM Deployment with Ansible and Terraform

![meme](https://github.com/user-attachments/assets/b1e30530-165e-4e71-9387-9cb3d71da022)

First of all we would like to give full credits to the amazing team at SpecterOps and https://github.com/Synzack in specific. They did the heavy lifting of most of the Ansible modules.

Since SpecterOps announced some amazing SCOM research with a Ludus lab, i wanted a way to deploy this without Ludus and integrate it in the deployment tools we already use. In this repository you can set SCOM easily up in all kinds of environments, we provided a Terraform file that deploys it into Azure for you but these Ansible files can be used stand alone as well to set it up in whatever environment you like.

**Important:** Since the deployment take +- 60-90 minutes we were not able to test every possible setting / setup, we opted to go for the "Medium Distrubuted". Since we are still testing against it we do not know if everything will work 100% as expected.

Besides the Ansible files that Synzack created we added one to setup the Domain Server and the Domain Admin user. We also created one that will make all the servers join the Domain Controller so that we have an setup that does everything from start to end.

## Usage
The usage is pretty straight forward, if you use the Terraform file when it finishes it shows the settings for the hosts deployed. Use these to setup the Ansible inventory.yml file, the inventory file holds all the variables that you might use during the deployment.

The Terraform deployments automatically disables the firewall due to the remote connection Ansible needs to make which otherwise wont be possible. It also opens RDP en WinRM to the IP address configured in the `variables.tf` file.

The most important files that you will use are:
- `variables.tf` this holds all the Terraform related configuration
- `inventory.yml` this holds all the Ansible related configuration

To run the Terraform deployment:
```
terraform init
terraform plan # confirm that everything looks ok
terraform deploy
```

When it is finished change into the Ansible directory, change the variables and run:
```
sudo ansible-playbook -i inventory.yml site.yml -vvv
```

Now wait for a long time and keep an eye on the deployment for potential errors.

Happy Researching!
