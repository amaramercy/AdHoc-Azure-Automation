Ad-Hoc Automation on Azure — 3 VMs, Inventory & Passwordless SSH

🎯 Objective
I provisioned a small Azure fleet with Terraform (3 Linux VMs), set up passwordless SSH, created a custom Ansible inventory, and ran ad-hoc commands (ping, uptime, package install, service restart) targeting hosts and groups with --become where needed.

🏢 Real-World Scenario
In this assignment, I demonstrated how to spin up dev/test VMs on Azure, ensure secure access, and perform fleet-wide actions in seconds without writing a playbook.

⚡Prerequisites
Azure CLI authenticated
Terraform installed
SSH key at ~/.ssh/id_ed25519
Ubuntu 22.04 LTS image

My Project Folder Structure
PS C:\Users\USER\Downloads\Assignment-34> tree /F
C:.
│   inventory.ini
│
└───terraform
        main.tf
        output.tf
        provider.tf
        terraform.tfvars
        variables.tf
inventory.ini → My Ansible inventory mapping IPs to web, app, and db groups
terraform/ → Terraform files I used to provision the Azure resources
🛠 Terraform Setup
I used Terraform to provision:

3 Linux VMs (1 app, 2 web, 1 db)
VNet and Subnet
NSG allowing SSH and HTTP
Network Interfaces + Public IPs
Outputted public IPs for inventory

🔑 Step 1 — Provision Azure VMs
I ran:

terraform init
terraform plan
terraform apply -auto-approve
terraform output public_ips
Got the public IPs of my 3 VMs to use in my inventory.

Press enter or click to view image in full size

Public-ip Output
Press enter or click to view image in full size

VM output
