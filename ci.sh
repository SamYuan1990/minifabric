#!/usr/bin/env bash
set -ex

docker build -t hfrd/minifab:latest .
git clone https://github.com/SamYuan1990/stupid.git && cd stupid && git checkout docker
docker build -t stupid:latest . && cd ..
./minifab up
docker ps
docker network ls
./minifab cleanup
