#!/bin/make
.PHONY: test slither


############################################################
# variables
############################################################


# project data
SRC=src
DATA=data

# contract data
CONTRACT_NAME="ArbitrageBot"
CONTRACT_SRC="$(SRC)/$(CONTRACT_NAME).sol"
# CONTRACT_ADDRESS=""
# FORK=

# contract deploy options
#CONSTRUCTOR_ARGS="ForgeUSD" "FUSD" 18 1000000000000000000000 
#VALUE= 	# ether amount to send to contract in deploy
#GAS_LIMIT
#GAS_PRICE
#TX
#CHAIN
#NONCE
#KEYSTORE


############################################################
# build
############################################################


release:
	forge build \
		--optimize --optimizer-runs 100000 \
		--names --sizes
		--build-info \
		--build-info-path $DATA

build:
	forge build --names --sizes

data:
	solc --asm --opcodes --gas --abi --bin $(CONTRACT_SRC) -o $(DATA)/$(CONTRACT_NAME)


############################################################
# create
############################################################


create-local:
	forge create \
		--rpc-url ${LOCAL_URL} \
    	--private-key $(LOCAL_KEY) \
		$(CONTRACT_SRC):$(CONTRACT_NAME) \
    	--offline

create-goerli:
	forge create \
		--rpc-url $(GOERLI_URL) \
    	--private-key $(GOERLI_KEY) \
		$(CONTRACT_SRC):$(CONTRACT_NAME) \
    	--constructor-args $(CONSTRUCTOR_ARGS) \
    	--etherscan-api-key $(ETHERSCAN_API_KEY) \
    	--verify

create-ethereum:
	forge create \
		--rpc-url $(ETHEREUM_URL) \
    	--private-key $(ETHERSCAN_API_KEY) \
		$(CONTRACT_SRC):$(CONTRACT_NAME) \
    	--constructor-args $(CONSTRUCTOR_ARGS) \
    	--etherscan-api-key $(ETHERSCAN_API_KEY) \
    	--verify

create-polygon:
	forge create \
		--rpc-url $(POLYGON_URL) \
    	--private-key $(POLYGON_KEY) \
		$(CONTRACT_SRC):$(CONTRACT_NAME) \
    	--constructor-args $(CONSTRUCTOR_ARGS) \
    	--etherscan-api-key $(ETHERSCAN_API_KEY) \
    	--verify

create-mumbai:
	forge create \
		--rpc-url $(MUMBAI_URL) \
    	--private-key $(MUMBAI_KEY) \
		$(CONTRACT_SRC):$(CONTRACT_NAME) \

verify-contract:
	forge verify-contract \
		$(CONTRACT_ADDRESS) $(CONTRACT_NAME) \
		$(ETHERSCAN_API_KEY)


############################################################
# test
############################################################


test:
	forge test

test-fork:
	forge test --fork-url $(FORK)

test-ls:
	forge test --list

coverage:
	forge coverage

snapshot:
	forge snapshot --asc
	# forge snapshot --asc --check

slither:
	slither $(SRC)


############################################################
# inspect
############################################################


inspect-abi:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) abi

inspect-storage:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) storage-layout

inspect-methods:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) methods

inspect-events:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) events

inspect-gas:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) gas-estimates

inspect-meta:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) metadata

inspect-doc-user:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) user-doc

inspect-doc-dev:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) dev-doc

inspect-asm:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) asm

inspect-asm-optimized:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) asm-optimized

inspect-bytecode:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) bytecode

inspect-bytecode-deployed:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) deployed-bytecode

inspect-ir:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) ir

inspect-ir-optimized:
	forge inspect $(CONTRACT_SRC):$(CONTRACT_NAME) ir-optimized
