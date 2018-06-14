#!/bin/bash

mkdir -p /home/michelek/m2e
cd /home/michelek/m2e

printf "\nFetch data from mysql\n"
. ./test.sh

printf "\nPull from github.com/memoriaal/mysql2elastic.git\n"

git clone -q https://github.com/memoriaal/mysql2elastic.git ./
git checkout -q master
git pull

printf "\n\n"
version=`date +"%y%m%d.%H%M%S"`
docker build --quiet --pull --tag=m2e:$version ./ && docker tag m2e:$version m2e:latest

printf "\n\n"
docker stop m2e
docker rm m2e
docker run -d \
    --name="m2e" \
    --restart="always" \
    --cpu-shares=256 \
    --memory="250m" \
    --env="NODE_ENV=production" \
    --env="VERSION=$version" \
    --env="PORT=80" \
    --env="COOKIE_SECRET=" \
    --env="DEPLOYMENT=debug" \
    --env="MYSQL_PASS=" \
    --env="ELASTIC_PASS=" \
    --volume="/data/m2e/log:/home/michelek/m2e/log" \
    m2e:latest

printf "\nDockerized\n"
