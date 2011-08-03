Name:	ofed-hpc	
Version: 1.5.3.1	
Release:	1%{?dist}
Summary: Dummy package for the OFED HPC distribution.
Group:	System Environment/Libraries	
License:	BSD
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

Requires:  dapl dapl-debuginfo dapl-devel dapl-devel-static dapl-utils ibutils ibutils-debuginfo infiniband-diags infiniband-diags-debuginfo kernel-ib kernel-ib-devel libcxgb3 libcxgb3-debuginfo libibmad libibmad-debuginfo libibmad-devel libibmad-static libibumad libibumad-debuginfo libibumad-devel libibumad-static    libibverbs libibverbs-debuginfo libibverbs-devel    libibverbs-devel-static libibverbs-utils    libipathverbs libipathverbs-debuginfo libmlx4 libmlx4-debuginfo   libmthca libmthca-debuginfo  libnes libnes-debuginfo    librdmacm librdmacm-debuginfo librdmacm-devel librdmacm-utils mpi-selector mpitests_mvapich2_gcc mpitests_mvapich_gcc mpitests_openmpi_gcc mstflint mstflint-debuginfo  mvapich2_gcc mvapich_gcc ofed-docs ofed-scripts openmpi_gcc opensm opensm-debuginfo    opensm-devel opensm-libs opensm-static perftest perftest-debuginfo  qperf qperf-debuginfo 	

%description


%prep


%build


%install


%clean


%files



%changelog

