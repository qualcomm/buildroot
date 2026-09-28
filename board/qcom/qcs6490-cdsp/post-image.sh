#!/bin/sh
# SPDX-License-Identifier: BSD-3-Clause
#
# Assemble the standalone artifacts consumed by the QCS6490 CDSP workflow:
# vmlinux, initrd, and DTB.  The platform-specific H2/loadlinux bootloader
# and the combined, signed firmware image are outside Buildroot's scope.

set -eu

images_dir=$1
build_dir=$(dirname "$images_dir")/build
linux_dir=$(find "$build_dir" -maxdepth 1 -name 'linux-*' -type d \
	-exec test -f '{}/vmlinux' ';' -printf '%T@ %p\n' | sort -rn | head -n 1 | cut -d' ' -f2-)

if [ -z "$linux_dir" ]; then
	echo "qcs6490-cdsp: cannot locate the Linux build directory" >&2
	exit 1
fi

cp -f "$linux_dir/vmlinux" "$images_dir/vmlinux"
cp -f "$images_dir/rootfs.cpio.gz" "$images_dir/initrd"

if [ ! -f "$images_dir/qcs6490-cdsp.dtb" ]; then
	echo "qcs6490-cdsp: missing $images_dir/qcs6490-cdsp.dtb" >&2
	exit 1
fi
