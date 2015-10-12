#!/bin/bash

set -e

# Get container id
container_id=$(docker ps | grep "spagobilabs/spagobi:all-in-one" | awk '{print $1}')

# Get IP depending on the OS : IP of the VM on Mac OS, IP of the container on others

if [[ `uname` == 'Darwin'* ]]; then
	IP=$(docker-machine ip $(docker-machine active))
else
	IP=$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${container_id})
fi

port_container=$(docker port $container_id)
echo $port_container

IFS=':' read -a array <<< "$port_container"
port=$(echo ${array[1]})
address=$(echo $IP:$port)

# make sure the virtual machine is on
if [[ -z $IP ]]; then
	echo "Docker container not running"
	exit 1
else
	echo "Docker container running at IP : $IP"
fi

if [[ -z $port ]]; then
	echo "Container's ports not open to the local machine"
	exit 1
else
	echo "Container port : $port"
fi

echo "\nHomepage test"
status=$(curl -s --head -w %{http_code} $address/SpagoBI -o /dev/null)

if [[ "$status" > '390' ]]; then
	echo "Homepage not reached. Status : $status"
	exit 1
else
	echo "Homepage found with status : $status"
fi

echo "\nSmoketests were successful. \nOK."