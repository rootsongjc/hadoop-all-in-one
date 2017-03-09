# Hadoop all-in-one


Docker Image for hadoop-all-in-one with spark inside.

This repository contains **Dockerfile** for [Docker](https://www.docker.com/)'s [automated build](https://registry.hub.docker.com/u/airdock/) published to the public [Docker Hub Registry](https://registry.hub.docker.com/).

## Usage

You should have already install [Docker](https://www.docker.com/).

Execute:

	'docker run -d --name hadoop hadoop:all-in-one '

### SSH Alternatives

SSH is not required in order to access a terminal for the running container. The simplest method is to use the docker exec command to run bash (or sh) as follows:

$ docker exec -it {container-name-or-id} bash

### Login the container with SSH

    'ssh -i id_rsa_insecure hadoop@$container_ip'

Execute:
    'docker inspect crane_crane_db_1|grep "IPAddress"'
You will see a IP address which is the contaienr_ip.

## Change Log

### 1.0
- volume tmp 
- spark-1.6.1
- jdk1.6.0-7u80
- add hadoop-cdh5.5.2.tar.gz
- namenode port default 9000, you can specify with ENV
- use MIT license


## Build

You should install "make" utility.

Under each project, you could retrieve a Makefile with a set of *tasks*:

- **all**: alias to 'build'
- **clean**: remove all container which depends on this image, and remove image previously builded
- **build**: clean and build the current version
- **tag_latest**: tag current version with ":latest"
- **release**: build and execute tag_latest, push image onto registry, and tag git repository
- **debug**: launch an interactive shell using this image
- **run**: run image as daemon and print IP address.
- **save**: export docker image as a tar.gz file


## MIT License

```
The MIT License (MIT)

Copyright (c) 2015 TalkingData

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 ```
