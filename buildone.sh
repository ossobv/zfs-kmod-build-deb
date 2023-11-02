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
if docker version | grep -F '24.0.5' -F; then
    # Observed on Ubuntu/Jammy with 24.0.5-0ubuntu1~22.04.1
    echo 'Your docker is broken:' >&2
    echo https://github.com/moby/moby/issues/45689 >&2
    exit 1
fi
if ! docker run --rm "$TAG" sh -c 'tar -c *.tar.gz *.rpm *.deb' |
        tar -C "$OUTPUT_DIR" -xv; then
    rm -rf "$OUTPUT_DIR"
    false
fi
