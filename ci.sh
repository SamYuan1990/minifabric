#!/usr/bin/env bash
set -ex

#build script if your needed, please build muanually
DIR=$PWD
docker build -t hfrd/minifab:latest .
git clone https://github.com/guoger/tape.git && cd tape
docker build -t tape:latest . 
cd $DIR
#ls -al

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
            #start tape for performance testing
            # docker run  -e TAPE_LOGLEVEL=debug --network host -v $PWD:/config tape tape $CONFIG_FILE 500
            # + docker run -e TAPE_LOGLEVEL=debug --network host -v /home/vsts/work/1/s:/config 
            #tape tape /config/test/config20org1andorg2.yaml 500
            # + docker run --name tape --network minifab -v /home/vsts/work/1/s:/config tape tape /config/config.yaml 100
            docker run --name tape -e TAPE_LOGLEVEL=debug --network minifab -v $PWD:/config tape tape /config/config.yaml 500
            export tps=$(docker logs tape --tail 1| cut -d ":" -f 4)
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