// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;
pragma abicoder v2;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";

contract NFTContract is ERC721 {
  using Counters for Counters.Counter;
  using EnumerableSet for EnumerableSet.UintSet;

  Counters.Counter private _tokenIds;
  mapping(address => EnumerableSet.UintSet) private _ownerTokens;

  uint16 public maxSupply = 2e3;
  bool public mintingEnabled = false;
  address payable public contractOwner;

  constructor() ERC721("Castle-Test", "TEST") {
    contractOwner = msg.sender;
  }

  modifier onlyOwner() {
    require(
      msg.sender == contractOwner,
      "NFTContract: caller is not the owner on onlyOwner modified function"
    );
    _;
  }

  function setMintingEnabled(bool enabled) public onlyOwner returns (bool) {
    return mintingEnabled = enabled;
  }

  function addToMaxSupply(uint16 add) public onlyOwner returns (uint16) {
    require(
      maxSupply + add <= type(uint16).max,
      "NFTContract: maxSupply cannot be higher than it's types maximum value"
    );
    maxSupply += add;
    return maxSupply;
  }

  function mintNFT(string memory tokenURI) public payable returns (uint256) {
    require(mintingEnabled, "NFTContract: minting is not enabled");
    require(
      _tokenIds.current() + 1 <= maxSupply,
      "NFTContract: all tokens have been minted"
    );
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);
    _setTokenURI(newItemId, tokenURI);
    _ownerTokens[msg.sender].add(newItemId);
    return newItemId;
  }

  function ownerTokenIDs(address owner)
    public
    view
    virtual
    returns (uint256[] memory)
  {
    require(
      owner != address(0),
      "NFTContract: tokenID query for the zero address"
    );
    bytes32[] memory byteArray = _ownerTokens[owner]._inner._values;
    uint256[] memory tokenIDs = new uint256[](byteArray.length);
    for (uint256 i = 0; i < byteArray.length; i++) {
      tokenIDs[i] = uint256(byteArray[i]);
    }
    return tokenIDs;
  }

  function ownerTokenMetadata(address owner)
    public
    view
    virtual
    returns (string[] memory)
  {
    require(
      owner != address(0),
      "NFTContract: tokenMetadata query for the zero address"
    );
    uint256[] memory tokenIDs = ownerTokenIDs(owner);
    string[] memory tokenMetaData = new string[](tokenIDs.length);
    for (uint256 i = 0; i < tokenIDs.length; i++) {
      tokenMetaData[i] = tokenURI(tokenIDs[i]);
    }
    return tokenMetaData;
  }
}
