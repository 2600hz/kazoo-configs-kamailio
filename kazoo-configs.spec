%define packagelayout   FH
%define SYSCONFDIR      %{_sysconfdir}
%define KAZOOCONFDIR    %{_sysconfdir}/kazoo

Name:           kazoo-configs
Summary:        Configuration for the Kazoo platform
License:        MPL1.1
Group:          Productivity/Telephony
Version:        v2.13
Release:        2600hz%{?dist}
URL:            http://www.2600hz.org/
Packager:       Karl Anderson
Vendor:         http://www.2600hz.org/

Source0:        Kazoo-Configs.tar

BuildRoot:    %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

%description
Configuration files for the various components that make up the Kazoo platform.

######################################################################################################################
# Prepare for the build
######################################################################################################################
%prep
%setup -b0 -q -n Kazoo-Configs

%{__mkdir} -p %{buildroot}%{KAZOOCONFDIR}
%{__mkdir} -p %{buildroot}%{SYSCONFDIR}/security/limits.d/

cp -r %{_builddir}/Kazoo-Configs/* %{buildroot}%{KAZOOCONFDIR}/
rm -rf %{buildroot}%{KAZOOCONFDIR}/system

cp %{_builddir}/Kazoo-Configs/system/*.limits.conf %{buildroot}%{SYSCONFDIR}/security/limits.d/

######################################################################################################################
# Bootstrap, Configure and Build the whole enchilada
######################################################################################################################
%build

######################################################################################################################
# Install it to the build root
######################################################################################################################
%install

######################################################################################################################
# Include a script to add a freeswitch user with group daemon when the core RPM is installed
######################################################################################################################
%pre

%post
find %{KAZOOCONFDIR} -type d -exec chmod 755 {} +

######################################################################################################################
# When the core RPM is uninstalled remove the freeswitch user
######################################################################################################################
%postun

######################################################################################################################
# List of files/directories to include in the core FreeSWITCH RPM
######################################################################################################################
%files                                                                                                                                                                                                                                                                                             
%defattr(0644,root,root)
#################################### Basic Directory Structure #######################################################
%dir %attr(0755, root, root) %{KAZOOCONFDIR}
%config(noreplace) %{KAZOOCONFDIR}/freeswitch/*
%config(noreplace) %{KAZOOCONFDIR}/haproxy/*
%config(noreplace) %{KAZOOCONFDIR}/kamailio/*
%config(noreplace) %{KAZOOCONFDIR}/rabbitmq/*
%config(noreplace) %{KAZOOCONFDIR}/bigcouch/*
%config(noreplace) %{KAZOOCONFDIR}/config.ini
%config(noreplace) %{SYSCONFDIR}/security/limits.d/*
