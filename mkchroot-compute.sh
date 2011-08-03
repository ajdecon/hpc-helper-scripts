#!/bin/sh
#
# mkchroot-compute.sh:
# 	Build base chroot for compute-node image.
#
# Based on Original mkchroot-rh.sh from Warewulf 3.0.
# Modifications Copyright (c) 2011 R Systems NA, Inc.
#
# Warewulf:
# Copyright (c) 2001-2003 Gregory M. Kurtzer
# Copyright (c) 2003-2011, The Regents of the University of California,
# through Lawrence Berkeley National Laboratory (subject to receipt of any
# required approvals from the U.S. Dept. of Energy).  All rights reserved.
#



VNFSDIR=$1
YUMDIR=$2
VERSION=$3

if [ -z "$VNFSDIR" ]; then
    echo "$0: Build base chroot for compute-node image."
    echo "USAGE: $0 /path/to/chroot [/path/to/yum-dir version]"
    echo "Where <yum-dir> contains the yum.conf and .repo files to be used for the install, "
    echo "and <version> is the release version to use."
    echo "Uses the host system's yum configuration and redhat-release version by default."
    echo
    exit 1
fi

if [ -z "$VERSION" ]; then
	VERSION=`rpm -qf /etc/redhat-release  --qf '%{VERSION}\n'`
fi

mkdir -p $VNFSDIR
mkdir -p $VNFSDIR/etc

#Set up the yum configuration
if [ -z "$YUMDIR" ]; then
	echo "Creating yum configuration based on master"
	cp -rap /etc/yum.conf /etc/yum.repos.d $VNFSDIR/etc
	sed -i -e "s/\$releasever/$VERSION/g" `find $VNFSDIR/etc/yum* -type f`
else
	echo "Copying yum configuration from $YUMDIR"
	if [ -f $YUMDIR/yum.conf ]; then
		cp -rap $YUMDIR/yum.conf $VNFSDIR/etc
	else
		echo "No yum.conf found in $YUMDIR, using master yum.conf"
		cp -rap /etc/yum.conf $VNFSDIR/etc
	fi
	sed -i -e "s/\$releasever/$VERSION/g" `find $VNFSDIR/etc/yum* -type f`
	echo "Copying .repo files from $YUMDIR"
	mkdir -p $VNFSDIR/etc/yum.repos.d
	cp -rap $YUMDIR/*.repo $VNFSDIR/etc/yum.repos.d
fi

echo "Installing minimal system"
yum --installroot $VNFSDIR -y install \
    SysVinit basesystem bash redhat-release chkconfig coreutils e2fsprogs \
    ethtool filesystem findutils gawk grep initscripts iproute iputils \
    mingetty mktemp net-tools nfs-utils pam portmap procps psmisc rdate \
    sed setup shadow-utils sysklogd tcp_wrappers termcap tzdata util-linux \
    words zlib tar less gzip which util-linux module-init-tools udev \
    openssh-clients openssh-server passwd dhclient pciutils vim-minimal \
    shadow-utils strace

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create chroot"
fi

echo "Installing additional packages"
yum --installroot $VNFSDIR -y install \
    OpenIPMI ipmitool mdadm perl python cronie crontabs readline iptables man sysstat tcpdump \
    man


echo
echo "Creating default fstab"
echo "#GENERATED_ENTRIES#" > $VNFSDIR/etc/fstab
echo "tmpfs /dev/shm tmpfs defaults 0 0" >> $VNFSDIR/etc/fstab
echo "devpts /dev/pts devpts gid=5,mode=620 0 0" >> $VNFSDIR/etc/fstab
echo "sysfs /sys sysfs defaults 0 0" >> $VNFSDIR/etc/fstab
echo "proc /proc proc defaults 0 0" >> $VNFSDIR/etc/fstab

echo "Creating SSH host keys"
/usr/bin/ssh-keygen -q -t rsa1 -f $VNFSDIR/etc/ssh/ssh_host_key -C '' -N ''
/usr/bin/ssh-keygen -q -t rsa -f $VNFSDIR/etc/ssh/ssh_host_rsa_key -C '' -N ''
/usr/bin/ssh-keygen -q -t dsa -f $VNFSDIR/etc/ssh/ssh_host_dsa_key -C '' -N ''

if [ ! -f "$VNFSDIR/etc/shadow" ]; then
    echo "Creating shadow file"
    /usr/sbin/chroot $VNFSDIR /usr/sbin/pwconv
fi

if [ -x "$VNFSDIR/usr/bin/passwd" ]; then
    echo "Setting root password..."
    /usr/sbin/chroot $VNFSDIR /usr/bin/passwd root
else
    echo "Setting root password to NULL (be sure to fix this yourself)"
    sed -i -e 's/^root:\*:/root::/' $VNFSDIR/etc/shadow
fi

echo "Done."
