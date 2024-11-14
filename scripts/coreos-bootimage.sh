#!/usr/bin/env bash
# Download the latest CoreOS boot image for a given architecture, platform and format
# Usage: coreos-bootimage.sh [architecture] [platform] [format]
# Example: coreos-bootimage.sh aarch64 metal pxe

set -euo pipefail

START_TIME=$(date +%s)

ARCHITECTURE="${1:-$(uname -m)}"
PLATFORM="${2:-qemu}"
FORMAT="${3:-qcow2.xz}"

DECOMPRESS=true
if [[ "$FORMAT" == "pxe" ]]; then
  DECOMPRESS=false
fi

echo "Starting CoreOS boot image download..."
echo "Architecture: $ARCHITECTURE"
echo "Platform: $PLATFORM"
echo "Format: $FORMAT"

echo "Fetching CoreOS stream metadata..."
openshift-install coreos print-stream-json |
  jq --arg architecture "$ARCHITECTURE" --arg platform "$PLATFORM" --arg format "$FORMAT" \
    -r '.architectures[$architecture].artifacts[$platform] | .release, .formats[$format][].location' | {
  read -r release
  echo "Release version: $release"
  while read -r location; do
    filename="${location##*/}"
    
    if ls "${filename%.*}"* 1> /dev/null 2>&1; then
      echo "File ${filename%.*}* already exists. Skipping download."
      continue
    else
      index_count="$(ls -1q index.txt* 2>/dev/null || true | wc -l)"
      if [ "$index_count" -gt 0 ]; then mv index.txt{,.$index_count}; fi

      echo "Downloading $filename from $location..."
      curl -Lo "$filename" "$location"
      echo "$location" >> index.txt
    fi
    
    if [[ "$filename" =~ \.(xz|gz)$ ]] && [[ "$DECOMPRESS" == true ]]; then
      echo "Decompressing $filename..."
      case "$filename" in
        *.xz)
          unxz "$filename"  
          filename="${filename%.xz}"
          ;;
        *.gz) 
          gunzip "$filename"  
          filename="${filename%.gz}"
          ;;
      esac
    fi
    
    echo "Creating symlink for $filename..."
    ln -sf "$filename" "${filename/$release/latest}"
  done
}

echo "CoreOS boot image download completed."

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME - START_TIME))

# Terraform docker_container fails if the script completes too quickly
if [ $ELAPSED_TIME -lt 1 ]; then
  SLEEP_TIME=$((1 - ELAPSED_TIME))
  sleep $SLEEP_TIME
fi
