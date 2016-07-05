#Hadoop all-in-one docker image

Build a hadoop all-in-one docker image for hadoop2.6.0-cdh5.5.2.

##Build

```
./build.sh
docker -H :2375 build -t hadoop-all-in-one:cdh5.5.2
```

##Run

```
docker -H :2375 run -d -p 50070:50070 -p 8088:8088 hadoop-all-in-one:cdh5.5.2
```

##Check

Visit http://your_ip:50070 and http://your_ip:8088

