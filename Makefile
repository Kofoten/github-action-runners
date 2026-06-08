# --- Usage ---
# make all RUNNER=dotnet10
# make load RUNNER=dotnet10

# --- Required Variables ---
ifndef RUNNER
$(error RUNNER is not defined. Please specify a runner, e.g., 'make load RUNNER=dotnet10')
endif

# --- Optional Variables ---
REGISTRY       ?= local
IMAGE_NAME     ?= $(RUNNER)-runner
TAG            ?= $(shell git rev-parse --short HEAD)
FULL_IMAGE     := $(REGISTRY)/$(IMAGE_NAME):$(TAG)

# Helm configuration
ARC_NAMESPACE  ?= arc-runners
SCALE_SET_NAME ?= $(RUNNER)-arc-runner
HELM_CHART     ?= oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

.PHONY: all build load deploy

all: build load deploy

build:
	@echo "Building runner image for $(RUNNER): $(FULL_IMAGE)..."
	docker buildx build --no-cache -t $(FULL_IMAGE) -f $(RUNNER)-runner.Dockerfile . --load

load: build
	@echo "Loading $(FULL_IMAGE) into containerd..."
	docker save $(FULL_IMAGE) | sudo ctr -n k8s.io images import -

deploy:
	@echo "Applying/Upgrading the ARC scale set for $(RUNNER)..."
	helm upgrade --install $(SCALE_SET_NAME) $(HELM_CHART) \
		--namespace $(ARC_NAMESPACE) \
		-f $(RUNNER)-runner.values.yaml \
		--set template.spec.containers[0].image=$(FULL_IMAGE)
	@echo "Scale set $(SCALE_SET_NAME) successfully updated!"