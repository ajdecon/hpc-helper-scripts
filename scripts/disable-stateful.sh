#!/bin/bash

# disable-stateful.sh
#   Script to set up basic stateful provisioning with Warewulf.
#   Adam DeConinck @ R Systems, 2011

NODE=$1

if [ -z "$NODE" ]; then
	echo
	echo "$0: Unset variables for stateful provisioning"
	echo "Usage: $0 nodename"
	echo "Unsets filesystems,diskformat,diskpartition,bootlocal and bootloader."
	echo
	exit 1
fi

wwsh << EOF
quiet
object modify $NODE -d filesystems
object modify $NODE -d diskformat
object modify $NODE -d diskparition
object modify $NODE -d bootloader
object modify $NODE -d bootlocal
EOF


