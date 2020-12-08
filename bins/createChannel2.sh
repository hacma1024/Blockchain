#!/bin/sh
org=$1

echo "=================Fetch channel ================"

peer channel fetch 0 ../config/mychannel.block -o $ORDERER_ADDRESS -c mychannel

echo "=================Join mychannel ================"

peer channel join -b ../config/mychannel.block -o $ORDERER_ADDRESS

echo "=================Update anchor peer ================"

peer channel update -f ../config/Org${org}MSPanchors.tx -c mychannel -o $ORDERER_ADDRESS