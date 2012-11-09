#!/bin/bash

# configure-stateful.sh
#   Script to set up basic stateful provisioning with Warewulf.
#   Adam DeConinck @ R Systems, 2011

NODE=$1
ROOTSIZE=$2
SWAPSIZE=$3

ROOTDEFAULT=20480
SWAPDEFAULT=4096

if [ -z "$NODE" ]; then
	echo
	echo "$0: Configure a node for stateful provisioning under Warewulf"
	echo "Usage: $0 nodename [ rootfs_in_mb swap_in_mb ]"
	echo "If omitted, rootfs = $ROOTDEFAULT and swap = $SWAPDEFAULT"
	echo "REMEMBER: If you're going to do this, make sure you have a "
	echo "kernel and grub installed in your VNFS!"
	echo
	exit 1
fi

if [ -z "$ROOTSIZE" ]; then
	ROOTSIZE=$ROOTDEFAULT;
fi
if [ -z "$SWAPSIZE" ]; then
	SWAPSIZE=$SWAPDEFAULT;
fi

wwsh << EOF
quiet
object modify $NODE -s filesystems="mountpoint=/:type=ext2:dev=sda1:size=$ROOTSIZE,dev=sda2:type=swap:size=$SWAPSIZE"
object modify $NODE -s diskformat=sda1,sda2
object modify $NODE -s diskpartition=sda
object modify $NODE -s bootloader=sda
EOF


echo
echo "REMEMBER: After you've provisioned the node, do:"
echo "	wwsh \"object $NODE -s bootlocal=1\""
echo "to make the node boot from local disk afterwards."
echo
