docker pull jwclabacr/orderer:latest 

docker build -t jwclabacr/orderer . -f images/orderer/Dockerfile

docker push jwclabacr/orderer:latest 

docker pull jwclabacr/org1:latest 

docker build -t jwclabacr/org1 . -f images/org1-peer/Dockerfile

docker push jwclabacr/org1:latest 

docker pull jwclabacr/org2:latest 

docker build -t jwclabacr/org2 . -f images/org2-peer/Dockerfile

docker push jwclabacr/org2:latest 