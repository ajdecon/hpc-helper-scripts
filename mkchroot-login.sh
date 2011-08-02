#!/bin/sh
#
# mkchroot-login.sh:
#	Build base chroot for login-node imae.
#
# Based on Original mkchroot-rh.sh from Warewulf 3.0.
# Modifications Copyright (c) 2011 R Systems NA, Inc.
#
# Warewulf:
# Copyright (c) 2001-2003 Gregory M. Kurtzer
#
# Copyright (c) 2003-2011, The Regents of the University of California,
# through Lawrence Berkeley National Laboratory (subject to receipt of any
# required approvals from the U.S. Dept. of Energy).  All rights reserved.
#



VNFSDIR=$1
YUMDIR=$2
VERSION=$3

if [ -z "$VNFSDIR" ]; then
    echo "$0: Build base chroot for login-node image."
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
yum --installroot $VNFSDIR --nogpgcheck -y install \
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
    OpenIPMI ipmitool mdadm perl python cronie readline iptables \
    tcsh zsh xorg-x11-server-Xorg xorg-x11-auth vim-enhanced nano emacs

echo "Installing development tools"
yum --installroot $VNFSDIR -y groupinstall "Development tools"

echo "Installing plotting tools"
yum --installroot $VNFSDIR -y groupinstall "Scientific support"


#echo "Installing Torque from $PACKAGEDIR/torque"
#yum --installroot $VNFSDIR --nogpgcheck -y install \
#	$PACKAGEDIR/torque/torque-*rpm

# Install Torque: assumes you've set up a local repo with the RPMS.
echo "Installing Torque from local repository"
yum --installroot $VNFSDIR --nogpgcheck -y install \
	torque torque-client torque-server torque-scheduler torque-debuginfo

/usr/sbin/chroot $VNFSDIR chkconfig pbs_server on
/usr/sbin/chroot $VNFSDIR chkconfig pbs_sched on
/usr/sbin/chroot $VNFSDIR chkconfig pbs_mom off


#echo "Installing OFED from $PACKAGEDIR/OFED"
#yum --installroot $VNFSDIR --nogpgcheck -y install $PACKAGEDIR/OFED/*rpm

# Install OFED packages: assumes you've set up a local repo.
echo "Installing OFED from local repository"
yum --installroot $VNFSDIR --nogpgcheck -y install dapl dapl-debuginfo \
	dapl-devel dapl-devel-static dapl-utils ibutils ibutils-debuginfo \
	infiniband-diags infiniband-diags-debuginfo kernel-ib \
	kernel-ib-devel libcxgb3 libcxgb3-debuginfo libcxgb3-devel \
	libibmad libibmad-debuginfo libibmad-devel libibmad-static \
	libibumad libibumad-debuginfo libibumad-devel libibumad-static \
	libibverbs libibverbs-debuginfo libibverbs-devel \
	libibverbs-devel-static libibverbs-utils libipathverbs \
	libipathverbs-debuginfo libipathverbs-devel libmlx4 \
	libmlx4-debuginfo libmthca libmthca-debuginfo \
	libnes libnes-debuginfo \
	librdmacm librdmacm-debuginfo librdmacm-devel librdmacm-utils \
	mpi-selector mpitests_mvapich2_gcc mpitests_mvapich_gcc \
	mpitests_openmpi_gcc mstflint mstflint-debuginfo mvapich2_gcc \
	mvapich_gcc ofed-docs ofed-scripts openmpi_gcc opensm \
	opensm-debuginfo opensm-devel opensm-libs opensm-static perftest \
	perftest-debuginfo qperf qperf-debuginfo 

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
