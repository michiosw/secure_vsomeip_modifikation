# secure_vsomeip_modifikation
Secure_vsomeip_modifikation is a state of the art reporduction of the github repository [secure-vsomeip](https://github.com/netgroup-polito/secure-vsomeip).
Certain parameters and configurations are modified. Each step necessary to execute the repository benchmark is mentioned.

## Prerequisites

Use [Docker](https://www.docker.com/products/docker-desktop) to create the Docker Image. <br/>
After the successful installation of Docker, move to the folder your Dockerfile (which can be found in this repository) is located in.<br/>

1. Build the Docker Image:

```bash
docker build -t img-secure-vsomeip .
```

2. The created Docker Image named "img-secure-vsomeip" is now ready to be started in a container named "secure-vsomeip".

```bash
docker run --publish-all=true -it --name secure-vsomeip img-secure-vsomeip bash
```
3. To connect into the docker container, use:

```bash
docker exec -it container_name bash
```
4. You should find yourself in the root folder of the container. To copy the repository into the container use:

```bash
git clone https://github.com/netgroup-polito/secure-vsomeip.git
```

## Installation and execution for remote client containers

In order to use the remote connection, you have to redo step 2, 3 and change the name of the container. Now two containers are existing. A MASTER and a WORKER (SLAVE) container. Now a Docker network needs to be created. In order to prevent an upcoming ssh password request during the benchmark, public keys are used. These need to be created in both containers:

```bash
service ssh enable
service ssh start
```

Do not enter any password after executing this command:

```bash
ssh-keygen -t rsa -b 2048
```

The public keys which were created in each container need to be exchanged among each other:


CONTAINER 1:
```bash
vim /root/.ssh/id_rsa.pub
```

Copy this key and paste it in:

CONTAINER 2:
```bash
vim /root/.ssh/authorized_keys
```
Please redo this step by copying the key from the second container to the first.

After completing this step, a Docker Network needs to be created.

```bash
docker network create svsomeip
docker network connect svsomeip container_id_1
docker network connect svsomeip container_id_2
```

The different container ID's can be found out with the help of:

```bash
docker ps -aqf "name=containername"
```

To guarantee the right assignment of the remote containers the IP address of each container is needed. This address can be found out with the help of:

```bash
docker inspect container_name
```

Now we have to connect the two containers via SSH to accept the key-pair. This is done with:

CONTAINER 1:
```bash
ssh <IP OF CONTAINER 2>
```

CONTAINER 2:
```bash
ssh <IP OF CONTAINER 1>
```

The two gained IP addresses can now be used in order to identify the client and service container. To create the secure-vsomeip repository, the user must create a build folder in the secure-vsomeip folder. Both created containers have to follow below given steps in order to successfully install the secure-vsomeip and execute the benchmark. This can be done by following commands:

```bash
cd secure-vsomeip
mkdir build
cd build
```
After successfully moving into the build folder you can now build the program. Therefore, insert the before gained IP addresses. For this reason, container one or container two is assigned to either the MASTER or the WORKER. In the following command two dummy IP addresses are used. Please make sure to use the previous gained IP's. It is also possible to change the security by renaming confidentiality to either nosec or authentication. Remember to edit all upcoming commands incase you change the security.

```bash
cmake .. -DCMAKE_BUILD_TYPE="Release" -DENABLE_SIGNAL_HANDLING=1 -DBENCH_IP_MASTER=192.168.192.2 -DBENCH_IP_SLAVE=192.168.192.3 -DCONFIGURATION_SECURITY_LEVEL=confidentiality
```

Now several make commands are needed to finish the installation.

```bash
make all
make build_benchmarks
make install
export LD_LIBRARY_PATH=/usr/local/lib/
mv benchmarks/conf benchmarks/conf-confidentiality
```

After completing this step, the configuration files from the MASTER need to be copied to the WORKER.
Copy the MASTER configuration and files to the same location on the WORKER using [SCP](https://linuxize.com/post/how-to-use-scp-command-to-securely-transfer-files/). The required configurations and files are as follows:

```bash
/root/secure-vsomeip/build/benchmark/conf-confidentiality/bench_request_response_client_external.json
/root/secure-vsomeip/crypto/generated/certificates
/root/secure-vsomeip/crypto/generated/keys/confidentiality.key
```
The remote benchmark can now be started. Therefore navigate to:

```bash
cd /root/secure-vsomeip/build/benchmarks
```

From there execute the runtime benchmark. This will execute the **request and response** benchmark in synchronous and asynchronous mode. In addition the **publish and subscribe** benchmark is performed. It is only needed to execute this command in the MASTER container. The security level will be confidential with 10 iterations and 5000 synchronous messages as well as 2000 asynchronous messages:

```bash
./run_runtime_protection_benchmarks.sh /root/secure-vsomeip/build/benchmarks .. conf-confidentiality log-confidentiality confidentiality 10 5000 2000
```

The log can be found in "/root/secure-vsomeip/build/benchmarks" and is called "log-confidentiality".

## Installation and execution for local client containers

To execute the benchmark script in one local container, several adjustments need to be made. The first step will create a build folder in order to build the program:

```bash
cd secure-vsomeip
mkdir build
cd build
```
After successfully moving into the build folder you can now build the program. Therefore, the IP addresses of the MASTER container is needed. This IP can be obtained using this line of code:

```bash
docker inspect container_name
```
Now replace the dummy IP in the below given command and execute it. The SLAVE IP is not relevant in this case.

```bash
cmake .. -DCMAKE_BUILD_TYPE="Release" -DENABLE_SIGNAL_HANDLING=1 -DBENCH_IP_MASTER=192.168.192.2 -DBENCH_IP_SLAVE=192.168.192.3 -DCONFIGURATION_SECURITY_LEVEL=confidentiality
```

Now several make commands are needed to finish the installation.

```bash
make all
make build_benchmarks
make install
export LD_LIBRARY_PATH=/usr/local/lib/
mv benchmarks/conf benchmarks/conf-confidentiality
```

To finish the local benchmark setup, the master scripts of **request and response** as well as **publish and subscribe** need to be adjusted. Replace the content of:

```bash
/root/secure-vsomeip/build/benchmarks/bench_request_response_master.sh
/root/secure-vsomeip/build/benchmarks/bench_publish_subscribe_master.sh
```
With the content of the files "bench_request_response_master_update.sh" and "bench_publish_subscribe_master_update.sh". These files can be found in the repository.

The remote benchmark can now be started. Therefore navigate to:

```bash
cd /root/secure-vsomeip/build/benchmarks
```

From there execute the local runtime benchmark. This will execute the **request and response** benchmark in synchronous and asynchronous mode. In addition the **publish and subscribe** benchmark is performed. The security level will be confidential with 10 iterations and 5000 synchronous messages as well as 2000 asynchronous messages:

```bash
./run_runtime_protection_benchmarks.sh /root/secure-vsomeip/build/benchmarks .. conf-confidentiality log-confidentiality confidentiality 10 5000 2000
```

The log can be found in "/root/secure-vsomeip/build/benchmarks" and is called "log-confidentiality".
