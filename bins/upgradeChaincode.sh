export CORE_PEER_TLS_ENABLED=true
# export ORDERER_CA=var/hyperledger/orderer.jwclab.com/msp/tlscacerts/tlsca.jwclab.com-cert.pem
# export PEER0_ORG1_CA=var/hyperledger/peer1.org1.jwclab.com/msp/tlscacerts/tlsca.org1.jwclab.com-cert.pem
# export PEER0_ORG2_CA=var/hyperledger/peer1.org2.jwclab.com/msp/tlscacerts/tlsca.org2.jwclab.com-cert.pem
# export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/jwclab.com/orderers/orderer.jwclab.com/msp/tlscacerts/tlsca.jwclab.com-cert.pem
export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.jwclab.com/peers/peer0.org1.jwclab.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.jwclab.com/peers/peer0.org2.jwclab.com/tls/ca.crt
export FABRIC_CFG_PATH=$PWD/../config/
export ORDERER_ADDRESS=localhost:7050
export ORG1_ADDRESS=localhost:7051
export ORG2_ADDRESS=localhost:9051

# presetup
export CC_CONSTRUCTOR='{"function":"Instantiate","Args":[]}'
export INTERNAL_DEV_VERSION="2.0"
export CC2_PACKAGE_FOLDER="/var/hyperledger/packages"
export CC2_SEQUENCE=2
export CC2_INIT_REQUIRED="--init-required"
export CHANNEL_NAME="mychannel"
export CC_RUNTIME_LANGUAGE="golang"
export CC_VERSION="2"
export VERSION="2"
export CC_SRC_PATH="../chaincode/iotrecordv2/go"
export CC_NAME="iotrecord"
# Create the package with this name
export PACKAGE_NAME="$CC_NAME.$CC_VERSION-$INTERNAL_DEV_VERSION"
# Extracts the package ID for the installed chaincode
export LABEL="$CC_NAME.$CC_VERSION-$INTERNAL_DEV_VERSION"

echo Vendoring Go dependencies ...
pushd ../chaincode/iotrecord/go
GO111MODULE=on go mod vendor
popd
echo Finished vendoring Go dependencies

# import utils
. scripts/envVar.sh

packageChaincode() {
    rm -rf ${PACKAGE_NAME}.tar.gz
    peer lifecycle chaincode package ${PACKAGE_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${LABEL}
    echo "===================== Chaincode is packaged ===================== "
}
# packageChaincode

installChaincode() {
    peer lifecycle chaincode install ${PACKAGE_NAME}.tar.gz
    echo "===================== Chaincode is installed ===================== "
}

# installChaincode

queryInstalled() {
    peer lifecycle chaincode queryinstalled >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${LABEL}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful ===================== "
}

approveForMyOrg() {
    # set -x
    peer lifecycle chaincode approveformyorg -o $ORDERER_ADDRESS \
        --ordererTLSHostnameOverride orderer.jwclab.com --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        $CC2_INIT_REQUIRED --package-id ${PACKAGE_ID} \
        --sequence ${CC2_SEQUENCE}
    # set +x
    echo "===================== chaincode approved from my org ===================== "
}

checkCommitReadyness() {
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --name ${CC_NAME} --version ${VERSION} --sequence ${VERSION} --output json $CC2_INIT_REQUIRED > test.json
    cat test.json
    echo "===================== checking commit readyness from my org ====================="
}

# checkCommitReadyness
checkApprove(){
    array=( $(sed -n "/{/,/}/{s/[^:]*:[[:blank:]]*//p;}" test.json ) )
    a=${array[2]}
    while (!($a))
    do
        echo "waiting..."
        sleep 5
        array=( $(sed -n "/{/,/}/{s/[^:]*:[[:blank:]]*//p;}" test.json ) )
        a=${array[2]}
        # while read line; 
        # do 
        # b=$line; 
        # done < results.txt
        # if (!($b)); then
        #     exit 0
        # fi
    done
}

commitChaincodeDefination() {
    checkApprove
    peer lifecycle chaincode commit -o $ORDERER_ADDRESS --ordererTLSHostnameOverride orderer.jwclab.com \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME \
    --peerAddresses $ORG1_ADDRESS --tlsRootCertFiles $PEER0_ORG1_CA\
    --peerAddresses $ORG2_ADDRESS --tlsRootCertFiles $PEER0_ORG2_CA\
    --version ${VERSION} --sequence ${VERSION} --init-required >&log.txt
 
    cat log.txt
}

# commitChaincodeDefination

queryCommitted() {
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name $CC_NAME
}

# queryCommitted

chaincodeInvokeInit() {
    peer chaincode invoke -o $ORDERER_ADDRESS --ordererTLSHostnameOverride orderer.jwclab.com \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
    --peerAddresses $ORG1_ADDRESS --tlsRootCertFiles $PEER0_ORG1_CA\
    --peerAddresses $ORG2_ADDRESS --tlsRootCertFiles $PEER0_ORG2_CA\
    -C $CHANNEL_NAME --name $CC_NAME -c $CC_CONSTRUCTOR --waitForEvent --isInit
}

chaincodeQuery() {
    peer chaincode query -C $CHANNEL_NAME --name $CC_NAME  -c '{"function":"QueryRecordHistory","Args":["DANANG_1", "PH"]}'

}

# chaincodeQuery

# Run this function if you add any new dependency in chaincode
# presetup

org=$1
setGlobals $org
echo $CORE_PEER_MSPCONFIGPATH
echo $CORE_PEER_ADDRESS
packageChaincode
installChaincode
queryInstalled
approveForMyOrg
checkCommitReadyness
commitChaincodeDefination
queryCommitted
chaincodeInvokeInit
sleep 3
chaincodeQuery
