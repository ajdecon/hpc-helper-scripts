HPC Helper Scripts
==================

This is just an assortment of scripts, notes, and miscellaneous tools I've
put together for helping with managing HPC clusters. Some of these are trivial,
others are decent tools in their own right; the latter are often included here as 
submodules rather than tracked as a massive repo.

A few worth noting include:

* __mkchroot__: A version of Warewulf's mkchroot-rh.sh which can take a yum 
configuration as one argument, so that you can (for example) build a Scientific
Linux chroot on a Red Hat system. This is important mostly if you want to
have a system that independently updates itself from other repos. Warewulf's new 
wwmkchroot is probably more useful in general, but still doesn't let you 
specify arbitary yum configs.

* **torque_qhistory**: A tool for viewing and doing simple queries on PBS/Torque 
accounting files.

* **modules_logger**: A system for logging the usage of environment-modules to 
help system administrators better manage cluster software. Uses MongoDB as the persistence layer.
