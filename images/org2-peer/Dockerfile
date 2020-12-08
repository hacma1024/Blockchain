#Docker file for setting up the acme peer
FROM hyperledger/fabric-peer:2.2.0

LABEL  maintainer="JWCLab"

#1. Create a folder
RUN mkdir -p /var/hyperledger/config

#2. Copy the crypto for peer crypto
COPY ./test-network/organizations/peerOrganizations/org2.jwclab.com/peers/peer0.org2.jwclab.com /var/hyperledger/peer0.org2.jwclab.com
COPY ./test-network/organizations/ordererOrganizations/jwclab.com/orderers/orderer.jwclab.com/msp /var/hyperledger/orderer/msp
COPY ./test-network/organizations/ordererOrganizations/jwclab.com/orderers/orderer.jwclab.com/tls /var/hyperledger/orderer/tls

#3. Copy the crypto for admin crypto
COPY ./test-network/organizations/peerOrganizations/org2.jwclab.com/users /var/hyperledger/users

#4. Copy the anchor peer update tx
COPY ./test-network/channel-artifacts/Org2MSPanchors.tx /var/hyperledger/config/Org2MSPanchors.tx

#5. Copy the channel create tx file
COPY ./test-network/channel-artifacts/mychannel.tx /var/hyperledger/config/mychannel.tx

#6. Copy the core YAML
COPY ./config/core.yaml /var/hyperledger/config/core.yaml

#7. Copy the bins
COPY ./bins /var/hyperledger/bins

#8. Copy the test chaincode
COPY ./chaincode  /var/hyperledger/chaincode

#9. Set the working dir
ENV  ENV="/etc/profile"
RUN  echo "cd /var/hyperledger/bins" >> /etc/profile

#10. Install the jq package - used in scripts
RUN apk update \
 && apk add --no-cache git make musl-dev go jq vim\
 && rm -rf /var/cache/apk/* 

ENV GOROOT /usr/lib/go
ENV GOPATH /go
ENV PATH /go/bin:$PATH
ENV FABRIC_LOGGING_SPEC DEBUG
ENV CORE_PEER_TLS_ENABLED false
ENV CORE_PEER_GOSSIP_USELEADERELECTION true
ENV CORE_PEER_GOSSIP_ORGLEADER false
ENV CORE_PEER_PROFILE_ENABLED true
ENV CORE_PEER_ID peer0.org2.jwclab.com
ENV CORE_PEER_ADDRESS peer0.org2.jwclab.com:9051
ENV CORE_PEER_LISTENADDRESS 0.0.0.0:9051
ENV CORE_PEER_CHAINCODEADDRESS peer0.org2.jwclab.com:9052
ENV CORE_PEER_CHAINCODELISTENADDRESS 0.0.0.0:9052
ENV CORE_PEER_GOSSIP_BOOTSTRAP peer0.org2.jwclab.com:9051
ENV CORE_PEER_GOSSIP_EXTERNALENDPOINT peer0.org2.jwclab.com:9051
ENV CORE_PEER_LOCALMSPID Org2MSP
ENV ORDERER_ADDRESS orderer.jwclab.com:7050
#export CORE_PEER_MSPCONFIGPATH=/var/hyperledger/users/Admin@org2.jwclab.com/msp
ENV CORE_PEER_MSPCONFIGPATH /var/hyperledger/peer0.org2.jwclab.com/msp
ENV CORE_PEER_TLS_CERT_FILE /var/hyperledger/peer0.org2.jwclab.com/tls/server.crt
ENV CORE_PEER_TLS_KEY_FILE /var/hyperledger/peer0.org2.jwclab.com/tls/server.key
ENV CORE_PEER_TLS_ROOTCERT_FILE /var/hyperledger/peer0.org2.jwclab.com/tls/ca.crt
ENV FABRIC_CFG_PATH /var/hyperledger/config/
ENV ORDERER_CA /var/hyperledger/orderer/tls/tlscacerts/tls-128-199-151-251-32769.pem
ENV CC_CONSTRUCTOR '{"Args":["Instantiate"]}'
ENV CC_NAME "iotrecord"
ENV CC_PATH "/var/hyperledger/chaincode/iotrecord/go"
ENV CC_VERSION "1.0"
ENV CC_CHANNEL_ID "mychannel"
ENV CC_LANGUAGE "golang"
ENV INTERNAL_DEV_VERSION "1.0"
ENV CC2_PACKAGE_FOLDER "/var/hyperledger/packages"
ENV CC2_SEQUENCE 1
ENV CC2_INIT_REQUIRED "--init-required"
ENV PACKAGE_NAME "iotrecord.1.0-1.0.tar.gz"
ENV LABEL "iotrecord.1.0-1.0"

#11. Launch the peer
CMD peer node start
