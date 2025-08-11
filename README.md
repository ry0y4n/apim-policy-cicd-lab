# Azure API Management Policy Management Lab

This is a complete lab repository demonstrating Infrastructure as Code (IaC) deployment of Azure API Management and automated policy management using GitHub Actions with the [`Azure/apim-policy-update`](https://github.com/marketplace/actions/azure-api-management-policy-update) action.

**What you'll learn:**

- Deploy APIM infrastructure using Bicep templates
- Manage APIM policies as code with version control
- Automate policy deployment via GitHub Actions

## Repository Structure

```
├── infra/                                    # Infrastructure as Code
│   ├── main.bicep                           # Main Bicep template (subscription-scoped)
│   ├── main.parameters.json                 # Deployment parameters
│   ├── deploy.sh                            # Deployment script
│   └── modules/
│       └── apim.bicep                       # APIM resource module
├── policies/                                # Policy definitions
│   └── sample-api/
│       ├── api.xml                         # API-level policy
│       └── operations/
│           └── get-data.xml                # Operation-level policy
├── policy_manifest.yaml                     # Policy mapping manifest
└── .github/workflows/
    └── update-apim-policies.yaml            # Policy deployment workflow
```

## Lab Setup Guide

### Step 0: Setup Code

1. **Fork this repository**
2. **Clone your forked repository**
   ```bash
   git clone https://github.com/<your-username>/apim-policy-cicd-lab.git
   cd apim-policy-cicd-lab
   ```

### Step 1: Deploy APIM Infrastructure

1. **Login to Azure CLI:**

````bash
   ```bash
   az login
````

2. **Review and customize parameters** in `infra/main.parameters.json`:

   - `resourceGroupName`: Your resource group name
   - `apiManagementServiceName`: Your APIM service name
   - `location`: Azure region
   - `publisherName` and `publisherEmail`: APIM publisher details

3. **Deploy the infrastructure:**

   ```bash
   cd infra
   chmod +x deploy.sh
   ./deploy.sh
   ```

   This creates:

   - Resource Group with unique suffix
   - APIM service instance (default: BasicV2 SKU)
   - API (`sample-api`) with operation (`get-data`)

4. **Note the deployment outputs** - you'll need the actual resource group and APIM service names for GitHub secrets.

### Step 2: Configure GitHub Actions

1. **Create an App Registration** for GitHub OIDC:

   ```bash
   # Create app registration
   az ad app create --display-name "SP-GitHub-APIM-Policy-Lab"

   # Create service principal
   az ad sp create --id <app-id-from-above>

   # Configure federated credentials for your GitHub repo
   az ad app federated-credential create \
     --id <app-id> \
     --parameters '{"name":"federated-cred-gha-update-policy","issuer":"https://token.actions.githubusercontent.com","subject":"repo:<OWNER>/<REPOSITORY>:ref:refs/heads/main","audiences":["api://AzureADTokenExchange"]}'
   ```

2. **Assign RBAC permissions** to the service principal:

   ```bash
   # Assign "Contributor" role to service principal
   az role assignment create --role contributor --assignee <app-id> --scope //subscriptions/<your-subscription-id>
   ```

3. **Configure GitHub repository secrets** (Settings → Secrets and variables → Actions):
   - `AZURE_CLIENT_ID`: App registration client ID
   - `AZURE_TENANT_ID`: Your Azure AD tenant ID
   - `AZURE_SUBSCRIPTION_ID`: Your subscription ID
   - `AZURE_RESOURCE_GROUP`: Deployed resource group name (with unique suffix)
   - `AZURE_APIM_NAME`: Deployed APIM service name (with unique suffix)

### (Optional) Update Policy & Manifest

By default, the workflow uses `policy_manifest.yaml` to map policies to APIs. You can customize this file to add more APIs or operations.

### Step 4: Test Policy Deployment

1. **(Optional) Make a policy change** - edit files in `policies/sample-api/`:

   - `api.xml`: Contains API-level policy (adds X-API-Version header)
   - `operations/get-data.xml`: Contains operation-level policy (adds request tracking)

2. **Commit and push** changes to trigger the workflow:

   ```bash
   git add .
   git commit -m "Update APIM policies"
   git push origin main
   ```

3. **Monitor the workflow** in GitHub Actions tab - it will:
   - Login to Azure using OIDC
   - Apply policies using `Azure/apim-policy-update@v1.0.0`
   - Output ETags for debugging

## What's Deployed

The infrastructure creates:

- **APIM Service**: BasicV2 SKU in Japan East region
- **Sample API**:

  - Path: `/sample-api`
  - Backend: `https://httpbin.org`
  - Operation: `GET /get-data` → calls `https://httpbin.org/get-data`

- **Policies**:
  All policies are deployed with default settings.

## Workflow Details

The GitHub Actions workflow (`.github/workflows/update-apim-policies.yaml`) triggers on:

- **push to main** affecting `policies/**` or `policy_manifest.yaml`
- **workflow dispatch** via Actions tab

**Key features:**

- OIDC authentication (no stored secrets)
- Targeted policy updates only
- ETag output for change tracking
- Fail-fast on errors

## Troubleshooting

**Common issues:**

- **403 Forbidden**: Check service principal role assignment and scope
- **Resource not found**: Verify `AZURE_APIM_NAME` and `AZURE_RESOURCE_GROUP` match deployed names (including unique suffixes)
- **Policy validation errors**: Ensure XML follows APIM policy schema
- **OIDC auth failures**: Verify federated credentials subject matches `repo:owner/repo:ref:refs/heads/main`

**Debugging tips:**

- Check workflow logs in GitHub Actions
- Verify resource names in Azure portal match GitHub secrets
- Test policies manually in Azure portal first

## Cleanup

To clean up all resources:

```bash
az group delete --name <your-resource-group-name> --yes --no-wait
```
