/* eslint-disable no-unused-expressions */
import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { PuzzleContract } from "../typechain";

describe("PuzzleContract", function () {
  let puzzle: PuzzleContract;
  const puzzlesPerTier = [1, 2, 4, 8];

  const fillRange = (start: number, end: number) => {
    return Array(end - start + 1)
      .fill(0)
      .map((_, index: number) => start + index);
  };

  this.beforeAll(async function () {
    const PuzzleContract = await ethers.getContractFactory("PuzzleContract");
    puzzle = await PuzzleContract.deploy(
      puzzlesPerTier as [number, number, number, number]
    );
  });

  it("check deployment", async function () {
    expect(puzzle.address).to.be.a("string");
  });

  it("setMintingEnabled()", async function () {
    await puzzle.setMintingEnabled(true);
    expect(await puzzle.mintingEnabled()).to.be.true;
  });

  it("mintAllPuzzles()", async function () {
    const accounts = await ethers.getSigners();
    await puzzle.mintAllPuzzles();
    expect(
      (
        await puzzle.balanceOfBatch(
          Array(puzzlesPerTier.length).fill(accounts[0].address),
          fillRange(1, puzzlesPerTier.length)
        )
      ).map((bn) => bn.toNumber())
    ).to.deep.equal(puzzlesPerTier);
  });

  it("uri()", async function () {
    expect(await puzzle.mintingDone()).to.be.true;
    const uri = await puzzle.uri(1);
    expect(uri).to.be.equal(
      "https://bafybeibigzpasy5bx2hnzeqzoanscaaspjz6kgswpmzs6s2bcpvaa4y2mq.ipfs.dweb.link/{id}.json"
    );
  });
});
