.PHONY: server tsung infra ops

server:
	./setup.sh > /dev/null
	./rebar3 shell

tsung:
	./setup.sh > /dev/null
	tsung -f tsung_client.xml start

infra:
	terraform init devops/
	terraform apply devops/

ops:
	ansible-playbook -v -i inventory devops/main.yml
