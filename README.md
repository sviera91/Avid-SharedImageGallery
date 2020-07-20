# Create Shared Image Gallery and generate Images using Packer

## Required Software
    - Azure Subscription
    - Azuer CLI
    - Packer
    - Terraform

## Create Service Principle
    az ad sp create-for-rbac --name sharedimage-sp

## Apply the values from the Service Principle to required files
    Values:
        subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        client_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        client_secret   = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
        tenant_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

    Files:
        jumpbox.json
        mediacentral.json
        mediacomposer.json
        mediacomposer2020.json
        mediaworker.json
        nexis_cloud_online.json
        nexis_nearline.json
        infrastructure/main.tf

        Note: You can also instead create variable files for both Terraform & Packer and pass that at deployment

## Steps
    - Create Azure Infrastructure
        - execute in infrastructure dir
        tertaform init
        terraform validate
        terraform apply -auto-approve

        Note: You can pass a variable file here too e.g. terraform apply -var-file="secrets.tfvars"

    - Build and deploy Images
        packer build nexis.json
        packer build jumpbox.json
        packer build mediacomposer.json
        packer build mediacentral.json

        Note: You can pass a variable file here too e.g.

        On Linux :
            $ packer build -var-file=variables.json template.json
        On Windows :
            packer build -var-file variables.json template.json

