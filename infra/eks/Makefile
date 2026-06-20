.PHONY: check deploy fmt validate plan apply destroy

check: fmt validate plan

deploy: check apply

# Terraform
fmt:
	terraform fmt

validate:
	terraform validate

plan:
	terraform plan -out=tfplan

apply:
	terraform apply -auto-approve tfplan

destroy:
	terraform destroy -auto-approve