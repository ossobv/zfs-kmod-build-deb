#!/bin/sh
set -eu
cd "$(dirname "$0")"

DISTRO=${1:-jammy}
KERNEL_VERSION=${2:-}  # auto-detect kernel
RELEASE_SUFFIX=${3:-osso0}
OUTPUT_DIR=${4:-./build.single}

OPENZFS_VERSION=${OPENZFS_VERSION:-zfs-2.1.13}

TAG=$(echo "build-$OPENZFS_VERSION-$RELEASE_SUFFIX-$DISTRO-$KERNEL_VERSION" |
      sed -e 's/-$//')

# Easiest fix would be to set this here using --hostname, but 'docker
# build' only has --add-host, which does not work for our purposes.
# See the "Build Host" replacements in 'dpkg-repackage-reproducible'
# instead.
REPRODUCIBLE_HOST=zfs-kmod-build-deb

if docker version | grep -F '24.0.5' -F; then
    # Observed on Ubuntu/Jammy with 24.0.5-0ubuntu1~22.04.1
    # Extraction using 'sh -c tar...' intermittently fails.
    echo 'Your docker is broken:' >&2
    echo https://github.com/moby/moby/issues/45689 >&2
    exit 1
fi

docker build \
    --progress=plain \
    --pull \
    --build-arg="oscodename=$DISTRO" \
    --build-arg="KERNEL_VERSION=$KERNEL_VERSION" \
    --build-arg="OPENZFS_VERSION=$OPENZFS_VERSION" \
    --build-arg="RELEASE_SUFFIX=$RELEASE_SUFFIX" \
    --build-arg="REPRODUCIBLE_HOST=$REPRODUCIBLE_HOST" \
    -t "$TAG" .

if ! mkdir -p "$OUTPUT_DIR"; then
    echo "$OUTPUT_DIR: output dir exists already. Aborting" >&2
    exit 2
fi

# Take the original .tar.gz, not the one made by rpmbuild/alien.
if ! docker run --rm "$TAG" sh -c \
        'mv *.deb .. && cd .. && tar -c *.tar.gz *.deb' |
        tar -C "$OUTPUT_DIR" -xv; then
    rm -rf "$OUTPUT_DIR"
    exit 3
fi
