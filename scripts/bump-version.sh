#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <new-version>"
  exit 1
fi

NEW_VERSION=$1
CHART_FILE="helm-charts/serviceexample/Chart.yaml"

sed -i "s/^version: .*/version: $NEW_VERSION/" $CHART_FILE

echo "Version bumped to $NEW_VERSION"
echo "Chart.yaml version updated:"
grep "^version:" $CHART_FILE
