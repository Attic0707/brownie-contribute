from scripts.helpfulScripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, getAccount
from scripts.deploy import deployContribute
from brownie import network, accounts, exceptions
import pytest


def test_canContribute():

    account = getAccount()
    contribute = deployContribute()
    entranceFee = contribute.getEntranceFee() + 100
    txn = contribute.contribute({"from": account, "value": entranceFee})
    txn.wait(1)
    assert contribute.amountPerAddress(account.address) == entranceFee
    txn2 = contribute.withdraw({"from": account})
    txn.wait(1)
    assert contribute.amountPerAddress(account.address) == 0


def test_onlyOwnerCanWithdraw():
    # fix this later
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip("Only for local testing")
    # account = getAccount()
    contribute = deployContribute()
    badActor = accounts.add()
    with pytest.raises(exceptions.VirtualMachineError):
        contribute.withdraw({"from": badActor})
