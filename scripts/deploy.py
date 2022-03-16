from brownie import Contribute, MockV3Aggregator, network, config
from scripts.helpfulScripts import (
    getAccount,
    deployMocks,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)


def deployContribute():
    account = getAccount()

    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        priceFeedAddress = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
    else:
        deployMocks()
        priceFeedAddress = MockV3Aggregator[-1].address

    contribute = Contribute.deploy(
        priceFeedAddress,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    return contribute


def main():
    deployContribute()
