#!/bin/sh
org=$1
echo "=================Create mychannel ================"

peer channel create -o $ORDERER_ADDRESS -c mychannel -f ../config/mychannel.tx --outputBlock ../config/mychannel.block

echo "=================Join mychannel ================"

peer channel join -b ../config/mychannel.block -o $ORDERER_ADDRESS

echo "=================Update anchor peer ================"

peer channel update -f ../config/Org${org}MSPanchors.tx -c mychannel -o $ORDERER_ADDRESS