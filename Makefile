.PHONY: ssh

ifeq (ssh, $(firstword $(MAKECMDGOALS)))
  vmbox := $(word 2, $(MAKECMDGOALS))
  $(eval $(vmbox):;@true)
endif

base = "CentOS"

help:
	@echo 'Usage:'
	@echo '  make <target> [base=CentOS|CoreOS]'
	@echo
	@echo 'Targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo

validate:
	@cd vagrant/$(base) && vagrant validate

status:      ## Get Cluster Status
	@cd vagrant/$(base) && vagrant status

load:        ## Load KUBECONFIG for the Cluster
	@KUBECONFIG=$(shell pwd)/.kube/config bash

create:
	@cd vagrant/$(base) && vagrant up

up: create load    ## Up Cluster

down:  	     ## Stop Cluster
	@cd vagrant/$(base) && vagrant halt

stop: down   ## Stop Cluster (same as "down")

destroy:     ## Destroy the Cluster
	@cd vagrant/$(base) && vagrant destroy -f

provision:   ## (Re)provision the Cluster
	@cd vagrant/$(base) && vagrant provision

whoup:       ## Show Running VMs
	@cd vagrant/$(base) && vagrant status --machine-readable | awk -F, 'BEGIN{printf("VM Name             | State\n--------------------+------------\n")}$$3 == "state" {printf("%-20s| %s\n", $$2, $$4)}END{printf("--------------------+------------\n")}'

who: whoup

ssh:         ## SSH Jump Into VM
	@cd vagrant/$(base) && vagrant ssh $(vmbox)

info:
	@ruby -r ipaddr -e 'load "config.rb"; print("Nodes: \n"); (0..$$worker_count).each { |i| print("  ", (i == 0) ? "k8s-master" : "k8s-worker-%d" % i, "\t  ", (IPAddr.new $$cluster_ips)|(1+i), "\n")}; print("\nLoadBalancers: ", $$metallb_ips, "\n")'
