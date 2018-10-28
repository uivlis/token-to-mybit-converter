var TokenConverter = artifacts.require("./TokenConverter.sol");

module.exports = function (deployer) {
    deployer.deploy(TokenConverter);
}