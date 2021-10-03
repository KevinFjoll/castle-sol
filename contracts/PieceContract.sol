// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;
pragma abicoder v2;

import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC721/ERC721Holder.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./PuzzleContract.sol";
import "./ArrayUtils.sol";

contract PieceContract is ERC721, ERC721Holder, Ownable {
  using Counters for Counters.Counter;
  using EnumerableSet for EnumerableSet.UintSet;
  using ArrayUtils for uint256[];

  struct Piece {
    uint8 tier;
    uint8 position;
    uint8 puzzle;
  }

  Counters.Counter private _tokenIds;
  mapping(uint256 => Piece) private _pieces;

  uint8 public maxSupply = 12;
  bool public mintingEnabled = false;

  PuzzleContract puzzleContract;

  constructor() ERC721("Castle-Piece", "CSTLPCE") {}

  function updatePuzzleContract(address newContract) public onlyOwner {
    puzzleContract = PuzzleContract(newContract);
  }

  function setMintingEnabled(bool enabled) public onlyOwner returns (bool) {
    return mintingEnabled = enabled;
  }

  function mintFullPuzzle() public view returns (bool) {
    uint256 count = balanceOf(msg.sender);
    require(count >= 2, "PieceContract: Full set is required to mint Puzzle");
    //check if all unique pieces are held
    uint256[] memory tokenIDs = ownerTokenIDs(msg.sender);
    (bool found1, ) = tokenIDs.indexOf(1);
    (bool found2, ) = tokenIDs.indexOf(2);
    if (found1 && found2) return true;
    return false;
  }

  function mint(string memory tokenURI) public onlyOwner returns (uint256) {
    return mintFor(msg.sender, tokenURI);
  }

  function mintFor(address owner, string memory tokenURI)
    public
    onlyOwner
    returns (uint256)
  {
    require(mintingEnabled, "PieceContract: minting is not enabled");
    require(
      _tokenIds.current() + 1 <= maxSupply,
      "PieceContract: all pieces have been minted"
    );
    _tokenIds.increment();
    uint256 newItemId = _tokenIds.current();
    _safeMint(owner, newItemId);
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
      "PieceContract: tokenID query for the zero address"
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
      "PieceContract: tokenMetadata query for the zero address"
    );
    uint256 total = balanceOf(owner);
    string[] memory metaList = new string[](total);
    for (uint256 i = 0; i < total; i++) {
      metaList[i] = tokenURI(tokenOfOwnerByIndex(owner, i));
    }
    return metaList;
  }
}
