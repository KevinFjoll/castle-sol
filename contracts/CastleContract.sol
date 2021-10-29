// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;
pragma abicoder v2;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./PieceContract.sol";
import "./PuzzleContract.sol";

/** @title Castle Contract */
contract CastleContract is ERC1155Holder, Ownable {
  PieceContract public pieceContract;
  PuzzleContract public puzzleContract;

  /** @dev Deploys an instance of both PieceContract and PuzzleContract.
   */
  function deploySubContracts() public onlyOwner {
    pieceContract = new PieceContract();
    puzzleContract = new PuzzleContract();
  }

  /** @dev Enables minting on the children contracts.
   * @return success if both contracts are now enabled to mint
   */
  function prepareMinting() public onlyOwner returns (bool success) {
    return
      pieceContract.setMintingEnabled(true) &&
      puzzleContract.setMintingEnabled(true);
  }

  function canLockPiecesForTier(uint8 tier) public view returns (bool success) {
    bool flag = false;
    for (uint8 row = 0; row < pieceContract.rowCount(); row++) {
      for (uint8 col = 0; col < pieceContract.columnCount(); col++) {
        uint256 tokenId = pieceContract.calcTokenId(tier, row, col);
        flag = pieceContract.balanceOf(msg.sender, tokenId) == 0;
      }
    }
    return !flag;
  }

  function lockPieces(uint8 tier) public returns (bool success) {
    require(canLockPiecesForTier(tier), "collection is not complete"); // TODO: rework error message
    uint256[] memory ids = new uint256[](25);
    uint256[] memory amounts = new uint256[](25);
    pieceContract.safeBatchTransferFrom(
      msg.sender,
      address(this),
      ids,
      amounts,
      ""
    );
    return true;
  }

  /** @dev Mints all pieces to an address and all puzzles to itself.
   * @param mintPiecesTo address to send the minted pieces to
   */
  function runMinting(address mintPiecesTo) public onlyOwner {
    require(
      pieceContract.mintingEnabled(),
      "Minting is disabled for PieceContract."
    );
    require(
      puzzleContract.mintingEnabled(),
      "Minting is disabled for PuzzleContract."
    );
    pieceContract.mintAllPieces(mintPiecesTo);
    puzzleContract.mintAllPuzzles();
  }
}
