pushd ..
export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/crypto/ordererOrganizations/nlr.nl/orderers/orderer.nlr.nl/msp/tlscacerts/tlsca.nlr.nl-cert.pem
export PEER0_ORG1_CA=${PWD}/artifacts/crypto/peerOrganizations/org1.nlr.nl/peers/peer0.org1.nlr.nl/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/artifacts/crypto/peerOrganizations/org2.nlr.nl/peers/peer0.org2.nlr.nl/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/artifacts/crypto/peerOrganizations/org3.nlr.nl/peers/peer0.org3.nlr.nl/tls/ca.crt
export PEER1_ORG1_CA=${PWD}/artifacts/crypto/peerOrganizations/org1.nlr.nl/peers/peer1.org1.nlr.nl/tls/ca.crt
export PEER1_ORG2_CA=${PWD}/artifacts/crypto/peerOrganizations/org2.nlr.nl/peers/peer1.org2.nlr.nl/tls/ca.crt
export PEER1_ORG3_CA=${PWD}/artifacts/crypto/peerOrganizations/org3.nlr.nl/peers/peer1.org3.nlr.nl/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/config/

export CHANNEL_NAME=channel1


# setGlobalsForOrderer(){
#     export CORE_PEER_LOCALMSPID="OrdererMSP"
#     export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/crypto/ordererOrganizations/nlr.nl/orderers/orderer.nlr.nl/msp/tlscacerts/tlsca.nlr.nl-cert.pem
#     export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/ordererOrganizations/nlr.nl/users/Admin@nlr.nl/msp
    
# }

setGlobalsForPeer0Org1(){
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/peerOrganizations/org1.nlr.nl/users/Admin@org1.nlr.nl/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Org1(){
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/peerOrganizations/org1.nlr.nl/users/Admin@org1.nlr.nl/msp
    export CORE_PEER_ADDRESS=localhost:7053
}

setGlobalsForPeer0Org2(){
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/peerOrganizations/org2.nlr.nl/users/Admin@org2.nlr.nl/msp
    export CORE_PEER_ADDRESS=localhost:8051
}

setGlobalsForPeer1Org2(){
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/peerOrganizations/org2.nlr.nl/users/Admin@org2.nlr.nl/msp
    export CORE_PEER_ADDRESS=localhost:8053
}

setGlobalsForPeer0Org3(){
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/peerOrganizations/org3.nlr.nl/users/Admin@org3.nlr.nl/msp
    export CORE_PEER_ADDRESS=localhost:9051
}

setGlobalsForPeer1Org3(){
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/peerOrganizations/org3.nlr.nl/users/Admin@org3.nlr.nl/msp
    export CORE_PEER_ADDRESS=localhost:9053
}

createChannel(){

    setGlobalsForPeer0Org1
    
    peer channel create -o localhost:7050 -c $CHANNEL_NAME \
    --ordererTLSHostnameOverride orderer.nlr.nl \
    -f ./artifacts/${CHANNEL_NAME}.tx --outputBlock ./artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

# removeOldCrypto(){
#     rm -rf ./api-1.4/crypto/*
#     rm -rf ./api-1.4/fabric-client-kv-org1/*
#     rm -rf ./api-2.0/org1-wallet/*
#     rm -rf ./api-2.0/org2-wallet/*
#     rm -rf ./api-2.0/org2-wallet/*
# }


joinChannel(){
    setGlobalsForPeer0Org1
    peer channel join -b ./artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer1Org1
    peer channel join -b ./artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer0Org2
    peer channel join -b ./artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer1Org2
    peer channel join -b ./artifacts/$CHANNEL_NAME.block

    setGlobalsForPeer0Org3
    peer channel join -b ./artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer1Org3
    peer channel join -b ./artifacts/$CHANNEL_NAME.block
    
}

updateAnchorPeers(){
    setGlobalsForPeer0Org1
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.nlr.nl -c $CHANNEL_NAME -f ./artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0Org2
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.nlr.nl -c $CHANNEL_NAME -f ./artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0Org3
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.nlr.nl -c $CHANNEL_NAME -f ./artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
      
}

# removeOldCrypto

createChannel
joinChannel
updateAnchorPeers

popd