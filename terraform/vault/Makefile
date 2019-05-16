help: ## list targets & descriptions
	@cat makefile* | grep -e '^[a-za-z_-]+:.*?## .*$$' | sort | awk 'begin {fs = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

upgrade: ## helm upgrade 
	helm upgrade --install vault charts -f charts/values/unseal.yaml -f charts/values/tls.yaml -f charts/values/storage.yaml -f charts/values/deploy.yaml

export-env: ## export env for k8s auth backend
	export TF_VAR_VAULT_SA_NAME=$(kubectl get sa vault-auth -o jsonpath="{.secrets[*]['name']}")
	export TF_VAR_SA_CA_CRT=$(kubectl get secret $TF_VAR_VAULT_SA_NAME -o jsonpath="{.data['ca\.crt']}" | base64 --decode; echo)
	export TF_VAR_SA_JWT_TOKEN=$(kubectl get secret $TF_VAR_VAULT_SA_NAME -o jsonpath="{.data.token}" | base64 --decode; echo)
	export TF_VAR_K8S_HOST=$(kubectl config view --minify --raw | grep server | cut -d"/" -f3)
