# Dockerfile
FROM centos:7.9.2009

# Update
RUN yum update -y

# Install prerequisites
RUN yum install -y epel-release gcc glibc glibc-common wget unzip httpd php gd gd-devel perl postfix make net-snmp

# Set the working directory
WORKDIR /nagios_home/

# Copy into /nagios
COPY . /nagios_home/

# Download source
RUN wget -O nagios-4.4.6.tar.gz  https://sourceforge.net/projects/nagios/files/nagios-4.x/nagios-4.4.6/nagios-4.4.6.tar.gz
RUN tar xzf nagios-4.4.6.tar.gz 

# Set the working directory
WORKDIR /nagios_home/nagios-4.4.6/

# Create Nagios User 
RUN useradd -m nagios
#
# Compile
RUN ./configure --with-command-group=nagios
RUN make all

# Install Binaries
RUN make install
RUN make install-init
RUN make install-exfoliation

# Create User and Group
RUN make install-groups-users
RUN usermod -a -G nagios apache


# Install Service-Daemon
RUN make install-daemoninit
RUN systemctl enable httpd.service

# Install Command Mode
RUN make install-commandmode

# Install Configuration Files
RUN make install-config

# Install Apache Config Files
RUN make install-webconf

# Create nagiosadmin User Account
#RUN htpasswd -c /nagios_home/nagios/etc/htpasswd.users nagiosadmin
RUN htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin
# populate libexec
#RUN cp -R /usr/local/nagios-4.4.6/contrib/eventhandlers/ /usr/local/nagios/libexec/
RUN cp -R /nagios_home/nagios-4.4.6/contrib/eventhandlers/ /usr/local/nagios/libexec/ 

#Enable Nagios 
RUN systemctl enable nagios.service

# Install Nagios plugins dependencies
RUN yum install -y which gettext automake autoconf openssl-devel net-snmp net-snmp-utils
RUN yum install -y perl-Net-SNMP

# Set working directory
WORKDIR /nagios_home/

# Downlaod Nagios Plugins
RUN wget -O /nagios_home/nagios-plugins-2.3.3.tar.gz  https://nagios-plugins.org/download/nagios-plugins-2.3.3.tar.gz
RUN tar zxf nagios-plugins-2.3.3.tar.gz  

# Set working directory
WORKDIR /nagios_home/nagios-plugins-2.3.3/

# Install Nagios plugins
RUN ./configure --with-nagios-user=nagios --with-nagios-group=nagios
RUN make
RUN make install
EXPOSE 8080
# Start Apache and Nagios
CMD ["/bin/bash", "/nagios_home/start.sh"]
