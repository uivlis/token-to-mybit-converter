var Migrations = artifacts.require("./Migrations.sol");
var TokenConverter = artifacts.require("./TokenConverter.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(
    TokenConverter, 
    /*BancorConverter_#1 contract address. You can choose another from https://etherscan.io/accounts?l=Bancor */
    0x3839416bd0095d97bE9b354cBfB0F6807d4d609E, 
    /* MYB address */
    0x5d60d8d7eF6d37E16EBABc324de3bE57f135e0BC
    );
};
