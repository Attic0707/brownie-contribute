from brownie import network, accounts, config, MockV3Aggregator

DECIMALS = 8
STARTING_PRICE = 200000000000
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"]


def getAccount():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    else:
        return accounts.load("TavanArasi")


def deployMocks():
    print(f"The active network is: {network.show_active()}")
    print("Deploying mocks... ")
    if len(MockV3Aggregator) <= 0:
        MockV3Aggregator.deploy(DECIMALS, STARTING_PRICE, {"from": getAccount()})
    print(f"Mock is deployed: {MockV3Aggregator[-1].address}")
