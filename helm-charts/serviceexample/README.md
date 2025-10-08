# ServiceExample Helm Chart

A Helm chart for deploying ServiceExample .NET application with MongoDB, Redis, and NATS.

## Introduction

This chart deploys a .NET application built with Aspire that uses:
- MongoDB for persistent storage
- Redis for caching  
- NATS for event streaming

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

```bash
# Add the repository
helm repo add serviceexample https://priyankakanna.github.io/ServiceExample/helm-repo
helm repo update

# Install the chart
helm install my-serviceexample serviceexample/serviceexample
