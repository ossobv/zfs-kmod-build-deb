OpenZFS kmod debian package builder
===================================

Usage::

    ./buildone.sh jammy

Builds packages in ``./build.single``:

.. code-block:: console

    $ ls -1 build.single/

    kmod-zfs-5.15.0-88-generic_2.1.13-1osso0_amd64.deb
    kmod-zfs-devel-5.15.0-88-generic_2.1.13-1osso0_amd64.deb
    kmod-zfs-devel_2.1.13-1osso0_amd64.deb
    libnvpair3_2.1.13-1osso0_amd64.deb
    libuutil3_2.1.13-1osso0_amd64.deb
    libzfs5-devel_2.1.13-1osso0_amd64.deb
    libzfs5_2.1.13-1osso0_amd64.deb
    libzpool5_2.1.13-1osso0_amd64.deb
    python3-pyzfs_2.1.13-1osso0_amd64.deb
    zfs-2.1.13.tar.gz
    zfs-dracut_2.1.13-1osso0_amd64.deb
    zfs-initramfs_2.1.13-1osso0_amd64.deb
    zfs-test_2.1.13-1osso0_amd64.deb
    zfs_2.1.13-1osso0_amd64.deb

Or build for many kernels using ``./buildmany.sh``:

.. code-block:: console

    $ find build -type d | LC_ALL=C sort

    build
    build/zfs-2.1.13
    build/zfs-2.1.13/zfs-2.1.13-osso1-5.15.0-72-generic+jammy
    build/zfs-2.1.13/zfs-2.1.13-osso1-5.15.0-73-generic+jammy
    build/zfs-2.1.13/zfs-2.1.13-osso1-5.15.0-75-generic+jammy
    build/zfs-2.1.13/zfs-2.1.13-osso1-5.15.0-78-generic+jammy
    build/zfs-2.1.13/zfs-2.1.13-osso1-5.15.0-79-generic+jammy
    build/zfs-2.1.13/zfs-2.1.13-osso1-5.15.0-82-generic+jammy
    build/zfs-2.1.13/zfs-2.1.13-osso1-5.15.0-83-generic+jammy
    build/zfs-2.1.13/zfs-2.1.13-osso1-5.15.0-84-generic+jammy
    build/zfs-2.1.13/zfs-2.1.13-osso1-5.15.0-86-generic+jammy
    build/zfs-2.1.13/zfs-2.1.13-osso1-5.15.0-87-generic+jammy
    build/zfs-2.1.13/zfs-2.1.13-osso1-5.15.0-88-generic+jammy


----------
Installing
----------

When installing on *Ubuntu*, we need the modules from ``kmod-zfs`` to
take precedence. They are in ``/lib/modules/.../extra``.

.. code-block:: diff

    --- /etc/depmod.d/ubuntu.conf
    +++ /etc/depmod.d/ubuntu.conf
    @@ -1 +1 @@
    -search updates ubuntu built-in
    +search extra updates ubuntu built-in

Install the modules. Make sure they match the kernel version (``uname -r``):

.. code-block:: console

    # dpkg -i kmod-zfs-5.15.0-88-generic_2.1.13-1osso0_amd64.deb

    # depmod -a

    # modinfo zfs | grep ^version:
    version:        2.1.13-1osso0

    # reboot

    # cat /sys/module/zfs/version
    2.1.13-1osso0

Install the userland tools. On *Ubuntu/Jammy* we first need to remove
(purge) the old packages:

.. code-block:: console

    # apt-get remove --purge \
        libnvpair3linux libuutil3linux libzfs4linux libzpool5linux \
        zfs-zed zfsutils-linux

    # dpkg -i \
        libnvpair3_2.1.13-1osso1_amd64.deb \
        libuutil3_2.1.13-1osso1_amd64.deb \
        libzfs5_2.1.13-1osso1_amd64.deb \
        libzpool5_2.1.13-1osso1_amd64.deb \
        zfs_2.1.13-1osso1_amd64.deb

