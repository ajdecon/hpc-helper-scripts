Name:		rs-login-packages	
Version:	2011080401
Release:	1%{?dist}
Summary:	Dummy package to install packages for HPC login nodes.

Group:		Applications/System
License:	MIT
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

Requires: yum tcsh zsh vim-enhanced nano emacs autoconf automake bison byacc cscope ctags cvs dev86 diffstat doxygen elfutils flex gcc gcc-c++ gcc-gfortran gdb gettext indent libtool ltrace make oprofile patchutils pkgconfig pstack python-ldap rcs redhat-rpm-config rpm-build subversion swig systemtap texinfo valgrind kernel gnuplot units curl curl-devel sqlite sqlite-devel gamin kernel-headers usermode bc ruby tcl tcl-devel tk

%description


%prep


%build


%install


%clean


%files



%changelog

