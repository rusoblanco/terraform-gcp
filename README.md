```
  ________                     .__           _________ .__                   .___
 /  _____/  ____   ____   ____ |  |   ____   \_   ___ \|  |   ____  __ __  __| _/
/   \  ___ /  _ \ /  _ \ / ___\|  | _/ __ \  /    \  \/|  |  /  _ \|  |  \/ __ | 
\    \_\  (  <_> |  <_> ) /_/  >  |_\  ___/  \     \___|  |_(  <_> )  |  / /_/ | 
 \______  /\____/ \____/\___  /|____/\___  >  \______  /____/\____/|____/\____ | 
        \/             /_____/           \/          \/                       \/ 
```
# Tools

# Reference

- GCloud: https://cloud.google.com/sdk/gcloud/reference

# Steps
## Create Project

On the Gcloud web interface, create a project attached to the billing account provided by TCK Financial Team.

It's highly recommended that the Project ID must be like a composed short name like "client-project": myproj-web, myproj-api o something like that, because that ID will be reused on each resource deployed. Be free to set the description as you need.

## Enable APIs

If the Google projects has been created and not reused, some APIs must be enabled before deploy any configuration via Terraform scripts, the basic ones are the following ones:

```
gcloud services enable cloudresourcemanager.googleapis.com && \
gcloud services enable compute.googleapis.com && \
gcloud services enable container.googleapis.com && \
gcloud services enable storage-component.googleapis.com 
```

In some ways, more APIs could be deployed via Terraform modules, but you need to be aware about GCP behaviour with the batch deployment. This resource kind doesnt allows to enable APIs at the same time so in the providers.tf file this code must be enabled, always:

```hcl
provider "google" {
  version     = "<4.0,>= 3.25"
  credentials = file("account.json")
  batching    {
    enable_batching = false
    send_after      = "2m"
  }
}
```
## Create Service Account

To enable Terraform deployments we must create a Google Service Account on the desired Project, then export the JSON an refeer that JSON file on the code, same providers.tf file that showed before. The file has been determined to be named as "account.json", so let's create this file.

First, create the Service Account:
```bash
gcloud iam service-accounts create terraform \
  --description="Terraform Infrastructure as a Code" \
  --display-name="terraform"
```

Enable the generated Service Account:
```bash
gcloud iam service-accounts enable terraform@<GCP_PROJECT_ID>.iam.gserviceaccount.com
```

Export the JSON to your relative Terraform project path:
```bash
gcloud iam service-accounts keys create account.json \
  --iam-account terraform@<GCP_PROJECT_ID>.iam.gserviceaccount.com
```

Attach IAM policy to the Service Account, the one required is "editor":
```bash
gcloud projects add-iam-policy-binding terraform \
  --member serviceAccount:terraform@$<GCP_PROJECT_ID>.iam.gserviceaccount.com \
  --role roles/editor
```

## Create Terraform Bucket storage

On this step, we need a bucket to provided a storage where the tfplan would be stored to make our infrastructure persistent. So we must create one, take note that the bucket name must be unique in the whole Google cloud; here is the proposal regex name: "client-proj-tf"
```bash
gsutil mb -p <GCP_PROJECT_ID> -l <REGION> gs://"client-proj-tf"
```

Enable bucket versioning on it:
```bash
gsutil versioning set on gs://"client-proj-tf"
```

Now, set this backend in the providers.tf file of your Terraform project:

```hcl
terraform {
  required_version = "<0.13,>=0.12"
  backend "gcs" {
    bucket  = "client-proj-tf"
    prefix  = "${var.env}/tfstate"
  }
}
```

## Use of Pre-Commit hook
TBD

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Error: no lines in file
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
Have fun!
