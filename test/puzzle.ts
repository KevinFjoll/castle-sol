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

  it("mintAllPuzzles() before enabling mint", async function () {
    try {
      await puzzle.mintAllPuzzles();
    } catch (e: any) {
      expect(e).to.not.be.undefined;
      expect(e.message).to.contain("MINTING_DISABLED");
    }
  });

  it("setMintingEnabled()", async function () {
    await puzzle.setMintingEnabled(true);
    expect(await puzzle.mintingEnabled()).to.be.true;
  });

  it("mintAllPuzzles()", async function () {
    const accounts = await ethers.getSigners();
    expect(accounts[0]?.address).to.be.a("string");
    if (accounts[0].address) {
      await puzzle.mintAllPuzzles();
      expect(
        (
          await puzzle.balanceOfBatch(
            Array(puzzlesPerTier.length).fill(accounts[0].address),
            fillRange(1, puzzlesPerTier.length)
          )
        ).map((bn) => bn.toNumber())
      ).to.deep.equal(puzzlesPerTier);
    }
  });

  it("mintAllPuzzles() again", async function () {
    try {
      await puzzle.mintAllPuzzles();
    } catch (e: any) {
      expect(e).to.not.be.undefined;
      expect(e.message).to.contain("MINTING_DONE");
    }
  });

  it("setMintingEnabled() again", async function () {
    try {
      await puzzle.setMintingEnabled(true);
    } catch (e: any) {
      expect(e).to.not.be.undefined;
      expect(e.message).to.contain("MINTING_DONE");
    }
  });

  it("uri()", async function () {
    expect(await puzzle.mintingDone()).to.be.true;
    const uri = await puzzle.uri(1);
    expect(uri).to.be.equal(
      "https://bafybeiela6wtg3ga7kn3aznqomjzvfbxi36hd2ral4gc3zga2o3kcipigu.ipfs.dweb.link/{id}.json"
    );
  });
});
