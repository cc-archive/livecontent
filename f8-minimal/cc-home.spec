Summary: All user data for user cc.
Name: cc-home
Version: 0.1
Release: 1
Source: file:///cc-home.tar.gz
Group: bleh
License: GPL
BuildRoot: /var/tmp/%{name}-buildroot
%description
Creates a user and fills the home with files in the source.

%prep
%setup -c -q
%install
cp -a ./ $RPM_BUILD_ROOT/
%clean
rm -rf $RPM_BUILD_ROOT
%files
%defattr(-,root,root)
