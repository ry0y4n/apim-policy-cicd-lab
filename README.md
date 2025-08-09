# dev-apim-policy — Sample using Azure/apim-policy-update

This repository is a sample showing how to apply Azure API Management (APIM) policies via GitHub Actions using the official action "Azure/apim-policy-update". The source of truth is `policy_manifest.yaml` plus the XML policies under `policies/`. On push to `main` (or manual dispatch), the workflow applies the policies to APIM.

## Repository layout

- `policy_manifest.yaml`: Manifest describing which API/operations get which policy files
- `policies/`:
  - `sample-api/api.xml`: API-level policy (example)
  - `sample-api/operations/get-data.xml`: Operation-level policy (example)
- `.github/workflows/update-apim-policies.yaml`: Workflow that applies policies to APIM

## Actions used

- Auth: `azure/login@v2`
- Apply policies: `Azure/apim-policy-update@v1.0.0`

## Prerequisites (in Azure)

1. An APIM instance (note the resource group name and APIM name)
2. An App Registration (service principal) configured with GitHub OIDC federated credentials
3. Appropriate role assignment for the service principal to write to APIM
   - e.g., at the Resource Group or APIM resource scope: "Contributor" or "API Management Service Contributor"

## GitHub Secrets

Add these repository-level secrets under Settings > Secrets and variables > Actions:

- `AZURE_CLIENT_ID`: Client ID of the App Registration with federated credentials
- `AZURE_TENANT_ID`: Azure AD tenant ID
- `AZURE_SUBSCRIPTION_ID`: Subscription ID
- `AZURE_RESOURCE_GROUP`: Resource Group name
- `AZURE_APIM_NAME`: APIM name

## How the workflow runs

`.github/workflows/update-apim-policies.yaml` triggers on:

- Push to `main` affecting `policies/**` or `policy_manifest.yaml`
- Manual dispatch (`workflow_dispatch`)

Steps:

1. Checkout repository
2. Login to Azure using `azure/login@v2` (OIDC)
3. Apply policies based on `policy_manifest.yaml` using `Azure/apim-policy-update@v1.0.0`
4. Output the last ETag (for debugging)

## Example policy_manifest.yaml

Refer to the action’s docs for the full schema. The snippet below matches this sample layout.

```yaml
apis:
  - name: sample-api
    policy: policies/sample-api/api.xml
    operations:
      - name: get-data
        policy: policies/sample-api/operations/get-data.xml
```

- Provide API-level policy (`api.xml`) and per-operation policies (`operations/*.xml`).
- XML must conform to the APIM policy schema.

## Usage

1. Edit the XML under `policies/` and update `policy_manifest.yaml` as needed
2. Push to `main` to trigger automatic apply to APIM
3. Or run it manually from the Actions tab ("Run workflow")

## Troubleshooting

- Authorization errors: Check service principal role assignment and scope (RG/APIM)
- Name mismatch: Ensure `AZURE_APIM_NAME` and `AZURE_RESOURCE_GROUP` match your environment
- XML validation: Verify your APIM policy XML conforms to the schema (no unsupported tags/attributes)

## Customization tips

- Change trigger paths/branch or the `policy_manifest_path` in the workflow as needed
- Keep secrets out of YAML; use GitHub Secrets
- Consider extending scope to manage product/global policies in addition to API/operation policies (if needed)
