# Updated to Fabric 2.x
#1. Docker file for setting up the Orderer
FROM hyperledger/fabric-orderer:2.2.0

LABEL  maintainer="JWCLab"

#2. Create the folder for configurations
RUN mkdir -p /var/hyperledger/config

#3. Copy the crypto for orderer
COPY ./test-network/organizations/ordererOrganizations/jwclab.com/orderers/orderer.jwclab.com /var/hyperledger/orderer.jwclab.com

#4. Copy the genesis file
COPY ./test-network/system-genesis-block/genesis.block /var/hyperledger/config/genesis.block

#5. Copy the orderer YAML
COPY ./config/orderer.yaml /var/hyperledger/config/orderer.yaml
COPY ./test-network/organizations/ordererOrganizations/jwclab.com/orderers/orderer.jwclab.com/msp /var/hyperledger/orderer/msp
COPY ./test-network/organizations/ordererOrganizations/jwclab.com/orderers/orderer.jwclab.com/tls /var/hyperledger/orderer/tls


ENV FABRIC_LOGGING_SPEC DEBUG
ENV ORDERER_CFG_PATH /var/
ENV ORDERER_GENERAL_LEDGERTYPE file
ENV ORDERER_FILELEDGER_LOCATION /var/ledger/orderer
ENV ORDERER_GENERAL_BATCHTIMEOUT 1s
ENV ORDERER_GENERAL_BATCHSIZE_MAXMESSAGECOUNT "10"
ENV ORDERER_GENERAL_MAXWINDOWSIZE "1000"
ENV CONFIGTX_GENERAL_ORDERERTYPE solo
ENV CONFIGTX_ORDERER_KAFKA_BROKERS "kafka1.local.parisi.biz:9092,kafka2.local.parisi.biz:9092,kafka3.local.parisi.biz:9092,kafka4.local.parisi.biz:9092"
ENV ORDERER_KAFKA_RETRY_SHORTINTERVAL 1s
ENV ORDERER_KAFKA_RETRY_SHORTTOTAL 30s
ENV ORDERER_KAFKA_VERBOSE "true"
#ENV CONFIGTX_ORDERER_ADDRESSES "orderer:7050"
ENV ORDERER_GENERAL_LISTENADDRESS 0.0.0.0
ENV ORDERER_GENERAL_LISTENPORT 7050
ENV ORDERER_GENERAL_LOGLEVEL debug
ENV ORDERER_GENERAL_LOCALMSPDIR /var/hyperledger/orderer/msp
ENV ORDERER_GENERAL_LOCALMSPID OrdererMSP
ENV ORDERER_GENERAL_GENESISMETHOD file
ENV ORDERER_GENERAL_GENESISFILE /var/hyperledger/config/genesis.block
ENV ORDERER_GENERAL_GENESISPROFILE initial
ENV ORDERER_GENERAL_TLS_ENABLED false
ENV ORDERER_GENERAL_TLS_PRIVATEKEY /var/hyperledger/orderer/tls/server.key
ENV ORDERER_GENERAL_TLS_CERTIFICATE /var/hyperledger/orderer/tls/server.crt
ENV ORDERER_GENERAL_TLS_ROOTCAS /var/hyperledger/orderer/tls/ca.crt
ENV ORDERER_GENERAL_TLS_CLIENTAUTHREQUIRED false
ENV GODEBUG "netdns=go"
ENV ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY /var/hyperledger/orderer/tls/server.key
ENV ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE /var/hyperledger/orderer/tls/server.crt
ENV ORDERER_GENERAL_CLUSTER_ROOTCAS /var/hyperledger/orderer/tls/ca.crt          
ENV ORDERER_GENERAL_LEDGERTYPE "ram"
ENV ORDERER_OPERATIONS_LISTENADDRESS 0.0.0.0:8443
ENV ORDERER_METRICS_PROVIDER prometheus
ENV ORDERER_OPERATIONS_TLS_ENABLED false
ENV ORDERER_OPERATIONS_TLS_PRIVATEKEY /var/hyperledger/orderer/tls/server.key
ENV ORDERER_OPERATIONS_TLS_CERTIFICATE /var/hyperledger/orderer/tls/server.crt
ENV ORDERER_OPERATIONS_TLS_CLIENTROOTCAS /var/hyperledger/orderer/tls/ca.crt          
ENV ORDERER_OPERATIONS_TLS_CLIENTAUTHREQUIRED false
ENV METRICS.STATSD.ADDRESS 0.0.0.0:8125

#6. Launch the Orderer
CMD orderer


