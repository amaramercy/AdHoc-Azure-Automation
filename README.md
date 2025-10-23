# 🚀 Ad-Hoc Automation on Azure — 3 VMs, Inventory & Passwordless SSH

## 🎯 Objective
Provision a small Azure fleet with Terraform (3 Linux VMs), set up passwordless SSH, create a custom Ansible inventory, and run ad-hoc commands (ping, uptime, package install, service restart) targeting hosts and groups with `--become` where needed.

## 🏢 Real-World Scenario
This mirrors a real-world DevOps scenario where engineers spin up dev/test VMs, ensure secure access, and perform fleet-wide actions in seconds without writing a playbook.

## ⚡ Prerequisites
- Azure CLI authenticated
- Terraform installed
- SSH key ready: `~/.ssh/id_ed25519` (or create one)
- Ubuntu 22.04 LTS image preferred

## 📁 Project Folder Structure
```text
C:\Users\USER\Downloads\Assignment-34
│   inventory.ini
└───terraform
        main.tf
        output.tf
        provider.tf
        terraform.tfvars
        variables.tf
        .terraform/ (ignore this in git)
        .terraform.lock.hcl
inventory.ini → Ansible inventory mapping IPs to web, app, and db groups

terraform/ → Terraform files used to provision Azure resources

🛠 Terraform Setup
Provisioned:

3 Linux VMs (web, app, db)

VNet and Subnet

NSG allowing SSH (22), HTTP (80), and app port (8080)

Network Interfaces + Public IPs

Run Terraform:

bash
Copy code
terraform init
terraform plan
terraform apply -auto-approve
terraform output public_ips
🔑 Step 1 — Connect to VMs via SSH
bash
Copy code
ssh azureuser@<VM_PUBLIC_IP>
Enter the password set in Terraform (Demo@12345678) for initial login.

🔑 Step 2 — Setup Passwordless SSH
From your control node (Windows PowerShell):

bash
Copy code
# VM 1
Get-Content $env:USERPROFILE\.ssh\id_rsa.pub | ssh azureuser@172.201.50.146 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

# VM 2
Get-Content $env:USERPROFILE\.ssh\id_rsa.pub | ssh azureuser@172.201.187.117 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

# VM 3
Get-Content $env:USERPROFILE\.ssh\id_rsa.pub | ssh azureuser@4.210.203.149 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
Test login:

bash
Copy code
ssh azureuser@<VM_PUBLIC_IP>
🔑 Step 3 — Install Ansible (on Control VM)
bash
Copy code
sudo apt update
sudo apt install -y ansible
ansible --version
🔑 Step 4 — Create Ansible Inventory
inventory.ini:

ini
Copy code
[web]
172.201.50.146
172.201.187.117

[app]
4.210.203.149

[db]
<db_vm_ip>

[all:vars]
ansible_user=azureuser
ansible_ssh_private_key_file=~/.ssh/id_rsa
🔑 Step 5 — Verify Ansible Connectivity
bash
Copy code
ansible all -i ~/inventory.ini -m ping
🔑 Step 6 — Docker Commands (Ad-Hoc)
Check Docker version:

bash
Copy code
ansible all -i ~/inventory.ini -a "docker --version"
Check running containers:

bash
Copy code
ansible all -i ~/inventory.ini -a "docker ps" --become
Stop nginx if blocking ports:

bash
Copy code
ansible web -i ~/inventory.ini -a "bash -c 'sudo systemctl stop nginx && sudo systemctl disable nginx'" --become
🔑 Step 7 — Deploy Applications with Ansible Ad-Hoc
Deploy Mexant on all web VMs (port 80):

bash
Copy code
ansible all -i ~/inventory.ini -a "docker run -d -p 80:80 --name mexant amaracloud/mexant:v4" --become
Deploy Mediplus on app VM (port 8080):

bash
Copy code
ansible app -i ~/inventory.ini -a "docker run -d -p 8080:80 --name mediplus amaracloud/mediplus:v2" --become
Verify containers:

bash
Copy code
ansible all -i ~/inventory.ini -a "docker ps" --become
🌍 Real-World Application
This exercise mirrors a real-world DevOps workflow:

Terraform provisions infrastructure

Ansible manages configuration and deployments efficiently

Quick ad-hoc commands allow testing and verification before writing playbooks

💡 Key Takeaways
Passwordless SSH simplifies automation securely

Ad-hoc commands are perfect for quick fixes and verification

Playbooks are ideal for repeatable, structured deployments

Combining Terraform + Ansible bridges provisioning and configuration seamlessly

🎥 Final Thoughts
From provisioning with Terraform to deploying containers with Ansible, managing multiple VMs now feels effortless. Fleet automation feels like magic ⚡ — powered by SSH, YAML, and Docker!
