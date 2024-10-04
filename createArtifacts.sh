pushd ./artifacts

chmod -R 0755 ./crypto
rm system.block channel1.tx Org1MSPanchors.tx Org2MSPanchors.tx Org3MSPanchors.tx
rm -rf crypto/*

#Generate Crypto artifactes for organizations
cryptogen generate --config=./crypto-config.yaml --output=./crypto/

# Generate System Genesis block
configtxgen -profile OrdererGenesis -configPath . -channelID system-channel  -outputBlock ./system.block


# Generate channel configuration block
configtxgen -profile BasicChannel -configPath . -outputCreateChannelTx ./channel1.tx -channelID channel1

echo "#######    Generating anchor peer update for Org1MSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./Org1MSPanchors.tx -channelID channel1 -asOrg Org1MSP

echo "#######    Generating anchor peer update for Org2MSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./Org2MSPanchors.tx -channelID channel1 -asOrg Org2MSP

echo "#######    Generating anchor peer update for Org3MSP  ##########"
configtxgen -profile BasicChannel -configPath . -outputAnchorPeersUpdate ./Org3MSPanchors.tx -channelID channel1 -asOrg Org3MSP

popd