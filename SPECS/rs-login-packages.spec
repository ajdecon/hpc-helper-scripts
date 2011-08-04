Name:		rs-login-packages	
Version:	20110804-1
Release:	1%{?dist}
Summary:	Dummy package to install packages for HPC login nodes.

Group:		Applications/System
License:	MIT
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

Requires: tcsh zsh vim-enhanced nano emacs autoconf automake automake14 automake15 automake16 automake17 bison byacc cscope ctags cvs dev86 diffstat dogtail doxygen elfutils flex gcc gcc-c++ gcc-gfortran gdb gettext indent libtool ltrace make oprofile patchutils pkgconfig pstack python-ldap rcs redhat-rpm-config rpm-build splint subversion swig systemtap texinfo valgrind kernel gnuplot units curl curl-devel sqlite sqlite-devel gamin kernel-headers usermode bc ruby

%description


%prep


%build


%install


%clean


%files



%changelog

