#!/usr/bin/env bash

set -euo pipefail

START_TIME=$(date +%s)

INSTALL_DIR="$1"

if [ ! -f "${INSTALL_DIR}/install-config.yaml" ]; then
  echo "install-config.yaml not found in ${INSTALL_DIR}. Exiting..." >&2
  exit 1
fi

echo "Generating ignition config for single-node cluster..."
openshift-install --dir="$INSTALL_DIR" create single-node-ignition-config

if [ -f "${INSTALL_DIR}/custom.ign" ]; then
  echo "Custom ignition file found. Merging with bootstrap ignition..."
  yq ". *+ load(\"${INSTALL_DIR}/custom.ign\")" ${INSTALL_DIR}/bootstrap-in-place-for-live-iso.ign \
    > "${INSTALL_DIR}/custom-sno.ign"
fi

chmod 644 "${INSTALL_DIR}"/*.ign

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))

# Terraform docker_container fails if the script completes too quickly
if [ $ELAPSED_TIME -lt 1 ]; then
  SLEEP_TIME=$((1 - ELAPSED_TIME))
  sleep $SLEEP_TIME
fi
