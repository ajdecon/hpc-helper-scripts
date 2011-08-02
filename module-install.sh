#!/bin/bash
#
# Install a module into a chroot

CHROOT=$1
MODULE=$2
MODULEDIR=$3

if [ -z $CHROOT ]; then
	echo "USAGE: $0 /path/to/chroot module [moduledir]"
	echo "  - moduledir: defaults to /etc/mkchroot/modules"
	exit 1
fi

# Find MODULEDIR
if [ -z "$MODULEDIR" ]; then
	MODULEDIR=/etc/mkchroot/modules
fi

# See if MODULE exists
if [ ! -d $MODULEDIR/$MODULE ]; then
	echo "$MODULE does not exist in $MODULEDIR, exiting"
	exit 2
fi

# Copy repos from module to chroot
if [ -d $MODULEDIR/$MODULE/yum.repos.d ]; then
	cp -rap $MODULEDIR/$MODULE/yum.repos.d $CHROOT/etc/
	echo "Copied yum.repos.d from $MODULE"
fi

# Copy file tree from module to chroot
if [ -d $MODULEDIR/$MODULE/files ]; then
	cp -rap $MODULEDIR/$MODULE/files/* $CHROOT/
	echo "Copied file tree from $MODULE"
fi

# Install packages from yum list
if [ -f $MODULEDIR/$MODULE/yum.list ]; then
	echo "Installing packages in yum.list"
	yum --installroot $CHROOT -y install `cat $MODULEDIR/$MODULE/yum.list`	
	
fi

# If any packages are present in an rpms directory, install those
if [ -d $MODULEDIR/$MODULE/rpms ]; then
	echo "Installing packages from $MODULE/rpms"
	yum --installroot $CHROOT --nogpgcheck -y install $MODULEDIR/$MODULE/rpms/*.rpm
fi

# If there is a $MODULE/install script, run it
if [ -x $MODULEDIR/$MODULE/install ]; then
	echo "Executing $MODULE/install..."
	mkdir -p $CHROOT/tmp
	cp $MODULEDIR/$MODULE/install $CHROOT/tmp/install
	/usr/sbin/chroot $CHROOT /tmp/install
	echo "Done."
fi

echo "Module $MODULE has been installed to $CHROOT"
