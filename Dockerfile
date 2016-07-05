# VERSION 1
# Author: jingchao.song

# Base images
FROM 10.10.36.213/library/jdk7:7u80

# Maintainer
MAINTAINER jingchaosong jingchao.song@tendcloud.com

ADD ./hadoop-2.6.0-cdh5.5.2 /usr/local/hadoop/
ADD ./hadoop-conf/ /usr/local/hadoop/etc/hadoop/

ENV JAVA_HOME /usr/local/java
ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH "/usr/local/hadoop/bin:/usr/local/hadoop/sbin:$PATH"
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_HOME/etc/hadoop

# passwordless ssh
RUN rm -f /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa
RUN cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

ADD ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN chown root:root /root/.ssh/config

# fix the 254 error code
RUN sed  -i "/^[^#]*UsePAM/ s/.*/#&/"  /etc/ssh/sshd_config
RUN echo "UsePAM no" >> /etc/ssh/sshd_config
RUN echo "Port 2122" >> /etc/ssh/sshd_config

RUN echo "export HADOOP_HOME=/usr/local/hadoop">>/etc/profile && \
echo "export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop">>/etc/profile && \
echo "export YARN_CONF_DIR=/usr/local/hadoop/etc/hadoop">>/etc/profile && \
echo 'export PATH=/usr/local/hadoop/bin:/usr/local/hadoop/sbin:$PATH'>>/etc/profile && \
echo "CLASSPATH=.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar">>/etc/profile
RUN $HADOOP_PREFIX/bin/hdfs namenode -format

#DataNode Protocol/Transceiver/HTTP Web UI/Secure DataNode Web UI Port and YARN spark job server ports
EXPOSE 50020 50090 50070 50010 50075 8030 8031 8032 8033 8040 8041 8042 8044 8090 49707 8088 10020 19888 19890 1003 18088 9090 8092 22

ADD scripts/startup.sh /usr/bin/
ADD ./lib/* /usr/local/hadoop/lib/native/

CMD ["startup.sh"]
