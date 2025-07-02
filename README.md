# 🚀 Azure Static Website with Terraform

Deploy a simple and scalable **static website** using **Azure Blob Storage** — fully automated with **Terraform**!

---

## 🧰 Tech Stack

- 🌩️ **Azure Blob Storage** – for hosting the static site
- 🏗️ **Terraform** – infrastructure as code
- 🧪 **Azure CLI** – for content upload
- 📄 **HTML** – minimal front-end files

---

## 📸 Demo

![Static Website Demo](https://raw.githubusercontent.com/yourusername/azure-static-website/main/demo-screenshot.png)  
*(Replace with your screenshot after deployment)*

---

## 📦 Project Structure

```bash
azure-static-website/
├── main.tf           # Core Terraform configuration
├── variables.tf      # (Optional) Variables for customization
├── outputs.tf        # Output website URL
├── index.html        # Home page
├── error.html        # 404 error page
└── README.md         # You're here!
