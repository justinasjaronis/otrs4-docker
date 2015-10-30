FROM centos:centos7
MAINTAINER Justinas Jaronis <justinas.jaronis@aksprendimai.lt>

RUN rpm -Uvh http://mirror.duomenucentras.lt/epel/7/x86_64/e/epel-release-7-5.noarch.rpm

RUN yum update -y
RUN yum -y install wget apache httpd-devel perl-core "perl(DBD::Pg)" "perl(Crypt::SSLeay)" "perl(Net::LDAP)" "perl(URI)" mod_perl httpd procmail "perl(Date::Format)" "perl(LWP::UserAgent)" "perl(Net::DNS)" "perl(IO::Socket::SSL)" "perl(XML::Parser)" "perl(Apache2::Reload)" "perl(Crypt::Eksblowfish::Bcrypt)" "perl(Encode::HanExtra)" "perl(GD)" "perl(GD::Text)" "perl(GD::Graph)" "perl(JSON::XS)" "perl(Mail::IMAPClient)" "perl(PDF::API2)" "perl(Text::CSV_XS)" "perl(YAML::XS)" curl

#OTRS
RUN wget http://ftp.otrs.org/pub/otrs/RPMS/rhel/7/otrs-5.0.1-03.noarch.rpm
RUN yum -y install otrs-5.0.1-03.noarch.rpm --skip-broken 

#OTRS COPY Configs
ADD Config.pm /opt/otrs/Kernel/Config.pm
RUN sed -i -e"s/mod_perl.c/mod_perl.so/" /etc/httpd/conf.d/zzz_otrs.conf

#reconfigure httpd
RUN sed -i "s/error\/noindex.html/otrs\/index.pl/" /etc/httpd/conf.d/welcome.conf

#set up sshd
#RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config
#RUN echo "root:root" | chpasswd

#enable crons
WORKDIR /opt/otrs/var/cron/
USER otrs
CMD ["/bin/bash -c 'for foo in *.dist; do cp $foo `basename $foo .dist`; done'"]

USER root
EXPOSE 80
VOLUME ["/sys/fs/cgroup" ]
CMD ["/bin/bash", "-c", "/bin/bash -c "source /etc/sysconfig/httpd && exec /usr/sbin/httpd -DFOREGROUND"]
