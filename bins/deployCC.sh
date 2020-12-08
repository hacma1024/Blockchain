#!/bin/sh
# Use this for testing your cloud setup *or* even local setup :)
# Example ./cc-test.sh  install  
function    usage {
    echo  "Usage: ./deployCC.sh install | commit | invoke | query "
    echo  "Installs the GoLang CC to specified Organization"
}

export CC_CONSTRUCTOR='{"Args":["Instantiate"]}'
export CC_NAME="iotrecord"
export CC_PATH="/var/hyperledger/chaincode/iotrecord/go"
export CC_VERSION="1.0"
export CC_CHANNEL_ID="mychannel"
export CC_LANGUAGE="golang"
export INTERNAL_DEV_VERSION="1.0"
export CC2_PACKAGE_FOLDER="/var/hyperledger/packages"
export CC2_SEQUENCE=1
export CC2_INIT_REQUIRED="--init-required"
export PACKAGE_NAME="iotrecord.1.0-1.0.tar.gz"
export LABEL="iotrecord.1.0-1.0"

OPERATION=$1

echo "CC Operation : $OPERATION"

# Extracts the package id from installed package
function cc_get_package_id {  
    OUTPUT=$(peer lifecycle chaincode queryinstalled -O json)
    PACKAGE_ID=$(echo $OUTPUT | jq -r ".installed_chaincodes[]|select(.label==\"$LABEL\")|.package_id")
}


# Packages & Installs the chaincode
function cc_install {
    # Create package folder if needed
    mkdir -p /var/hyperledger/packages

    # Check if package already exist
    if [ -f "$CC2_PACKAGE_FOLDER/$PACKAGE_NAME" ]; then
        echo "====> Step 1 Using the existing chaincode package:   $CC2_PACKAGE_FOLDER/$PACKAGE_NAME"
    else
        echo "====> Step 1 Creating the chaincode package $CC2_PACKAGE_FOLDER/$PACKAGE_NAME"
        peer lifecycle chaincode package $CC2_PACKAGE_FOLDER/$PACKAGE_NAME -p $CC_PATH --label=$LABEL -l $CC_LANGUAGE
    fi
    echo "====> Step 2   Installing chaincode (may fail if CC/version already there)"
    peer lifecycle chaincode install ${CC2_PACKAGE_FOLDER}/${PACKAGE_NAME}

    # set the package ID
    cc_get_package_id

     echo "====> Step 3 Query if installed successfully" 
    peer lifecycle chaincode queryinstalled

    # Approving the chaincode --channel-config-policy Channel/Application/Admins
    echo "===> Step 4   Approving the chaincode"
    peer lifecycle chaincode approveformyorg --channelID $CC_CHANNEL_ID --name $CC_NAME \
            --version $CC_VERSION --package-id $PACKAGE_ID --sequence $CC2_SEQUENCE $CC2_INIT_REQUIRED \
            -o $ORDERER_ADDRESS  
}

function cc_commit {
    # set the package ID
    cc_get_package_id

    # if already committed do nothing
    CHECK_IF_COMMITTED=$(peer lifecycle chaincode querycommitted -C $CC_CHANNEL_ID -n $CC_NAME)
    if [ $? == "0" ]; then
        echo "===> Step 1   Chaicode Already Committed - Ready for invoke & query."
    else
        echo "===> Step 1   Committing the chaincode"
        peer lifecycle chaincode commit -o orderer.jwclab.com:7050 --channelID mychannel --name iotrecord --version 1.0 --sequence 1 \
        --init-required --peerAddresses peer0.org1.jwclab.com:7051 --peerAddresses peer0.org2.jwclab.com:9051 --waitForEvent
        echo "===> Step 2   Query committed the chaincode"
        peer lifecycle chaincode querycommitted --channelID mychannel 
    fi
}



# Invoke the "peer chain code" command using the operation
case $OPERATION in
    "install")   
        cc_install
        ;;
    "commit")
        cc_commit
        ;;
    "invoke")
        echo "Invoke save record"
        peer chaincode invoke -o orderer.jwclab.com:7050 -C mychannel -n iotrecord --peerAddresses peer0.org1.jwclab.com:7051 --peerAddresses peer0.org2.jwclab.com:9051 --isInit -c '{"function":"InitLedger","Args":[]}'
        ;;
    "query")
        echo -n "query TEMPERATURE="
        peer chaincode query -C $CC_CHANNEL_ID -n $CC_NAME  -c '{"Args":["QueryRecordHistory","DANANG_1"]}'
        ;;
    *) usage
esac



