#!/bin/bash

function replace_json_field {
    tmpfile=/tmp/tmp.json
    cp $1 $tmpfile
    jq "$2 |= \"$3\"" $tmpfile > $1
    rm "$tmpfile"
}

# Check if SUFFIX envvar exists
if [[ -z "${MCW_SUFFIX}" ]]; then
    echo "Please set the MCW_SUFFIX environment variable to a unique three character string."
    exit 1
fi

if [[ -z "${MCW_GITHUB_USERNAME}" ]]; then
    echo "Please set the MCW_GITHUB_USERNAME environment variable to your Github Username"
    exit 1
fi

if [[ -z "${MCW_GITHUB_TOKEN}" ]]; then
    echo "Please set the MCW_GITHUB_TOKEN environment variable to your Github Token"
    exit 1
fi

if [[ -z "${MCW_AZURE_SUBSCRIPTION}" ]]; then
    echo "Please set the MCW_AZURE_SUBSCRIPTION environment variable to your Azure subscription ID"
    exit 1
fi

if [[ -z "${MCW_GITHUB_URL}" ]]; then
    MCW_GITHUB_URL=https://$MCW_GITHUB_TOKEN@github.com/$MCW_GITHUB_USERNAME/Fabmedical.git
fi

if [[ -z "${MCW_PRIMARY_LOCATION}" ]]; then
    MCW_PRIMARY_LOCATION="northeurope"
    MCW_PRIMARY_LOCATION_NAME="North Europe"
fi

if [[ -z "${MCW_SECONDARY_LOCATION}" ]]; then
    MCW_SECONDARY_LOCATION="westeurope"
    MCW_SECONDARY_LOCATION_NAME="West Europe"
fi

# Create SSH key
if [[ ! -e ~/.ssh ]]; then
    mkdir ~/.ssh
fi

if [[ ! -e ~/.ssh/fabmedical ]]; then
    ssh-keygen -t RSA -b 2048 -C admin@fabmedical -N "" -f ~/.ssh/fabmedical
fi

# Create resource group
az group create -l "${MCW_PRIMARY_LOCATION}" -n "fabmedical-${MCW_SUFFIX}"

SSH_PUBLIC_KEY=$(cat ~/.ssh/fabmedical.pub)

# Create Fabmedical repository
if [[ ! -e ~/Fabmedical ]]; then
    cp -R ~/MCW-Cloud-native-applications/Hands-on\ lab/lab-files/developer ~/Fabmedical
    cd ~/Fabmedical
    git init
    git remote add origin $MCW_GITHUB_URL
fi

# Configuring github workflows
cd ~/Fabmedical
sed -i "s/\[SUFFIX\]/$MCW_SUFFIX/g" ~/Fabmedical/.github/workflows/content-init.yml
sed -i "s/\[SUFFIX\]/$MCW_SUFFIX/g" ~/Fabmedical/.github/workflows/content-api.yml
sed -i "s/\[SUFFIX\]/$MCW_SUFFIX/g" ~/Fabmedical/.github/workflows/content-web.yml

# Commit changes
git add .
git commit -m "Initial Commit"

# Configure ARM deployment
cd ~/Fabmedical/scripts
replace_json_field ~/Fabmedical/scripts/azuredeploy.parameters.json .parameters.Suffix.value "$MCW_SUFFIX"
replace_json_field ~/Fabmedical/scripts/azuredeploy.parameters.json .parameters.VirtualMachineAdminPublicKeyLinux.value "$SSH_PUBLIC_KEY"
replace_json_field ~/Fabmedical/scripts/azuredeploy.parameters.json .parameters.CosmosLocation.value "$MCW_PRIMARY_LOCATION"
replace_json_field ~/Fabmedical/scripts/azuredeploy.parameters.json .parameters.CosmosLocationName.value "$MCW_PRIMARY_LOCATION_NAME"
replace_json_field ~/Fabmedical/scripts/azuredeploy.parameters.json .parameters.CosmosPairedLocation.value "$MCW_SECONDARY_LOCATION"
replace_json_field ~/Fabmedical/scripts/azuredeploy.parameters.json .parameters.CosmosPairedLocationName.value "$MCW_SECONDARY_LOCATION_NAME"

# Create ARM deployment
az deployment group create --resource-group fabmedical-$MCW_SUFFIX --template-file ./azuredeploy.json --parameters azuredeploy.parameters.json

# Get ACR credentials and add them as secrets to Github
ACR_CREDENTIALS=$(az acr credential show -n fabmedical$MCW_SUFFIX)
ACR_USERNAME=$(jq -r -n '$input.username' --argjson input "$ACR_CREDENTIALS")
ACR_PASSWORD=$(jq -r -n '$input.passwords[0].value' --argjson input "$ACR_CREDENTIALS")
AZURE_CREDENTIALS=$(az ad sp create-for-rbac --role contributor --scopes /subscriptions/$MCW_AZURE_SUBSCRIPTION/resourceGroups/fabmedical-${MCW_SUFFIX} --sdk-auth)

GITHUB_TOKEN=$MCW_GITHUB_TOKEN
cd ~/Fabmedical
echo $GITHUB_TOKEN | gh auth login --with-token
gh secret set ACR_USERNAME -b "$ACR_USERNAME"
gh secret set ACR_PASSWORD -b "$ACR_PASSWORD"
gh secret set AZURE_CREDENTIALS -b "$AZURE_CREDENTIALS" 

# Committing repository
cd ~/Fabmedical
git branch -m master main
git push -u origin main

# Get public IP of build agent VM
VM_PUBLIC_IP=$(az vm show -d -g fabmedical-$MCW_SUFFIX -n fabmedical-$MCW_SUFFIX --query publicIps -o tsv)
echo "Command to create an active session to the build agent VM:"
echo ""
echo "    ssh -i ~/.ssh/fabmedical adminfabmedical@$VM_PUBLIC_IP"
