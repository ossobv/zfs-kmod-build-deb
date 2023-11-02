#!/bin/sh
set -eu
cd "$(dirname "$0")"

OPENZFS_VERSION=zfs-2.1.13

build_if_not_exists() {
    local codename="$1"; shift
    local uname_r_tpl="$1"; shift
    local version uname_r
    for version in "$@"; do
        uname_r=${uname_r_tpl%#*}$version${uname_r_tpl#*#}
        _build_one_if_not_exists "$codename" "$uname_r"
    done
}

_build_one_if_not_exists() {
    local codename="$1"
    local uname_r="$2"
    local dir="\
build/$OPENZFS_VERSION/$OPENZFS_VERSION-$uname_r-$codename"
    if ! test -d "$dir"; then
        if ! OPENZFS_VERSION=$OPENZFS_VERSION ./buildone.sh \
                "$codename" "$uname_r" "$dir"; then
            echo "ERROR: at $dir -- kernel not found? mkdir to skip" >&2
            exit 1
        fi
    fi
}

# apt-cache search linux-headers-5.15.0- | sed -ne 's/^linux-headers-[^-]*-\([0-9]*\)-generic .*/\1/p' | sort -rn | tr '\n' ' '; echo
build_if_not_exists jammy '5.15.0-#-generic' 88 87 86 84 83 82 79 78 75 73 72 25
# apt-cache search linux-headers-5.4.0- | sed -ne 's/^linux-headers-[^-]*-\([0-9]*\)-generic .*/\1/p' | sort -rn | tr '\n' ' '; echo
#build_if_not_exists focal '5.4.0-#-generic' 150 149 148 147 146 144 139 137 136 135 132 131 128 126 125 124 122 121 120 117 113 110 109 107 105 104 100 99 97 96 94 92 91 90 89 88 86 84 81 80 77 74 73 72 71 70 67 66 65 64 62 60 59 58 54 53 52 51 48 47 45 42 40 39 37 33 31 29 28 26
