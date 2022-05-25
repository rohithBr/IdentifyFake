from brownie import SupplyChain,accounts

def deploy_supply_chain():
    supplyChain=SupplyChain.deploy({"from":accounts[0]})
    
def main():
    deploy_supply_chain()