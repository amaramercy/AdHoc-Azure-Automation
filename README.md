# 🚀 Ad-Hoc Automation on Azure — Multi-VM Deployment with Terraform & Ansible

This project demonstrates **automating infrastructure provisioning and application deployment** on Azure using Terraform and Ansible ad-hoc commands.

---

## 🎯 Objective
Provision a small Azure fleet (3 Linux VMs), set up **passwordless SSH**, create a custom **Ansible inventory**, and run ad-hoc commands to deploy Dockerized applications (`Mexant` and `Mediplus`) without writing playbooks.

---

## 🏢 Real-World Scenario
Engineers need to quickly spin up dev/test environments, ensure secure access, and deploy applications consistently. This project mirrors a real-world DevOps workflow:

1. **Terraform** provisions infrastructure (VMs, networking, NSG rules, public IPs).  
2. **Ansible ad-hoc commands** verify connectivity, manage Docker containers, and deploy apps.  

---

## ⚡ Prerequisites
- Azure CLI authenticated
- Terraform installed
- SSH key: `~/.ssh/id_ed25519`
- Ubuntu 22.04 LTS image

---

## 📂 Project Structure
```text
Assignment-34/
│
├── terraform/
│   ├── main.tf
│   ├── provider.tf
│   ├── output.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── .gitignore
│
├── inventory.ini
└── README.md
terraform/ → Terraform configuration to provision Azure VMs

inventory.ini → Ansible inventory mapping IPs to web, app, db groups

🛠 Terraform Setup
Provisioned:

3 Linux VMs (2 web, 1 app, 1 db)

VNet and Subnet

NSG allowing SSH (22), HTTP (80), and App port (8080)

Public IPs for Ansible inventory

Commands:

bash
Copy code
terraform init
terraform plan
terraform apply -auto-approve
terraform output public_ips
🔑 Passwordless SSH
Generate key on control VM (if not already):

bash
Copy code
ssh-keygen -t ed25519
Copy public key to all VMs:

bash
Copy code
ssh-copy-id azureuser@<VM_PUBLIC_IP>
Test with:

bash
Copy code
ssh azureuser@<VM_PUBLIC_IP>
🔑 Ansible Inventory
inventory.ini:

ini
Copy code
[web]
172.201.50.146
172.201.187.117

[app]
4.210.203.149

[db]
<db-ip>

[all:vars]
ansible_user=azureuser
ansible_ssh_private_key_file=~/.ssh/id_ed25519
🔧 Ad-Hoc Commands
Verify connectivity:

bash
Copy code
ansible all -i ~/inventory.ini -m ping
Check Docker installation:

bash
Copy code
ansible all -i ~/inventory.ini -a "docker --version"
Deploy Mexant app on all web servers:

bash
Copy code
ansible all -i ~/inventory.ini -a "docker run -d -p 80:80 --name mexant amaracloud/mexant:v4" --become
Deploy Mediplus app on app server:

bash
Copy code
ansible app -i ~/inventory.ini -a "docker run -d -p 8080:80 --name mediplus amaracloud/mediplus:v2" --become
Check running containers:

bash
Copy code
ansible all -i ~/inventory.ini -a "docker ps" --become
Stop nginx (if blocking ports):

bash
Copy code
ansible web -i ~/inventory.ini -a "bash -c 'sudo systemctl stop nginx && sudo systemctl disable nginx'" --become
🌍 Real-World Application
This exercise mirrors a real-world DevOps scenario where Terraform provisions infrastructure, and Ansible manages configuration and deployments efficiently.

💡 Key Takeaways
Passwordless SSH simplifies automation securely

Ad-hoc commands are perfect for quick fixes, testing, or verifying configs

Playbooks are ideal for repeatable or structured deployments

Combining Terraform + Ansible bridges provisioning and configuration seamlessly
