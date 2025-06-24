env=$1
action=$2
if [ -z $env ]; then
  echo -e "\e[31mInput missing env(dev|prod)\e[0m"
  exit 1
fi

if [ -z $action ]; then
  echo -e "\e[31mAction missing(apply|destroy)\e[0m"
  exit 1
fi

terraform init -backend-config=$env-env/state.tfvars
terraform $action -var-file=dev-$env-env/main.tfvars
