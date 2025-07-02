# Static Website on Azure Blob Storage (via Terraform)

## Overview
This project uses Terraform to deploy a static website to Azure Blob Storage.

## What It Does
- Creates a Resource Group
- Deploys a Storage Account with static website hosting
- Outputs the website URL

## Prerequisites
- Terraform installed
- Azure CLI authenticated (`az login`)
- GitHub account

## Deploy

terraform init
terraform apply -auto-approve

## Clean up Terraform

terraform destroy


```bash