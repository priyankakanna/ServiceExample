# ServiceExample Helm Chart

Helm chart for deploying the ServiceExample .NET application on Kubernetes.

## Features

- Deploys ServiceExample .NET application
- Optional dependencies: MongoDB, Redis, NATS
- Configurable resources and environment variables
- Health checks and readiness probes
- Support for auto-scaling

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installation

### Add the Helm repository

```bash
helm repo add serviceexample https://artifacthub.io/packages/helm/serviceexample/serviceexample
helm repo update
