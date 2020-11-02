HOTFIX_VERSION = 8.3.6.46
HOTFIX_URL = http://download.ahsay.com/dev/hot-fixes/83/public/obm-nix-v83646.zip
.PHONY: stable hotfix clean-stable clean-hotfix clean

stable: clean-stable
	docker build -t jeffre/obm:latest .
	docker tag jeffre/obm:latest jeffre/obm:stable

hotfix: clean-hotfix
	docker build -t jeffre/obm:hotfix --build-arg HOTFIX=$(HOTFIX_URL) .
	docker tag jeffre/obm:hotfix jeffre/obm:hotfix-$(HOTFIX_VERSION)

clean-stable:
	-docker rm -f `docker ps -aq \
	    --filter "ancestor=jeffre/obm:latest" \
	    --filter "ancestor=jeffre/obm:stable"`
	-docker rmi jeffre/obm:latest jeffre/obm:stable

clean-hotfix:
	-docker rm -f `docker ps -aq \
	  --filter "ancestor=jeffre/obm:hotfix-latest \
	  --filter "ancestor=jeffre/obm:hotfix-$(HOTFIX_VERSION)"`
	-docker rmi jeffre/obm:hotfix-latest jeffre/obm:hotfix-$(HOTFIX_VERSION)

clean: clean-stable clean-hotfix
