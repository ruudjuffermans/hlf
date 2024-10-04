FROM hyperledger/fabric-peer

# Create user 'juffermans' with a home directory and bash shell
RUN useradd -m -s /bin/bash juffermans

# Set the user for subsequent commands
USER juffermans


# Set environment variables
ENV CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock \
    CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=artifacts_default \
    CORE_LOGGING_LEVEL=INFO \
    CORE_PEER_GOSSIP_USELEADERELECTION=true \
    CORE_PEER_GOSSIP_ORGLEADER=false \
    CORE_PEER_GOSSIP_SKIPHANDSHAKE=true \
    CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/crypto/peer/msp \
    CORE_PEER_TLS_ENABLED=true \
    CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/crypto/peer/tls/server.key \
    CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/crypto/peer/tls/server.crt \
    CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/crypto/peer/tls/ca.crt

# Set the working directory
WORKDIR /opt/gopath/src/github.com/hyperledger/fabric/peer

# Command to start the peer node
CMD ["peer", "node", "start"]