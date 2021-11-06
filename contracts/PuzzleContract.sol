// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;
pragma abicoder v2;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155Holder.sol";
import "../node_modules/@openzeppelin/contracts/utils/Counters.sol";
import "../node_modules/@openzeppelin/contracts/utils/EnumerableSet.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./StringUtils.sol";

/** @title Puzzle Contract */
contract PuzzleContract is ERC1155, Ownable {
  using Counters for Counters.Counter;
  using EnumerableSet for EnumerableSet.UintSet;

  uint16[4] puzzlesPerTier;

  bool public mintingEnabled;
  bool public mintingDone;

  constructor(uint16[4] memory _puzzlesPerTier)
    ERC1155(
      "https://raw.githubusercontent.com/CastleNFT/castle-sol/master/test-data/puzzles/{id}.json"
    )
  {
    puzzlesPerTier = _puzzlesPerTier;
  }

  /** @dev Enables minting.
   * @param enabled boolean indicating the minting state to be set
   * @return _mintingEnabled whether minting is enabled now
   */
  function setMintingEnabled(bool enabled)
    public
    onlyOwner
    returns (bool _mintingEnabled)
  {
    require(!mintingDone, "Minting has already been done.");
    return mintingEnabled = enabled;
  }

  /** @dev Override of uri function to return puzzle specific metadata uri
   * @param tokenId tokenId of the puzzle whose metadata uri is being queried for
   * @return _uri the URI of this specific token
   */
  function uri(uint256 tokenId)
    public
    pure
    override
    returns (string memory _uri)
  {
    return
      string(
        abi.encodePacked(
          "https://raw.githubusercontent.com/CastleNFT/castle-sol/master/test-data/puzzles/",
          StringUtils.uint2str(tokenId),
          ".json"
        )
      );
  }

  /** @dev Mints all puzzles to the sender and disables minting.
   */
  function mintAllPuzzles() public onlyOwner {
    require(mintingEnabled, "Minting is disabled.");
    for (uint256 i = 0; i < puzzlesPerTier.length; i++) {
      _mint(msg.sender, i, puzzlesPerTier[i], "");
    }
    (mintingEnabled, mintingDone) = (false, true);
  }
}
