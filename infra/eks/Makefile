.PHONY: initcheck deploy fmt validate plan apply destroy

init:
	terraform init

check: fmt validate plan

deploy: check apply

init:
	terraform init

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