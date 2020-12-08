export CORE_PEER_TLS_ENABLED=true
# export ORDERER_CA=var/hyperledger/orderer.jwclab.com/msp/tlscacerts/tlsca.jwclab.com-cert.pem
# export PEER0_ORG1_CA=var/hyperledger/peer1.org1.jwclab.com/msp/tlscacerts/tlsca.org1.jwclab.com-cert.pem
# export PEER0_ORG2_CA=var/hyperledger/peer1.org2.jwclab.com/msp/tlscacerts/tlsca.org2.jwclab.com-cert.pem
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/jwclab.com/orderers/orderer.jwclab.com/msp/tlscacerts/tlsca.jwclab.com-cert.pem
export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/org1.jwclab.com/peers/peer0.org1.jwclab.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/org2.jwclab.com/peers/peer0.org2.jwclab.com/tls/ca.crt
export FABRIC_CFG_PATH=$PWD/../config/
export ORDERER_ADDRESS=localhost:7050

export CC_CONSTRUCTOR='{"function":"Instantiate","Args":[]}'
export INTERNAL_DEV_VERSION="2.0"
export CC2_PACKAGE_FOLDER="/var/hyperledger/packages"
export CC2_SEQUENCE=2
export CC2_INIT_REQUIRED="--init-required"
export CHANNEL_NAME="mychannel"
export CC_RUNTIME_LANGUAGE="golang"
export VERSION=2
export CC_VERSION="2"
export CC_SRC_PATH="../chaincode/iotrecordv2/go"
export CC_NAME="iotrecord"
# Create the package with this name
export PACKAGE_NAME="$CC_NAME.$CC_VERSION-$INTERNAL_DEV_VERSION"
# Extracts the package ID for the installed chaincode
export LABEL="$CC_NAME.$CC_VERSION-$INTERNAL_DEV_VERSION"

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
        --sequence ${VERSION}
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

# Run this function if you add any new dependency in chaincode
# presetup

# import utils
. scripts/envVar.sh
org=$1
setGlobals $org
echo $CORE_PEER_MSPCONFIGPATH
echo $CORE_PEER_ADDRESS
flag=$2
if ($flag); then
    #packageChaincode
    echo $flag > results.txt
    installChaincode
    queryInstalled
    approveForMyOrg
    checkCommitReadyness
else
    echo $flag > results.txt
fi
