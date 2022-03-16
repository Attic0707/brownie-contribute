from brownie import Contribute
from scripts.helpfulScripts import getAccount


def contribute():
    contribute = Contribute[-1]
    account = getAccount()
    entranceFee = contribute.getEntranceFee()
    contribute.contribute({"from": account, "value": entranceFee})


def withdraw():
    contribute = Contribute[-1]
    account = getAccount()
    contribute.withdraw({"from": account})


def main():
    contribute()
    withdraw()
