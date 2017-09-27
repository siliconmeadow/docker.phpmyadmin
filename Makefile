# Makefile for a standard repo with associated container

##### These variables need to be adjusted in most repositories #####

# This repo's root import path (under GOPATH).
# PKG := github.com/drud/repo_name

# Docker repo for a push
DOCKER_REPO ?= drud/phpmyadmin

# Top-level directories to build
# SRC_DIRS := files drudapi secrets utils

# Version variables to replace in build, The variable VERSION is automatically pulled from git committish so it doesn't have to be added
# These are replaced in the $(PKG).version package.
# VERSION_VARIABLES = ThisCmdVersion ThatContainerVersion

# These variables will be used as the defaults unless overridden by the make command line
#ThisCmdVersion ?= $(VERSION)
#ThatContainerVersion ?= drud/nginx-php-fpm7-local

# Optional to docker build
# DOCKER_ARGS =

# VERSION can be set by
  # Default: git tag
  # make command line: make VERSION=0.9.0
# It can also be explicitly set in the Makefile as commented out below.

# This version-strategy uses git tags to set the version string
# VERSION can be overridden on make commandline: make VERSION=0.9.1 push
VERSION := $(shell git describe --tags --always --dirty)
#
# This version-strategy uses a manual value to set the version string
#VERSION := 1.2.3

# Each section of the Makefile is included from standard components below.
# If you need to override one, import its contents below and comment out the
# include. That way the base components can easily be updated as our general needs
# change.
# include build-tools/makefile_components/base_build_go.mak
include build-tools/makefile_components/base_build_python-docker.mak
include build-tools/makefile_components/base_container.mak
include build-tools/makefile_components/base_push.mak
# include build-tools/makefile_components/base_test_go.mak
#include build-tools/makefile_components/base_test_python.mak


# Additional targets can be added here
# Also, existing targets can be overridden by copying and customizing them.
test: container
	@docker stop phpmyadmin-test || true
	@docker rm phpmyadmin-test || true
	docker run -p 1081:80 -d --name phpmyadmin-test -d $(DOCKER_REPO):$(VERSION)
	CONTAINER_NAME=phpmyadmin-test test/containercheck.sh
	@docker stop phpmyadmin-test && docker rm phpmyadmin-test
