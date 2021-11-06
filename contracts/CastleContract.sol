// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
pragma abicoder v2;

import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./PieceContract.sol";
import "./PuzzleContract.sol";
import "./ArrayUtils.sol";

/** @title Castle Contract */
contract CastleContract is ERC1155Holder, Ownable {
  PieceContract public pieceContract;
  PuzzleContract public puzzleContract;

  uint16[4] public PUZZLES_PER_TIER = [1, 2, 4, 8];

  uint8 public ROW_COUNT = 3;
  uint8 public COLUMN_COUNT = 3;
  uint8 public GOLD_TIER = 1;
  uint8 public SILVER_TIER = 2;
  uint8 public IRON_TIER = 3;
  uint8 public BRONCE_TIER = 4;

  /** @dev Deploys an instance of both PieceContract and PuzzleContract.
   */
  function deploySubContracts() external onlyOwner {
    pieceContract = new PieceContract(
      PUZZLES_PER_TIER,
      ROW_COUNT,
      COLUMN_COUNT
    );
    puzzleContract = new PuzzleContract(PUZZLES_PER_TIER);
  }

  /** @dev Enables minting on the children contracts.
   * @return success if both contracts are now enabled to mint
   */
  function prepareMinting() external onlyOwner returns (bool success) {
    return
      pieceContract.setMintingEnabled(true) &&
      puzzleContract.setMintingEnabled(true);
  }

  /** @dev Locks a users puzzle and returns its pieces to the user.
   * @param tier the tier of the puzzle to be locked
   * @return success if the transfer has been finished successfully
   */
  function retrievePieces(uint8 tier) external returns (bool success) {
    require(puzzleContract.balanceOf(msg.sender, tier) > 0, "NO_PUZZLE"); // TODO: rework error message

    puzzleContract.safeTransferFrom(msg.sender, address(this), tier, 1, "");
    pieceContract.safeBatchTransferFrom(
      address(this),
      msg.sender,
      pieceContract.getTokenIdsOfTier(tier),
      ArrayUtils.getFilledArray(
        pieceContract.rowCount() * pieceContract.columnCount(),
        1
      ),
      ""
    );
    return true;
  }

  /** @dev Checks if a user can lock their pieces and retrieve a puzzle.
   * @param tier the tier of which pieces should be checked for
   * @return success whether the user is able to lock pieces
   */
  function canLockPiecesForTier(uint8 tier) public view returns (bool success) {
    bool flag;
    uint256[] memory ids = pieceContract.getTokenIdsOfTier(tier);
    for (uint256 i = 0; i < ids.length; i++) {
      flag = pieceContract.balanceOf(msg.sender, ids[i]) == 0;
    }
    return !flag;
  }

  /** @dev Locks a users pieces and returns a puzzle to the user.
   * @param tier the tier of the pieces to be locked
   * @return success if the transfer has been finished successfully
   */
  function lockPieces(uint8 tier) external returns (bool success) {
    require(canLockPiecesForTier(tier), "INCOMPLETE_COLLECTION"); // TODO: rework error message
    pieceContract.safeBatchTransferFrom(
      msg.sender,
      address(this),
      pieceContract.getTokenIdsOfTier(tier),
      ArrayUtils.getFilledArray(
        pieceContract.rowCount() * pieceContract.columnCount(),
        1
      ),
      ""
    );
    puzzleContract.safeTransferFrom(address(this), msg.sender, tier, 1, "");
    return true;
  }

  /** @dev Mints all pieces to an address and all puzzles to itself.
   * @param mintPiecesTo address to send the minted pieces to
   */
  function runMinting(address mintPiecesTo) external onlyOwner {
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
