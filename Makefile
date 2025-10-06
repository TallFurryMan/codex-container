# Makefile for building and testing the codex-tools Docker image

IMAGE_REGISTRY := docker.io/tallfurryman
IMAGE_NAME := codex-tools
IMAGE_TAG := $(shell git describe --tags --always --dirty)

DOCKER_SOCKET ?= /var/run/docker.sock
ifeq ("$(shell test -S "$(DOCKER_SOCKET)" && echo yes)","yes")
DOCKER_VOL := -v $(DOCKER_SOCKET):/var/run/docker.sock
endif
WORKSPACE ?= $(CURDIR)

help:
	@printf "Available targets:\n"\
		"  build   – Build the Docker image.\n"\
		"  test    – Run sanity checks inside the image (needs host Docker socket).\n"\
		"  shell   – Start interactive shell in a temporary container (for debugging).\n"

build:
	@echo "Building $(IMAGE_NAME) for all supported arches …"
	@docker buildx build --load --platform linux/amd64,linux/arm64 -t $(IMAGE_NAME) .

test: build
	@echo "Running tests inside container …"
	@docker run --rm $(DOCKER_VOL) \
	    -v $(CURDIR)/test.sh:/test.sh:ro \
	    $(IMAGE_NAME) bash /test.sh

shell: ENTRYPOINT := bash
shell: codex

codex:
	@echo "Starting interactive session for $(WORKSPACE) in temporary container."
	@echo "Using volume codex-data for session persistence."
	docker run -it --rm ${DOCKER_VOL} \
		-v $(WORKSPACE):/home/builder/workspace \
		-v codex-data:/home/builder/.codex \
		-v $(DOCKER_SOCKET):/var/run/docker.sock \
		$(IMAGE_NAME) $(ENTRYPOINT)

publish: build
	@echo "Publishing $(IMAGE_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG) to Docker Hub."
	@docker login $(IMAGE_REGISTRY)
	@docker tag $(IMAGE_NAME) $(IMAGE_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)
	docker push $(IMAGE_REGISTRY)/$(IMAGE_NAME):$(IMAGE_TAG)

all: test

clean:
	@echo "Removing image $(IMAGE_NAME) …"
	-docker rmi $(IMAGE_NAME)
