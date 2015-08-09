TIER ?= dev
BASE_PATH ?= $(PWD)
TAG ?= 0.3.3
MACHINE_ALIAS ?= ustwosite

project_name := ustwosite
# project_name := usweb

## CLI aliases ################################################################
RM := rm -rf
CP := cp
DOCKER := docker
DOCKER.cp := $(DOCKER) cp
DOCKER.exec := $(DOCKER) exec -it
DOCKER.rm := $(DOCKER) rm -f
DOCKER.run := $(DOCKER) run -d
DOCKER.volume := $(DOCKER) run
DOCKER.task := $(DOCKER) run --rm -it
DOCKER_MACHINE := docker-machine
MACHINE_IP = $(shell $(DOCKER_MACHINE) ip $(MACHINE_ALIAS))
ANSIBLE := ansible
ANSIBLE.play := ansible-playbook
ANSIBLE.shell = $(ANSIBLE) $(MACHINE_IP) --become -m shell
###############################################################################

# Make sure there is no default task
all:

include tasks/*.mk

## Automatic variables ########################################################
#
#  $@ The filename representing the target.
#  $% The filename element of an archive member specification.
#  $< The filename of the first prerequisite.
#  $? The names of all prerequisites that are newer than the target, separated
#     by spaces.
#  $^ The filenames of all the prerequisites, separated by spaces.
#  $+ Similar to $^, this is the names of all the prerequisites separated by
#     spaces, except that $+ includes duplicates.
#  $* The stem of the target filename. A stem is typically a filename without
#     its suffix.
#
###############################################################################


init: vault-create app-create proxy-create
init-rm: vault-rm app-rm proxy-rm
deploy: app-rm proxy-rm app-create proxy-create

ps:
	@$(DOCKER) ps -a \
		--filter 'label=project_name=$(project_name)' \
		--filter 'label=tier=$(TIER)'

iid-production: TIER := production
iid-production: MACHINE_ALIAS := ustwositepro
iid-production: static-iid

rm-production: TIER := production
rm-production: static-rm

init-production: TIER := production
init-production: MACHINE_ALIAS := ustwositepro
init-production: STATIC_HTTP_PORT := 80
init-production: STATIC_HTTPS_PORT := 443
init-production: static-create static-iid

rollback-production: TIER := production
rollback-production: STATIC_HTTP_PORT := 80
rollback-production: STATIC_HTTPS_PORT := 443
rollback-production: rollback-template

deploy-production: proxy-pull rm-production init-production

deploy-staging: TIER := staging
deploy-staging: PROXY_HTTP_PORT := 80
deploy-staging: PROXY_HTTPS_PORT := 443
deploy-staging: deploy
