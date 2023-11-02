OpenZFS kmod debian package builder
===================================

Usage::

    ./buildone.sh jammy 5.15.0-88-generic

Builds packages in ``./build.single``::

    $ ls -1 build.single/
    kmod-zfs-5.15.0-88-generic_2.1.13-1_amd64.deb
    kmod-zfs-devel-5.15.0-88-generic_2.1.13-1_amd64.deb
    kmod-zfs-devel_2.1.13-1_amd64.deb
    libnvpair3_2.1.13-1_amd64.deb
    libuutil3_2.1.13-1_amd64.deb
    libzfs5-devel_2.1.13-1_amd64.deb
    libzfs5_2.1.13-1_amd64.deb
    libzpool5_2.1.13-1_amd64.deb
    python3-pyzfs_2.1.13-1_amd64.deb
    zfs-2.1.13-1.src.rpm
    zfs-2.1.13.tar.gz
    zfs-dracut_2.1.13-1_amd64.deb
    zfs-initramfs_2.1.13-1_amd64.deb
    zfs-kmod-2.1.13-1.src.rpm
    zfs-test_2.1.13-1_amd64.deb
    zfs_2.1.13-1_amd64.deb

Or build many at once::

    ./buildmany.sh

Builds packages in ``./builds``::

    $ find build -type d | LC_ALL=C sort
    build
    build/zfs-2.1.13
    build/zfs-2.1.13/zfs-2.1.13-5.15.0-72-generic-jammy
    build/zfs-2.1.13/zfs-2.1.13-5.15.0-73-generic-jammy
    build/zfs-2.1.13/zfs-2.1.13-5.15.0-75-generic-jammy
    build/zfs-2.1.13/zfs-2.1.13-5.15.0-78-generic-jammy
    build/zfs-2.1.13/zfs-2.1.13-5.15.0-79-generic-jammy
    build/zfs-2.1.13/zfs-2.1.13-5.15.0-82-generic-jammy
    build/zfs-2.1.13/zfs-2.1.13-5.15.0-83-generic-jammy
    build/zfs-2.1.13/zfs-2.1.13-5.15.0-84-generic-jammy
    build/zfs-2.1.13/zfs-2.1.13-5.15.0-86-generic-jammy
    build/zfs-2.1.13/zfs-2.1.13-5.15.0-87-generic-jammy
    build/zfs-2.1.13/zfs-2.1.13-5.15.0-88-generic-jammy


----
TODO
----

Not all packages that should be are reproducible yet. This makes it
harder to package these properly (because filenames in a repository
should be unique):

::

    $ find build/zfs-2.1.13/zfs-2.1.13-5.15.0-8{7,8}-generic-jammy \
        -type f -name '*.deb' | xargs md5sum | sed -e 's@  .*/@  @' | \
        sort | uniq -c | LC_ALL=C sort -k3
      1 1059c635f16c3d0272c3d624164c5bc1  kmod-zfs-5.15.0-87-generic_2.1.13-1_amd64.deb
      1 d27d2216029636b25f8f985ad6dccb5d  kmod-zfs-5.15.0-88-generic_2.1.13-1_amd64.deb
      1 bd55a8c816d1ac94dc9467da90360680  kmod-zfs-devel-5.15.0-87-generic_2.1.13-1_amd64.deb
      1 e048f6b72de5792da0ad063e56de4d9e  kmod-zfs-devel-5.15.0-88-generic_2.1.13-1_amd64.deb
      2 e42aef9cc32b23e30acf99d3eb5f0eb1  kmod-zfs-devel_2.1.13-1_amd64.deb
      1 226e6c35cff1ee3701309d68135a6ec2  libnvpair3_2.1.13-1_amd64.deb
      1 fff7376d5a9191d9e3b8d5c716b26353  libnvpair3_2.1.13-1_amd64.deb
      1 21ccb7c3b10b3545d2b92a0d7aeeca12  libuutil3_2.1.13-1_amd64.deb
      1 44b006903b9136a2e85d83f336a2a5b9  libuutil3_2.1.13-1_amd64.deb
      2 e7043009b486bd4cfcfe6c535c3e60f2  libzfs5-devel_2.1.13-1_amd64.deb
      1 0b9466de7721b591e3fa4137f7b4d5b6  libzfs5_2.1.13-1_amd64.deb
      1 2f1604956875d3809f805618a0e36b32  libzfs5_2.1.13-1_amd64.deb
      1 26d068b9e72cec6a1c851da1baceec30  libzpool5_2.1.13-1_amd64.deb
      1 97176ccbd01107cc92f022000fc0ce7a  libzpool5_2.1.13-1_amd64.deb
      2 6e0de3083df0f19d62061780b14b5cff  python3-pyzfs_2.1.13-1_amd64.deb
      2 0b791ec8769ff8be2767c12bcbc36347  zfs-dracut_2.1.13-1_amd64.deb
      2 89aad98d0a0453fd059421712b11131a  zfs-initramfs_2.1.13-1_amd64.deb
      1 cb8cb1301c447bcdc68bf82fd71a24d3  zfs-test_2.1.13-1_amd64.deb
      1 d0dc56cc1f9c67024fdc17f94924009a  zfs-test_2.1.13-1_amd64.deb
      1 17b746efda4ce094687bf7a96a256446  zfs_2.1.13-1_amd64.deb
      1 83a16eb68903e13d80b7e8793743492d  zfs_2.1.13-1_amd64.deb
