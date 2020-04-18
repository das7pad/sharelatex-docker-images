BRANCH_NAME ?= $(shell git rev-parse --abbrev-ref HEAD)
BUILD_NUMBER ?= local
GIT_COMMIT ?= $(shell git rev-parse HEAD)
RELEASE ?= $(shell git describe --tags --always | sed 's/-g/-/;s/^v//')

TARGET ?= lint-runner

SHARELATEX_DOCKER_REPOS ?= local/sharelatex
IMAGE_BARE = $(SHARELATEX_DOCKER_REPOS)/$(TARGET)
IMAGE_BRANCH_DEV = $(IMAGE_BARE):dev
IMAGE_BRANCH = $(IMAGE_BARE):$(BRANCH_NAME)
IMAGE = $(IMAGE_BRANCH)-$(BUILD_NUMBER)
IMAGE_FINAL = $(IMAGE_BARE):$(RELEASE)

pull_cache_branch_current:
	docker pull $(IMAGE_BRANCH)
	docker tag $(IMAGE_BRANCH) $(IMAGE)-cache

pull_cache_branch_dev:
	docker pull $(IMAGE_BRANCH_DEV)
	docker tag $(IMAGE_BRANCH_DEV) $(IMAGE)-cache

pull_cache:
	$(MAKE) pull_cache_branch_current \
	|| $(MAKE) pull_cache_branch_dev \
	|| echo 'Nothing cached yet!'

clean_pull_cache:
	docker rmi --force \
		$(IMAGE_BRANCH) \
		$(IMAGE_BRANCH_DEV) \

NODE_VERSION ?= 12.16.2

lint-runner/build:
	docker build \
		--tag $(IMAGE) \
		--cache-from $(IMAGE)-cache \
		--cache-from $(IMAGE) \
		--build-arg NODE_VERSION=$(NODE_VERSION) \
		--build-arg COMMIT=$(GIT_COMMIT) \
		--build-arg DATE=$(shell date --rfc-3339=s | sed 's/ /T/') \
		--build-arg RELEASE=$(RELEASE) \
		lint-runner

TEXLIVE_VERSION ?= 2017
TEXLIVE_SCHEME ?= basic
TEXLIVE_MIRROR ?= http://ftp.math.utah.edu/pub/tex/
TEXLIVE_REPOSITORY ?= \
	$(TEXLIVE_MIRROR)/historic/systems/texlive/$(TEXLIVE_VERSION)/tlnet-final/

ifeq (texlive,$(TARGET))
RELEASE=$(TEXLIVE_VERSION).1-$(TEXLIVE_SCHEME)
endif

texlive/build:
	docker build \
		--tag $(IMAGE) \
		--cache-from $(IMAGE)-cache \
		--build-arg COMMIT=$(GIT_COMMIT) \
		--build-arg DATE=$(shell date --rfc-3339=s | sed 's/ /T/') \
		--build-arg RELEASE=$(RELEASE) \
		--build-arg TEXLIVE_REPOSITORY=$(TEXLIVE_REPOSITORY) \
		--build-arg TEXLIVE_SCHEME=$(TEXLIVE_SCHEME) \
		--build-arg TEXLIVE_VERSION=$(TEXLIVE_VERSION) \
		texlive

lint-runner/test:
	docker run --rm $(IMAGE) eslint --version
	docker run --rm $(IMAGE) prettier-eslint --version

texlive/test:
	docker run --rm $(IMAGE) which \
		latex \
		latexmk \
		lualatex  \
		pdflatex \
		xelatex \
		/opt/synctex \

push:
	docker push $(IMAGE)
	docker tag $(IMAGE) $(IMAGE_BRANCH)
	docker push $(IMAGE_BRANCH)
	docker tag $(IMAGE) $(IMAGE_FINAL)
	docker push $(IMAGE_FINAL)

ifeq (master,$(BRANCH_NAME))
	docker tag $(IMAGE) $(IMAGE_BARE):latest
	docker push $(IMAGE_BARE):latest
endif

clean_push:
	docker rmi --force $(IMAGE_BRANCH)

ifeq (master,$(BRANCH_NAME))
	docker rmi --force $(IMAGE_BARE)
endif

ifeq (lint-runner,$(TARGET))
# set KEEP_LINT_RUNNER_IMAGE=1 to skip this
ifeq (,$(KEEP_LINT_RUNNER_IMAGE))
	docker rmi --force $(IMAGE_FINAL)
endif
endif
ifeq (texlive,$(TARGET))
# set KEEP_TEXLIVE_IMAGE=1 to skip this
ifeq (,$(KEEP_TEXLIVE_IMAGE))
	docker rmi --force $(IMAGE_FINAL)
endif
endif

clean:
	docker rmi --force \
		$(IMAGE) \
		$(IMAGE)-cache \
