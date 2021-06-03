#!/bin/bash

if [ -z "$1" ]; then
  echo -e "Usage:\n  $0 [repository]"
  echo -e "\nExample:\n  $0 netivism/docker-wheezy-php55:fpm"
  echo -e "\nError:"
  echo -e "  Required repository."
  exit 1
fi

repo=$1
running_container=$(docker ps -a | awk '{print $1}' | grep -v CONTAINER) 

for container in $running_container
do
  image=$(docker inspect $container | jq '.[0].Config.Image' | tr -d '"')
  if [ "${image}" == "${repo}" ]; then
    echo $(docker inspect $container | jq '.[0].Name' | tr -d '/"')
  fi
done
