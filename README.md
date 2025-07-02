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


azure-static-website/ <br>
├── main.tf           # Core Terraform configuration <br> 
├── variables.tf      # (Optional) Variables for customization <br>
├── outputs.tf        # Output website URL <br>
├── index.html        # Home page <br>
├── error.html        # 404 error page <br>
└── README.md         # You're here!


## 🔧 Prerequisites

✅ Terraform

✅ Azure CLI

✅ An Azure account

## 🚀 Getting Started

### 1️⃣ Clone the repository
bash

git clone https://github.com/ejahanz/static_site_azure_blob.git

cd static_site_azure_blob


### 2️⃣ Authenticate with Azure
bash

az login

### 3️⃣ Initialize & Apply Terraform
bash

terraform init
terraform apply -auto-approve

### 4️⃣ Upload Website Files
bash

az storage blob upload-batch \
  --destination \$web \
  --account-name <your-storage-account-name> \
  --source . \
  --pattern "*.html"

### 5️⃣ View Your Website! 🎉
Terraform will output the URL. Open it in your browser:

bash

echo "🌐 Website URL: $(terraform output -raw static_website_url)"

## 🧹 Cleanup (Optional)
To avoid any charges:

bash

terraform destroy -auto-approve

## 📚 Resources

Azure Static Website Docs

Terraform AzureRM Provider

Azure CLI

## 🤝 Contributing

Pull requests welcome! If you found this useful, give it a ⭐️

## 🧑‍💻 Author
Made with 💙 by Erfan

```bash