// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;
pragma abicoder v2;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155Holder.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./StringUtils.sol";
import "./PieceContract.sol";

/** @title Puzzle Contract */
contract PuzzleContract is ERC1155, Ownable {
  using Counters for Counters.Counter;
  using EnumerableSet for EnumerableSet.UintSet;

  uint256 public GOLD = 1;
  uint256 public SILVER = 2;
  uint256 public IRON = 3;
  uint256 public BRONCE = 4;

  bool public mintingEnabled = false;

  constructor()
    ERC1155(
      "https://raw.githubusercontent.com/CastleNFT/castle-sol/master/test-data/puzzles/{id}.json"
    )
  {}

  function setMintingEnabled(bool enabled) public onlyOwner returns (bool) {
    return mintingEnabled = enabled;
  }

  function uri(uint256 tokenId) public pure override returns (string memory) {
    return
      string(
        abi.encodePacked(
          "https://raw.githubusercontent.com/CastleNFT/castle-sol/master/test-data/puzzles/",
          StringUtils.uint2str(tokenId),
          ".json"
        )
      );
  }

  function mintAllPuzzles() public onlyOwner {
    require(mintingEnabled, "Minting is disabled.");
    _mint(msg.sender, GOLD, 1, "");
    _mint(msg.sender, SILVER, 1, "");
    _mint(msg.sender, IRON, 1, "");
    _mint(msg.sender, BRONCE, 1, "");
    mintingEnabled = false;
  }
}
