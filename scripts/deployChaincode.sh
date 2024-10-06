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

export PRIVATE_DATA_CONFIG=${PWD}/artifacts/private-data/collections_config.json

export CHANNEL_NAME=channel1

setGlobalsForOrderer() {
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/crypto/ordererOrganizations/nlr.nl/orderers/orderer.nlr.nl/msp/tlscacerts/tlsca.nlr.nl-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/ordererOrganizations/nlr.nl/users/Admin@nlr.nl/msp

}

setGlobalsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/peerOrganizations/org1.nlr.nl/users/Admin@org1.nlr.nl/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/peerOrganizations/org1.nlr.nl/users/Admin@org1.nlr.nl/msp
    export CORE_PEER_ADDRESS=localhost:7053
}

setGlobalsForPeer0Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/peerOrganizations/org2.nlr.nl/users/Admin@org2.nlr.nl/msp
    export CORE_PEER_ADDRESS=localhost:8051
}

setGlobalsForPeer1Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/peerOrganizations/org2.nlr.nl/users/Admin@org2.nlr.nl/msp
    export CORE_PEER_ADDRESS=localhost:8053
}

setGlobalsForPeer0Org3() {
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/peerOrganizations/org3.nlr.nl/users/Admin@org3.nlr.nl/msp
    export CORE_PEER_ADDRESS=localhost:9051

}

setGlobalsForPeer1Org3() {
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/crypto/peerOrganizations/org3.nlr.nl/users/Admin@org3.nlr.nl/msp
    export CORE_PEER_ADDRESS=localhost:9053
}

presetup() {
    echo Vendoring Go dependencies ...
    pushd ./chaincode/car
    GO111MODULE=on go mod vendor
    popd
    echo Finished vendoring Go dependencies
}


CHANNEL_NAME="channel1"
CC_RUNTIME_LANGUAGE="golang"
VERSION="2"
CC_SRC_PATH="./chaincode/car"
CC_NAME="car"
SEQUENCE="1"

packageChaincode() {
    rm -rf ${CC_NAME}.tar.gz
    setGlobalsForPeer0Org1
    peer lifecycle chaincode package ${CC_NAME}.tar.gz \
        --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} \
        --label ${CC_NAME}_${VERSION}
    echo "===================== Chaincode is packaged on peer0.org1 ===================== "
}

installChaincode() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org1 ===================== "

    setGlobalsForPeer1Org1
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer1.org1 ===================== "

    setGlobalsForPeer0Org2
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org2 ===================== "

    setGlobalsForPeer1Org2
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer1.org2 ===================== "

    setGlobalsForPeer0Org3
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer0.org3 ===================== "

    setGlobalsForPeer1Org3
    peer lifecycle chaincode install ${CC_NAME}.tar.gz
    echo "===================== Chaincode is installed on peer1.org3 ===================== "
}


queryInstalled() {
    setGlobalsForPeer0Org1
    PACKAGE_ID=$(peer lifecycle chaincode queryinstalled 2>&1 | sed -n "/${CC_NAME}_${VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}")
}

# --collections-config ./artifacts/private-data/collections_config.json \
#         --signature-policy "OR('Org1MSP.member','Org2MSP.member')" \
# --collections-config $PRIVATE_DATA_CONFIG \

getBlock() {
    setGlobalsForPeer0Org1
    # peer channel fetch 10 -c channel1 -o localhost:7050 \
    #     --ordererTLSHostnameOverride orderer.nlr.nl --tls \
    #     --cafile $ORDERER_CA

    peer channel getinfo  -c $CHANNEL_NAME -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.nlr.nl --tls \
        --cafile $ORDERER_CA
}

# --signature-policy "OR ('Org1MSP.member')"
# --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG2_CA
# --peerAddresses peer0.org1.nlr.nl:7051 --tlsRootCertFiles $PEER0_ORG1_CA --peerAddresses peer0.org2.nlr.nl:9051 --tlsRootCertFiles $PEER0_ORG2_CA
#--channel-config-policy Channel/Application/Admins
# --signature-policy "OR ('Org1MSP.peer','Org2MSP.peer')"

# --collections-config ./artifacts/private-data/collections_config.json \
# --signature-policy "OR('Org1MSP.member','Org2MSP.member')" \

