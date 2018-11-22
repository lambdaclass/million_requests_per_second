.PHONY: server tsung

server:
	./setup.sh > /dev/null
	./rebar3 shell

tsung:
	./setup.sh > /dev/null
	tsung -f tsung_client.xml start
