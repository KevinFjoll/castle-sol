// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;
pragma abicoder v2;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155Holder.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./StringUtils.sol";

/** @title Piece Contract */
contract PieceContract is ERC1155, Ownable {
  using Counters for Counters.Counter;
  using EnumerableSet for EnumerableSet.UintSet;

  uint16[4] public pieceCounts = [1, 2, 4, 8];
  uint8 public tierCount = 4;
  uint8 public rowCount = 3;
  uint8 public columnCount = 3;

  bool public mintingEnabled = false;

  constructor()
    ERC1155(
      "https://raw.githubusercontent.com/CastleNFT/castle-sol/master/test-data/pieces/{id}.json"
    )
  {
    super;
  }

  function setMintingEnabled(bool enabled) public onlyOwner returns (bool) {
    return mintingEnabled = enabled;
  }

  function uri(uint256 tokenId) public pure override returns (string memory) {
    return
      string(
        abi.encodePacked(
          "https://raw.githubusercontent.com/CastleNFT/castle-sol/master/test-data/pieces/",
          StringUtils.uint2str(tokenId),
          ".json"
        )
      );
  }

  function mintAllPieces(address mintTo) public onlyOwner {
    require(mintingEnabled, "Minting is disabled.");
    for (uint8 tier = 0; tier < tierCount; tier++) {
      for (uint8 row = 0; row < rowCount; row++) {
        for (uint8 col = 0; col < columnCount; col++) {
          uint256 tokenId = calcTokenId(tier, row, col);
          _mint(mintTo, tokenId, pieceCounts[tier], "");
        }
      }
    }
    mintingEnabled = false;
  }

  function calcTokenId(
    uint256 tier,
    uint256 row,
    uint256 column
  ) public view returns (uint256) {
    return
      1 +
      (uint256(tier) * uint256(rowCount) * uint256(columnCount)) +
      (uint256(row) * 5 + uint256(column));
  }
}
