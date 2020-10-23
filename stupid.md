use this stupid version
https://github.com/SamYuan1990/stupid/tree/docker

docker build -t stupid:latest .

docker run  --network yourminifabnetwork -v /pathto/minifabric:/tmp  stupid ./stupid /tmp/config.yaml 10 
