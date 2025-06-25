terraform init -backend-config=dev-env/state.tfvars
terraform apply -var-file=dev-env/main.tfvars -auto-approve