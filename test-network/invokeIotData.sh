# export PATH=${PWD}/../bin:$PATH
# export FABRIC_CFG_PATH=$PWD/../config/
# export CORE_PEER_TLS_ENABLED=true
# export CORE_PEER_LOCALMSPID="Org1MSP"
# export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.jwclab.com/peers/peer0.org1.jwclab.com/tls/ca.crt
# export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.jwclab.com/users/Admin@org1.jwclab.com/msp
# export CORE_PEER_ADDRESS=localhost:7051
# export ORDERER_ADDRESS=localhost:7050
# export PEERS="peer0.org1"
# export CHANNEL_NAME="mychannel"
# export TLSCACERT=${PWD}/organizations/ordererOrganizations/jwclab.com/orderers/orderer.jwclab.com/msp/tlscacerts/tlsca.jwclab.com-cert.pem
# export ORG1CACERT=${PWD}/organizations/peerOrganizations/org1.jwclab.com/peers/peer0.org1.jwclab.com/tls/ca.crt
# export ORG2CACERT=${PWD}/organizations/peerOrganizations/org2.jwclab.com/peers/peer0.org2.jwclab.com/tls/ca.crt
# export token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJkYXRhIjp7Il9pZCI6Im1hdV94eHgiLCJwYXNzd29yZCI6Imp3Y2xhYiIsInJvbGUiOiJzdGF0aW9uIn0sImlhdCI6MTYwMDY3MzMxMywiZXhwIjoxOTE2MDMzMzEzfQ.o24pnAycoPR0BpFUgea0V4A_gapnNnPrU0oZkmg-CEA
# curl -d '{"id":"mau_xxx","password":"jwclab"}' -H "Content-Type: application/json" -H "x-access-token :$token" -X POST http://identity.jwclab.com:32768/login


function getToken(){
	token=$(python3 /home/mau/PycharmProjects/envmonitoring/getTokenStation.py)
	len_token=`expr length "$token"`
	if [ len_token != 3 ]; then
		echo $token
	else
		echo "Error"
	fi
}


function chaincodeInvokeFiltered() {
	echo 
	echo "========== Invoke transaction iotdata ================"
	echo
	for i in {0..11}
	do
		python filterData.py
		sleep 5
	done
	md5_hash=$(python3 /home/mau/PycharmProjects/filterDataIOT/hashIotDataFiltered.py)
	echo $md5_hash
	# echo $data
	curl -d ''${md5_hash}'' -H "Content-Type: application/json" -H "x-access-token: $token" -X POST http://identity.jwclab.com:32768/add
	cat log.txt
	echo "===================== Invoke transaction successful on $PEERS on channel '$CHANNEL_NAME' ===================== "
}

function chaincodeInvokeNoFiltered() {
	echo 
	echo "========== Invoke transaction iotdata ================"
	echo
	md5_hash=$(python3 /home/mau/PycharmProjects/envmonitoring/hashIotDataNoFiltered.py)
	IFS=' ' read -a md5_hash_arr <<< "$md5_hash"
	for hash in "${md5_hash_arr[@]}";
	do
	# printf "$hash\n"
	token=$1
	if [ `expr length "$token"` != "5" ];then
		curl -d ''${hash}'' -H "Content-Type: application/json" -H "x-access-token: $token" -X POST http://identity.jwclab.com:32768/add
		echo 
	else
		echo "Token error."
	fi
	done
}

mode=$1
token=$(getToken)


while [ true ]; do
	if [ "$mode" == "filter" ]; then
		chaincodeInvokeFiltered
		sleep 60
	elif [ "$mode" == "nofilter" ];then
		chaincodeInvokeNoFiltered $token
		sleep 10
	elif [ "$mode" == "query" ];then
		echo "query"
		exit 0
	elif [ "$mode" == "test" ];then
		echo "test"
		exit 0
	else 
		echo "Invalid mode!"
		echo "Mode: filter--nofilter--query--test"
		exit 0
	fi
	
done



