#!/bin/sh
set -eu
cd "$(dirname "$0")"

DISTRO=${1:-jammy}
KERNEL_VERSION=${2:-}  # auto-detect kernel
OUTPUT_DIR=${3:-./build.single}

OPENZFS_VERSION=${OPENZFS_VERSION:-zfs-2.1.13}

TAG=$(echo "build-$OPENZFS_VERSION-$DISTRO-$KERNEL_VERSION" |
      sed -e 's/-$//')

docker build \
    --progress=plain \
    --pull \
    --build-arg="oscodename=$DISTRO" \
    --build-arg="KERNEL_VERSION=$KERNEL_VERSION" \
    --build-arg="OPENZFS_VERSION=$OPENZFS_VERSION" \
    -t "$TAG" .

mkdir -p "$OUTPUT_DIR"
if ! docker run "$TAG" sh -c 'tar -c *.tar.gz *.rpm *.deb' |
        tar -C "$OUTPUT_DIR" -xv; then
    rm -rf "$OUTPUT_DIR"
    false
fi
