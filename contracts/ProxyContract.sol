// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;

import "./Owner.sol";

contract ProxyContract is Owner {
  struct Contract {
    address contractAddress;
    bool exists;
  }

  mapping(string => Contract) private contractMapper;

  event ContractUpdated(string indexed name, address indexed contractAddress);

  function updateContract(string memory name, address contractAddress)
    public
    isOwner
  {
    contractMapper[name] = Contract(contractAddress, true);
    ContractUpdated(name, contractAddress);
  }

  function getContract(string memory name) external view returns (address) {
    require(
      contractMapper[name].exists,
      "ProxyContract: Contract does not exist"
    );
    return contractMapper[name].contractAddress;
  }
}
