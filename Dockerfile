ARG osdist=ubuntu oscodename=jammy
FROM harbor.osso.io/ossobv/$osdist:$oscodename

LABEL maintainer="Walter Doekes <wjdoekes+zfs@osso.nl>"
LABEL dockerfile-vcs=https://github.com/ossobv/zfs-kmod-build-deb

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -q update && \
    apt-get -qy install --no-install-recommends \
      ca-certificates wget \
      build-essential autoconf automake libtool gawk alien fakeroot dkms \
      libblkid-dev uuid-dev libudev-dev libssl-dev zlib1g-dev libaio-dev \
      libattr1-dev libelf-dev linux-headers-generic python3 python3-dev \
      python3-setuptools python3-cffi libffi-dev python3-packaging \
      debhelper-compat dh-python po-debconf python3-all-dev python3-sphinx

RUN groupadd --gid=1000 dev && \
    useradd --uid=1000 --gid=1000 --shell=/bin/sh --home-dir=/usr/src dev && \
    chown dev:dev /usr/src
USER 1000
WORKDIR /usr/src

COPY dpkg-repackage-reproducible which-is-latest-kernel /usr/src/
RUN mkdir build-targets

# Change these in .gitlab-ci.yml or on invocation instead of here...
ARG OPENZFS_VERSION=zfs-2.1.13 \
    OPENZFS_SOURCE_PREFIX=https://github.com/openzfs/zfs/releases/download

RUN wget "$OPENZFS_SOURCE_PREFIX/$OPENZFS_VERSION/$OPENZFS_VERSION.tar.gz" && \
    tar zxf "$OPENZFS_VERSION.tar.gz"

# Optional: KERNEL_VERSION=5.4.0-120-generic
ARG KERNEL_VERSION=
RUN . /etc/os-release && \
    test -n "$VERSION_CODENAME" && \
    if test -z "$KERNEL_VERSION"; then \
      eval $(./which-is-latest-kernel $VERSION_CODENAME | \
             tee /dev/stderr) && \
      echo "$VERSION" >build-targets/kernelver; \
    else \
      echo "$KERNEL_VERSION" >build-targets/kernelver; \
    fi && \
    # KERNEL_VERSION includes the "-generic"
    KERNEL_VERSION=$(cat build-targets/kernelver) && \
    echo "linux-headers-${KERNEL_VERSION}" >build-targets/kernelpkg

USER 0
RUN apt-get -qy install $(cat /usr/src/build-targets/kernelpkg)
USER 1000

WORKDIR /usr/src/$OPENZFS_VERSION
ARG RELEASE_SUFFIX=osso0
RUN set -x && \
    NCPU=$(awk '\
        /^processor[[:blank:]]/{n=$3} \
        END{if(!n||n<1)print 1;else print n}' /proc/cpuinfo) && \
    \
    # Update RELEASE version, the quickest way we know how:
    VER=$RELEASE_SUFFIX && \
    sed -i -e '\
        s/^\(RELEASE[[:blank:]]*=[[:blank:]]*[^[[:blank:]]*\).*/\1'$VER'/; \
        \
        /^srpm-common:/,/^$/{s@$(def)@$(def) --define "dist '$VER'"@}; \
        /^rpm-common:/,/^$/{s@$(def)@$(def) --define "dist '$VER'"@}; \
        \
        s/--bump=0/--keep-version/; \
    ' Makefile.in && \
    \
    # Make sure we get reproducible NT_GNU_BUILD_ID by ensuring the build
    # path is always the same. A better fix would be
    # -ffile-prefix-map=$rpmbuild=. -- but I'm not sure in which
    # CFLAGS/etc. we could add it. Especially since rpmbuild does the
    # Make invocation from that path. Possibly we can do this by
    # altering the .spec files where the %{_tmppath} is available.
    sed -i -e '\
        /^srpm-common:/,/^$/{s@=`mktemp[^`]*`@=/tmp/srpm;rm -rf /tmp/srpm;mkdir -p /tmp/srpm@}; \
        /^rpm-common:/,/^$/{s@=`mktemp[^`]*`@=/tmp/rpm;rm -rf /tmp/rpm;mkdir -p /tmp/rpm@}; \
        /^deb-utils:/,/^$/{s@=`mktemp[^`]*`@=/tmp/debu;rm -rf /tmp/debu;mkdir -p /tmp/debu@}; \
    ' Makefile.in && \
    \
    # Alas, the /tmp/(s)rpm workaround also requires single job mode.
    # Luckily there is a make -jMORE in a sub-make somewhere.
    NCPU=1 && \
    ./configure --enable-systemd \
        --with-linux=/usr/src/linux-headers-$(cat ../build-targets/kernelver) \
    && \
    make -j$NCPU deb-utils deb-kmod

ARG REPRODUCIBLE_HOST=zfs-kmod-build-deb
RUN HOSTNAME=$REPRODUCIBLE_HOST ../dpkg-repackage-reproducible *.deb
