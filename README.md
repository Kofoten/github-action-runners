# Kofoten's Action Runners

Welcome to my personal Action Runners repository. I built this strictly for my own infrastructure because I despise bloat and overly complex configurations. This project is a pragmatic, highly opinionated, and bare-bones setup for deploying self-hosted Action Runner Controllers (ARC).

It does exactly what I need it to do—nothing more, nothing less. If you happen to find it useful, feel free to use it, but keep in mind that this was designed, maintained, and optimized for an audience of one.

## What's Inside

- **Custom Runner Images**: A clean `dotnet10` runner built on top of the standard actions-runner, injecting only the .NET 10 SDK and `zip`. Zero extra garbage.

- **Zero-Magic Automation**: A single `Makefile` handles the entire workflow: building the image, loading it directly into the `k8s.io` containerd namespace, and deploying the ARC Helm chart. Pushing local images to remote registries just to pull them back down is a waste of time.

- **Strict CI Scripts**: Dead-simple bash scripts that enforce my repository rules:
  - Strip `v` prefixes for clean SemVer.
  - Enforce that releases only happen from the `main` branch.
  - Validate that pushed tags strictly increase in version.

## Usage

Deploying a runner to a local Kubernetes cluster takes exactly one command:

```Bash
make all RUNNER=dotnet10 GITHUB_URL=https://github.com/Kofoten/happy-frog
```

This automates the entire flow:

1. Builds the `dotnet10` image locally using Docker Buildx.
2. Imports the image directly into `containerd` via `sudo ctr`.
3. Installs/upgrades the `gha-runner-scale-set` Helm chart using custom YAML values.

## License

This is released into the public domain under the Unlicense. Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means. Do whatever you want with it, just don't expect me to maintain it for you.

For more information, please refer to [https://unlicense.org](https://unlicense.org)