approveForMyOrg1() {
    queryInstalled
    setGlobalsForPeer0Org1
    # set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.nlr.nl --tls \
        --collections-config $PRIVATE_DATA_CONFIG \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence $SEQUENCE
    # set +x

    echo "===================== chaincode approved from org 1 ===================== "

}

approveForMyOrg2() {
    queryInstalled
    setGlobalsForPeer0Org2

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.nlr.nl --tls \
        --collections-config $PRIVATE_DATA_CONFIG \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence $SEQUENCE

    echo "===================== chaincode approved from org 2 ===================== "
}

approveForMyOrg3() {
    queryInstalled
    setGlobalsForPeer0Org3

    peer lifecycle chaincode approveformyorg -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.nlr.nl --tls \
        --collections-config $PRIVATE_DATA_CONFIG \
        --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name ${CC_NAME} --version ${VERSION} \
        --init-required --package-id ${PACKAGE_ID} \
        --sequence $SEQUENCE

    echo "===================== chaincode approved from org 2 ===================== "
}



checkCommitReadyness() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness --channelID $CHANNEL_NAME \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --collections-config $PRIVATE_DATA_CONFIG \
        --name ${CC_NAME} --version ${VERSION} --sequence "1" --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

commitChaincodeDefination() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.nlr.nl \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        --channelID $CHANNEL_NAME --name ${CC_NAME} \
        --collections-config $PRIVATE_DATA_CONFIG \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_ORG2_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG3_CA \
        --version ${VERSION} --sequence "1" --init-required

}


queryCommitted() {
    setGlobalsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}

}

chaincodeInvokeInit() {
    setGlobalsForPeer0Org1
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.nlr.nl \
        --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n ${CC_NAME} \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_ORG2_CA \
        --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG3_CA \
        --isInit -c '{"Args":[]}'

}

chaincodeInvoke() {
    setGlobalsForPeer0Org1
    # peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.nlr.nl \
    # --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} \
    # --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
    # --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_ORG2_CA  \
    # --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG3_CA  \
    # -c '{"function":"initLedger","Args":[]}'

    # setGlobalsForPeer0Org1

    ## Create Car
    peer chaincode invoke -o localhost:7050 \
        --ordererTLSHostnameOverride orderer.nlr.nl \
        --tls $CORE_PEER_TLS_ENABLED \
        --cafile $ORDERER_CA \
        -C $CHANNEL_NAME -n $CC_NAME  \
        --peerAddresses localhost:7051 \
        --tlsRootCertFiles $PEER0_ORG1_CA \
        --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA   \
        -c '{"function":"initLedger","Args":[]}'

    ## Add private data
    # export CAR=$(echo -n "{\"key\":\"1111\", \"make\":\"Tesla\",\"model\":\"Tesla A1\",\"color\":\"White\",\"owner\":\"pavan\",\"price\":\"10000\"}" | base64 | tr -d \\n)
    # peer chaincode invoke -o localhost:7050 \
    #     --ordererTLSHostnameOverride orderer.nlr.nl \
    #     --tls $CORE_PEER_TLS_ENABLED \
    #     --cafile $ORDERER_CA \
    #     -C $CHANNEL_NAME -n ${CC_NAME} \
    #     --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_ORG1_CA \
    #     --peerAddresses localhost:8051 --tlsRootCertFiles $PEER0_ORG2_CA \
    #     --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_ORG3_CA \
    #     -c '{"function": "initLedger", "Args":[]}' \
    #     --transient "{\"car\":\"$CAR\"}"
}

chaincodeQuery() {
    setGlobalsForPeer0Org1

    # Query all cars
    peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"Args":["queryAllCars"]}'

    # Query Car by Id
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "get","Args":["key"]}'
    #'{"Args":["GetSampleData","Key1"]}'

    # Query Private Car by Id
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "readPrivateCar","Args":["1111"]}'
    # peer chaincode query -C $CHANNEL_NAME -n ${CC_NAME} -c '{"function": "readCarPrivateDetails","Args":["1111"]}'
}

# Run this function if you add any new dependency in chaincode

# presetup
# packageChaincode
# installChaincode


# approveForMyOrg1
# approveForMyOrg2
# approveForMyOrg3

# checkCommitReadyness

# commitChaincodeDefination
# queryCommitted

# chaincodeInvokeInit
# sleep 5
# chaincodeInvoke
# sleep 3
chaincodeQuery


popd