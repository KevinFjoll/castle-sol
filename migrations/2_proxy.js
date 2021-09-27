const ProxyContract = artifacts.require("ProxyContract");

module.exports = function (deployer) {
  deployer.deploy(ProxyContract);
};
