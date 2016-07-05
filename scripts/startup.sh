#!/bin/bash
#Init the hadoop configuration
#Author:jingchao.song@tendcloud.com
#Date:2016-06-07
HADOOP_PREFIX=/usr/local/hadoop
#Edit hadoop configuration
sed -i -E "s/HOSTNAME/$HOSTNAME/" /usr/local/hadoop/etc/hadoop/core-site.xml

#Start service
/usr/sbin/sshd 
/usr/local/hadoop/sbin/start-yarn.sh
$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh 
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/root
$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh 
$HADOOP_PREFIX/sbin/start-yarn.sh
#Foreground
echo "Press Ctrl+P and Ctrl+Q to background this process."
echo 'Use exec command to open a new bash instance for this instance (Eg. "docker exec -i -t CONTAINER_ID bash"). Container ID can be obtained using "docker ps" command.'
echo "Start Terminal"
bash
echo "Press Ctrl+C to stop instance."
sleep infinity
