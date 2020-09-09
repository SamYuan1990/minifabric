#!/usr/bin/env bash
set -ex

#build script if your needed, please build muanually
docker build -t hfrd/minifab:latest .
git clone https://github.com/SamYuan1990/stupid.git && cd stupid && git checkout docker
docker build -t stupid:latest . && cd ..

echo -e "Chaincode\t|BatchTimeout\t|MaxMessageCount\t|AbsoluteMaxBytes\t|PreferredMaxBytes\t|TPS\t|\n" >> rs.out
txnumber=$1
cooldown=$2
chaincode=sample
# ref Fair and Efficient Gossip in Hyperledger Fabric https://docs.qq.com/pdf/DVWRaU3lSU0RRV0xm
for BatchTimeout in 0.75 # 1 2 1.5
do
    # ref Performance Modeling of Hyperledger Fabric https://docs.qq.com/pdf/DR2NTYWxNdGNwbUVt https://docs.qq.com/pdf/DR2NTYWxNdGNwbUVt
    for MaxMessageCount in 10 # 40 80 120
    do
        for AbsoluteMaxBytes in 2
        do
            # ref How to Databasify a Blockchain the Case of Hyperledger Fabric https://docs.qq.com/pdf/DVUJnbkFlUVduZExq
            for PreferredMaxBytes in 256 # 512 1024
            do
            #Prepare config for gensis block
            ./prepareConfig.sh $BatchTimeout $MaxMessageCount $AbsoluteMaxBytes $PreferredMaxBytes -n $chaincode
            #deploy your fabric network by minifab
            ./minifab up
            #start stupid for performance testing
            docker run --name stupid --network minifab -v $PWD:/tmp  stupid stupid /tmp/config.yaml $txnumber
            #echo "libgcc-4.8.5-4.h5.x86_64.rpm" | grep -Eo "[0-9]+\.[0-9]+.*x86_64"
            export tps=$(docker logs stupid --tail 1| cut -d ":" -f 4)
            echo -e "$chaincode\t|$BatchTimeout\t|$MaxMessageCount\t|$AbsoluteMaxBytes\t|$PreferredMaxBytes\t|$tps\t|\n" >> rs.out
            #clean up network by minifab
            ./minifab cleanup
            #cool down
            sleep $cooldown
            done
        done
    done
done
cat rs.out