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

So far untested: *ZFS on root.* You probably want to install the
appropriate ``zfs-initramfs`` package then as well, and likely others.
We may run into conflicts when installing e.g. ``libzpool5`` because
``libzpool5linux`` already has a
``/lib/x86_64-linux-gnu/libzpool.so.5.0.0``.


-------------------
Reproducible builds
-------------------

This setup contains some hacks/fixes to make builds reproducible.

Seeing the results:

.. code-block:: console

    $ ls -1 build/zfs-2.1.13

    zfs-2.1.13-5.15.0-79-generic-jammy
    zfs-2.1.13-5.15.0-84-generic-jammy
    zfs-2.1.13-5.15.0-88-generic-jammy

.. code-block:: console

    $ find build/zfs-2.1.13/zfs-2.1.13-5.15.0-*-generic-jammy \
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

* Fix the "zfs-2.1.13-5.15.0-79-generic-jammy" path to also contain "1osso1".
* Get (some of) the reproducible-package fixes merged upstream.
* Maybe replace ALIEN calls with a proper dpkg-buildpackage setup.
