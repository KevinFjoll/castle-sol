import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { CastleContract, PieceContract, PuzzleContract } from "../typechain";

describe("CastleContract Deploy", function () {
  let castle: CastleContract;

  this.beforeAll(async function () {
    const CastleContract = await ethers.getContractFactory("CastleContract");
    castle = await CastleContract.deploy();
  });

  it("check deployment", async function () {
    expect(castle.address).to.be.a("string");
  });

  it("deploySubContracts()", async function () {
    await castle.deploySubContracts();
    const pieceContract = await castle.pieceContract();
    const puzzleContract = await castle.puzzleContract();
    expect(pieceContract).to.be.a("string");
    expect(puzzleContract).to.be.a("string");
  });

  describe("CastleContract Functions", function () {
    let piece: PieceContract, puzzle: PuzzleContract;

    this.beforeAll(async function () {
      await castle.deploySubContracts();
      piece = await ethers.getContractAt(
        "PieceContract",
        await castle.pieceContract()
      );
      puzzle = await ethers.getContractAt(
        "PuzzleContract",
        await castle.puzzleContract()
      );
    });

    it("prepareMinting()", async function () {
      await castle.prepareMinting();
      const pieceEnabled = await piece.mintingEnabled();
      const puzzleEnabled = await puzzle.mintingEnabled();
      expect(pieceEnabled).to.be.true;
      expect(puzzleEnabled).to.be.true;
    });
  });
});
