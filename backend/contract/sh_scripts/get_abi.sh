#! /bin/bash
 
# replace it with the network your contract lives on
NETWORK=testnet
# replace it with your contract address
CONTRACT_ADDRESS=$(cat contract_address.txt)
# replace it with your module name, every .move file except move script has module_address::module_name {}
MODULE_NAME=story_collision
 
# save the ABI to a TypeScript file
echo "export const ABI = $(curl https://fullnode.$NETWORK.aptoslabs.com/v1/accounts/$CONTRACT_ADDRESS/module/$MODULE_NAME | sed -n 's/.*"abi":\({.*}\).*}$/\1/p') as const" > ../src/abi.ts