This contains all the userland stuff you need, except for *ZFS-on-root
initramfs* requirements.

You might need to (re)enable some dependencies:

.. code-block:: console

    # systemctl list-unit-files | grep ^zfs
    zfs-import-cache.service        disabled        enabled
    zfs-import-scan.service         disabled        disabled
    zfs-import.service              masked          enabled
    zfs-load-key.service            masked          enabled
    zfs-mount.service               disabled        enabled
    zfs-scrub@.service              static          -
    zfs-share.service               disabled        enabled
    zfs-volume-wait.service         disabled        enabled
    zfs-zed.service                 disabled        enabled
    zfs-import.target               disabled        enabled
    zfs-volumes.target              disabled        enabled
    zfs.target                      disabled        enabled
    zfs-scrub-monthly@.timer        disabled        enabled
    zfs-scrub-weekly@.timer         disabled        enabled

    # systemctl enable \
        zfs-import-cache.service zfs-mount.service zfs-share.service \
        zfs-volume-wait.service zfs-zed.service zfs-import.target \
        zfs-volumes.target zfs.target

The bi-weekly default *Ubuntu* scrub cronjob is gone. You can enable one
of the above timers if you wish.

If your ``zfs-import-cache.service`` fails because ``zpool.cache`` is
empty, you can just generate it by doing a ``zpool import POOL``. Skip
``zpool export POOL``, as it would clear the ``zpool.cache`` again.

**NOTE**: So far untested: *ZFS-on-root.* You probably want to install the
appropriate ``zfs-initramfs`` and ``zfs-dracut``.


-------------------
Reproducible builds
-------------------

This setup contains some hacks/fixes to make builds reproducible.

Seeing the results:

.. code-block:: console

    $ ls -1 build/zfs-2.1.13

    zfs-2.1.13-osso1-5.15.0-79-generic+jammy
    zfs-2.1.13-osso1-5.15.0-84-generic+jammy
    zfs-2.1.13-osso1-5.15.0-88-generic+jammy

.. code-block:: console

    $ find build/zfs-2.1.13/zfs-2.1.13-*-generic+jammy \
        -type f -name '*.deb' | xargs md5sum | sed -e 's@  .*/@  @' |
        sort | uniq -c | awk '{print $3 "  (" $1 "x)"}' | LC_ALL=C sort

    kmod-zfs-5.15.0-79-generic_2.1.13-1osso1_amd64.deb  (1x)
    kmod-zfs-5.15.0-84-generic_2.1.13-1osso1_amd64.deb  (1x)
    kmod-zfs-5.15.0-88-generic_2.1.13-1osso1_amd64.deb  (1x)
    kmod-zfs-devel-5.15.0-79-generic_2.1.13-1osso1_amd64.deb  (1x)
    kmod-zfs-devel-5.15.0-84-generic_2.1.13-1osso1_amd64.deb  (1x)
    kmod-zfs-devel-5.15.0-88-generic_2.1.13-1osso1_amd64.deb  (1x)
    kmod-zfs-devel_2.1.13-1osso1_amd64.deb  (3x)
    libnvpair3_2.1.13-1osso1_amd64.deb  (3x)
    libuutil3_2.1.13-1osso1_amd64.deb  (3x)
    libzfs5-devel_2.1.13-1osso1_amd64.deb  (3x)
    libzfs5_2.1.13-1osso1_amd64.deb  (3x)
    libzpool5_2.1.13-1osso1_amd64.deb  (3x)
    python3-pyzfs_2.1.13-1osso1_amd64.deb  (3x)
    zfs-dracut_2.1.13-1osso1_amd64.deb  (3x)
    zfs-initramfs_2.1.13-1osso1_amd64.deb  (3x)
    zfs-test_2.1.13-1osso1_amd64.deb  (3x)
    zfs_2.1.13-1osso1_amd64.deb  (3x)


----
TODO
----

* Get (some of) the reproducible-package fixes merged upstream.
* Maybe replace ALIEN calls with a proper dpkg-buildpackage setup.
