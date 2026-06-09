# --- Usage ---
# make all RUNNER=dotnet10 GITHUB_URL=https://github.com/dev-frog/happy-frog
# make load RUNNER=dotnet10 GITHUB_URL=https://github.com/frog-corp

# --- Required Variables ---
ifndef RUNNER
	$(error RUNNER is not defined. Please specify a runner, e.g., 'make load RUNNER=dotnet10')
endif

ifndef GITHUB_URL
	$(error GITHUB_URL is not defined. Please specify a repo, e.g., 'make load GITHUB_URL=http://github.com/frog/happy-frog')
endif

# --- Auto-Generated & Optional Variables ---
TARGET_NAME    := $(notdir $(GITHUB_URL))
SCALE_SET_NAME ?= $(TARGET_NAME)-arc-runner
REGISTRY       ?= local
IMAGE_NAME     ?= $(RUNNER)-runner
TAG            ?= $(shell git rev-parse --short HEAD)
FULL_IMAGE     := $(REGISTRY)/$(IMAGE_NAME):$(TAG)

# Helm configuration
ARC_NAMESPACE  ?= arc-runners
HELM_CHART     ?= oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set

.PHONY: all build load deploy

all: build load deploy

build:
	@echo "Building runner image for $(RUNNER): $(FULL_IMAGE)..."
	docker buildx build --no-cache --pull -t $(FULL_IMAGE) -f $(RUNNER)-runner.Dockerfile . --load

load: build
	@echo "Checking sudo access..."
	@sudo -n -v || (echo "ERROR: No active sudo session. Run 'sudo -v' manually first, or run 'sudo make load'." && exit 1)
	@echo "Loading $(FULL_IMAGE) into containerd..."
	docker save $(FULL_IMAGE) | sudo ctr -n k8s.io images import -

deploy:
	@echo "Applying/Upgrading the ARC scale set for $(TARGET_NAME)..."
	helm upgrade --install $(SCALE_SET_NAME) $(HELM_CHART) \
		--namespace $(ARC_NAMESPACE) \
		-f $(RUNNER)-runner.values.yaml \
		--set githubConfigUrl=$(GITHUB_URL) \
		--set runnerScaleSetName=$(SCALE_SET_NAME) \
		--set template.spec.containers[0].image=$(FULL_IMAGE)
	@echo "Scale set $(SCALE_SET_NAME) successfully updated!"
