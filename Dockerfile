FROM centos:centos7
MAINTAINER Justinas Jaronis <justinas.jaronis@aksprendimai.lt>

RUN rpm -Uvh http://mirror.duomenucentras.lt/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
RUN yum update -y
RUN yum -y install openssh-server wget postgresql mysql-server mysql apache httpd-devel perl-core "perl(DBD::Pg)" "perl(Crypt::SSLeay)" "perl(Net::LDAP)" "perl(URI)" mod_perl httpd procmail "perl(Date::Format)" "perl(LWP::UserAgent)" "perl(Net::DNS)" "perl(IO::Socket::SSL)" "perl(XML::Parser)" "perl(Apache2::Reload)" "perl(Crypt::Eksblowfish::Bcrypt)" "perl(Encode::HanExtra)" "perl(GD)" "perl(GD::Text)" "perl(GD::Graph)" "perl(JSON::XS)" "perl(Mail::IMAPClient)" "perl(PDF::API2)" "perl(Text::CSV_XS)" "perl(YAML::XS)" curl

#MYSQL
RUN sed -i '/user=mysql/akey_buffer_size=32M' /etc/my.cnf 
RUN sed -i '/user=mysql/amax_allowed_packet=32M' /etc/my.cnf 

#OTRS
RUN wget http://ftp.otrs.org/pub/otrs/RPMS/rhel/6/otrs-4.0.8-02.noarch.rpm
RUN yum -y install otrs-4.0.8-02.noarch.rpm --skip-broken 

#OTRS COPY Configs
ADD Config.pm /opt/otrs/Kernel/Config.pm
RUN sed -i -e"s/mod_perl.c/mod_perl.so/" /etc/httpd/conf.d/zzz_otrs.conf

#reconfigure httpd
RUN sed -i "s/error\/noindex.html/otrs\/index.pl/" /etc/httpd/conf.d/welcome.conf

#Start web and otrs and configure mysql
ADD run.sh /run.sh
RUN chmod +x /*.sh

#set up sshd
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config
RUN echo "root:root" | chpasswd

RUN yum -y install git subversion mc tmux vim

#enable crons
WORKDIR /opt/otrs/var/cron/
USER otrs
CMD ["/bin/bash -c 'for foo in *.dist; do cp $foo `basename $foo .dist`; done'"]

USER root
EXPOSE 22 80
RUN yum -y update; yum clean all
RUN yum -y swap -- remove systemd-container systemd-container-libs -- install systemd systemd-libs 
RUN yum -y clean all; \
(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*

RUN ln -s '/usr/lib/systemd/system/httpd.service' '/etc/systemd/system/multi-user.target.wants/httpd.service';\
ln -s '/usr/lib/systemd/system/sshd.service' '/etc/systemd/system/multi-user.target.wants/sshd.service'

VOLUME ["/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]


