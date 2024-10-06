# Hyperledger Fabric Project

## Overview
This project is built using Hyperledger Fabric, a distributed ledger technology (DLT) framework. It enables businesses to develop blockchain solutions tailored to their needs with support for private transactions and confidential contracts.

The following guide will walk you through the process of setting up the Hyperledger Fabric environment, installing necessary binaries, and configuring the development environment to run this project.

## Prerequisites
Before you begin, ensure that you have the following software installed on your machine:
- Git: Version control system to clone the project repository.
- Docker: Required for running Hyperledger Fabric components such as peers, orderers, and certificate authorities.
- Docker Compose: Manages the Docker containers.
- cURL or wget: For downloading files.
- Go: Hyperledger Fabric chaincode is written in Go, so ensure Go is installed and configured

## Getting Started


./install-fabric.sh

# move the binaries to our bin folder
Step 1: Clone the Repository

Step 2: Install Hyperledger Fabric Binaries and Docker Images

Step 3: Move the Binaries to the Project's bin Folder

Step 4: Generate Crypto Material and Genesis Block

Step 5: Start the Hyperledger Fabric Network

Step 6: Deploy Chaincode

Step 7: Interact with the Network

Step 8: Shut Down the Network

## Project Structure
/your-hyperledger-fabric-project
│
├── bin/                        # Hyperledger Fabric binaries (peer, orderer, cryptogen, etc.)
├── crypto/                     # Crypto material (certificates, keys)
├── chaincode/                  # Chaincode directory (smart contracts written in Go)
├── artifacts/                  # Channel configuration files (genesis block, channel tx)
├── scripts/                    # Docker Compose file to start the Fabric network
└── README.md                 # Project documentation (this file)

## Contributing
If you’d like to contribute to this project, feel free to submit a pull request or open an issue. Contributions are welcome!

## License
This project is licensed under the MIT License - see the LICENSE file for details.
