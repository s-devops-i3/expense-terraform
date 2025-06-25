terraform init -backend-config=dev-env/state.tfvars
terraform destroy -var-file=dev-env/main.tfvars -auto-approve