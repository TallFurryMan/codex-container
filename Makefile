# Makefile for building and testing the codex-tools Docker image

IMAGE_NAME := codex-tools
DOCKER_SOCKET ?= /var/run/docker.sock
ifeq ("$(shell test -S $(DOCKER_SOCKET) && echo yes)","yes")
DOCKER_VOL := -v $(DOCKER_SOCKET):/var/run/docker.sock
else
endif

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

shell:
	@docker run -it --rm -v $(DOCKER_SOCKET):/var/run/docker.sock $(IMAGE_NAME) bash
