# DESCRIPTION:    hadoop-all-in-one
FROM centos:centos7.2.1511

MAINTAINER Jimmy Song<rootsongjc@gmail.com>

# -----------------------------------------------------------------------------
# Import the RPM GPG keys for Repositories
# -----------------------------------------------------------------------------
RUN rm -f /etc/yum.repos.d/*
ADD etc/yum.repos.d/td-idc-yz.repo /etc/yum.repos.d/

# -----------------------------------------------------------------------------
# Base Install
# -----------------------------------------------------------------------------
RUN rpm --rebuilddb \
	&& yum -y install \
		vim \
        net-tools \
		xz-5.1.2-12alpha.el7.x86_64 \
		sudo-1.8.6p7-17.el7_2 \
		openssh-6.6.1p1-25.el7_2 \
		openssh-server-6.6.1p1-25.el7_2 \
		openssh-clients-6.6.1p1-25.el7_2 \
		python-setuptools-0.9.8-4.el7 \
		yum-plugin-versionlock-1.1.31-34.el7 \
	&& yum versionlock add \
		vim \
		xz \
		sudo \
		openssh \
		openssh-server \
		openssh-clients \
		python-setuptools \
		yum-plugin-versionlock \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all

# -----------------------------------------------------------------------------
# Install supervisord (required to run more than a single process in a container)
# Note: EPEL package lacks /usr/bin/pidproxy
# We require supervisor-stdout to allow output of services started by 
# supervisord to be easily inspected with "docker logs".
# -----------------------------------------------------------------------------
RUN easy_install \
		'supervisor == 3.3.1' \
		'supervisor-stdout == 0.1.1' \
	&& mkdir -p \
		/var/log/supervisor/

# -----------------------------------------------------------------------------
# CTC Timezone & Networking
# -----------------------------------------------------------------------------
RUN ln -sf \
		/usr/share/zoneinfo/Asia/Shanghai \
		/etc/localtime \
	&& echo "NETWORKING=yes" > /etc/sysconfig/network

# -----------------------------------------------------------------------------
# Configure SSH for non-root public key authentication
# -----------------------------------------------------------------------------
RUN sed -i \
	-e 's~^PasswordAuthentication yes~PasswordAuthentication no~g' \
	-e 's~^#PermitRootLogin yes~PermitRootLogin no~g' \
	-e 's~^#UseDNS yes~UseDNS no~g' \
	-e 's~^\(.*\)/usr/libexec/openssh/sftp-server$~\1internal-sftp~g' \
	/etc/ssh/sshd_config

# -----------------------------------------------------------------------------
# Enable the wheel sudoers group
# -----------------------------------------------------------------------------
RUN sed -i \
	-e 's~^# %wheel\tALL=(ALL)\tALL~%wheel\tALL=(ALL) ALL~g' \
	-e 's~\(.*\) requiretty$~#\1requiretty~' \
	/etc/sudoers

# -----------------------------------------------------------------------------
# Copy files into place
# -----------------------------------------------------------------------------
ADD usr/sbin \
	/usr/sbin/
ADD opt/scmi \
	/opt/scmi/
ADD etc/systemd/system \
	/etc/systemd/system/
ADD etc/services-config/ssh/authorized_keys \
	etc/services-config/ssh/sshd-bootstrap.conf \
	etc/services-config/ssh/sshd-bootstrap.env \
	/etc/services-config/ssh/
ADD etc/services-config/supervisor/supervisord.conf \
	/etc/services-config/supervisor/
ADD etc/services-config/supervisor/supervisord.d \
	/etc/services-config/supervisor/supervisord.d/

RUN mkdir -p \
		/etc/supervisord.d/ \
	&& cp -pf \
		/etc/ssh/sshd_config \
		/etc/services-config/ssh/ \
	&& ln -sf \
		/etc/services-config/ssh/sshd_config \
		/etc/ssh/sshd_config \
	&& ln -sf \
		/etc/services-config/ssh/sshd-bootstrap.conf \
		/etc/sshd-bootstrap.conf \
	&& ln -sf \
		/etc/services-config/ssh/sshd-bootstrap.env \
		/etc/sshd-bootstrap.env \
	&& ln -sf \
		/etc/services-config/supervisor/supervisord.conf \
		/etc/supervisord.conf \
	&& ln -sf \
		/etc/services-config/supervisor/supervisord.d/sshd-wrapper.conf \
		/etc/supervisord.d/sshd-wrapper.conf \
	&& ln -sf \
		/etc/services-config/supervisor/supervisord.d/sshd-bootstrap.conf \
		/etc/supervisord.d/sshd-bootstrap.conf \
	&& chmod 700 \
		/usr/sbin/{scmi,sshd-{bootstrap,wrapper}}

# -----------------------------------------------------------------------------
# Purge
# -----------------------------------------------------------------------------
RUN rm -rf /etc/ld.so.cache \
	; rm -rf /sbin/sln \
	; rm -rf /usr/{{lib,share}/locale,share/{man,doc,info,cracklib,i18n},{lib,lib64}/gconv,bin/localedef,sbin/build-locale-archive} \
	; rm -rf /{root,tmp,var/cache/{ldconfig,yum}}/* \
	; > /etc/sysconfig/i18n

EXPOSE 22

# -----------------------------------------------------------------------------
# Ulimit
RUN echo "* soft nofile 655350" >> /etc/security/limits.conf & \
echo "* hard nofile 655350" >> /etc/security/limits.conf & \
echo "@hadoop        hard    nproc           655350" >> /etc/security/limits.conf & \
echo "@hadoop        soft    nproc           655350" >> /etc/security/limits.conf & \
echo "@root        soft    nproc           655350" >> /etc/security/limits.conf & \
echo "@root        hard    nproc           655350" >> /etc/security/limits.conf & \
echo "ulimit -SH 655350" >> /etc/rc.local
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Set default environment variables
# -----------------------------------------------------------------------------
ENV SSH_AUTHORIZED_KEYS="" \
	SSH_AUTOSTART_SSHD=true \
	SSH_AUTOSTART_SSHD_BOOTSTRAP=true \
	SSH_CHROOT_DIRECTORY="%h" \
	SSH_INHERIT_ENVIRONMENT=false \
	SSH_SUDO="ALL=(ALL) ALL" \
	SSH_USER="hadoop" \
	SSH_USER_FORCE_SFTP=false \
	SSH_USER_HOME="/home/%u" \
	SSH_USER_ID="500:500" \
	SSH_USER_PASSWORD="" \
	SSH_USER_PASSWORD_HASHED=false \
	SSH_USER_SHELL="/bin/bash"
# Install Oracle JDK 7u80
RUN cd /tmp && \
    curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k "http://download.oracle.com/o    tn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz" && \
    tar xf jdk-7u80-linux-x64.tar.gz -C /usr/local/ && \
    ln -s /usr/local/jdk1.7.0_80 /usr/local/java && \
    rm -f /tmp/jdk-7u80-linux-x64.tar.gz && \
    echo "export JAVA_HOME=/usr/local/java" >>/etc/profile && \
    echo "export PATH=/usr/local/java/bin:/usr/local/java/jre/bin:$PATH" >> /etc/profile 

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/local/java

# Add /srv/java and jdk on PATH variable
ENV PATH ${PATH}:${JAVA_HOME}/bin

# Install hadoop
RUN cd /tmp && \
    curl -L -O -k "http://archive.cloudera.com/cdh5/cdh/5/hadoop-2.6.0-cdh5.5.2.tar.gz" && \
    tar xf hadoop-2.6.0-cdh5.5.2.tar.gz -C /usr/local/ && \
    ln -s /usr/local/hadoop-2.6.0-cdh5.5.2 /usr/local/hadoop && \
    rm -f /tmp/hadoop-2.6.0-cdh5.5.2.tar.gz && \
    adduser hadoop && \
    chown -R hadoop:hadoop /usr/local/hadoop*
#Add lib
ADD ./lib/* /usr/local/hadoop/lib/native/

#DataNode Protocol/Transceiver/HTTP Web UI/Secure DataNode Web UI Port and YARN spark job server ports
EXPOSE 50020 50090 50070 50010 50075 8030 8031 8032 8033 8040 8041 8042 8044 8090 49707 8088 10020 19888 19890 1003 18088 9090 8092 9000 8080

ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH "/usr/local/hadoop/bin:/usr/local/hadoop/sbin:$PATH"
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV FS_DEFAULTFS_PORT 9000

RUN echo "export HADOOP_HOME=/usr/local/hadoop">>/etc/profile && \
echo "export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop">>/etc/profile && \
echo "export YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop">>/etc/profile && \
echo "export PATH=/usr/local/hadoop/bin:/usr/local/hadoop/sbin:$PATH">>/etc/profile && \
echo "CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar">>/etc/profile

RUN su - hadoop -c "$HADOOP_PREFIX/bin/hdfs namenode -format"

VOLUME /tmp

#Install spark
#RUN cd /tmp && \
#    curl -L -O -k "http://d3kbcqa49mib13.cloudfront.net/spark-1.6.1-bin-hadoop2.6.tgz" && \
#    tar xf spark-1.6.1-bin-hadoop2.6.tgz -C /usr/local/ && \
#    ln -s /usr/local/spark-1.6.1-bin-hadoop2.6 /usr/local/spark && \
#    rm -f /tmp/spark-1.6.1-bin-hadoop2.6.tgz && \
#    chown -R hadoop:hadoop /usr/local/spark*
#
#CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]
