// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;
pragma abicoder v2;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721Holder.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./PieceContract.sol";
import "./ArrayUtils.sol";

contract PuzzleContract is ERC721, ERC721Holder, Ownable {
  using Counters for Counters.Counter;
  using EnumerableSet for EnumerableSet.UintSet;

  Counters.Counter private _tokenIds;

  uint16 public maxSupply = 3;
  bool public mintingEnabled = false;

  PieceContract pieceContract;

  constructor() ERC721("Castle-Puzzle", "CSTLPZL") {}

  function updatePieceContract(address newContract) public onlyOwner {
    pieceContract = PieceContract(newContract);
  }

  function setMintingEnabled(bool enabled) public onlyOwner returns (bool) {
    return mintingEnabled = enabled;
  }

  function mintNFT(string memory tokenURI) public payable returns (uint256) {
    require(mintingEnabled, "PuzzleContract: minting is not enabled");
    require(
      _tokenIds.current() + 1 <= maxSupply,
      "PuzzleContract: all puzzles have been minted"
    );
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _safeMint(msg.sender, newItemId);
    _setTokenURI(newItemId, tokenURI);
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
      "PuzzleContract: tokenID query for the zero address"
    );
    uint256 total = balanceOf(owner);
    uint256[] memory idList = new uint256[](total);
    for (uint256 i = 0; i < total; i++) {
      idList[i] = tokenOfOwnerByIndex(owner, i);
    }
    return idList;
  }

  function ownerTokenMetadata(address owner)
    public
    view
    virtual
    returns (string[] memory)
  {
    require(
      owner != address(0),
      "PuzzleContract: tokenMetadata query for the zero address"
    );
    uint256 total = balanceOf(owner);
    string[] memory metaList = new string[](total);
    for (uint256 i = 0; i < total; i++) {
      metaList[i] = tokenURI(tokenOfOwnerByIndex(owner, i));
    }
    return metaList;
  }
}
