/* eslint-disable no-unused-expressions */
import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { PieceContract } from "../typechain";

describe("PieceContract", function () {
  let piece: PieceContract;
  const puzzlesPerTier = [1, 2, 4, 8];
  const rowCount = 3;
  const columnCount = 3;

  const fillRange = (start: number, end: number) => {
    return Array(end - start + 1)
      .fill(0)
      .map((_, index: number) => start + index);
  };

  this.beforeAll(async function () {
    const PieceContract = await ethers.getContractFactory("PieceContract");
    piece = await PieceContract.deploy(
      puzzlesPerTier as [number, number, number, number],
      rowCount,
      columnCount
    );
  });

  it("check deployment", async function () {
    expect(piece.address).to.be.a("string");
  });

  it("setMintingEnabled()", async function () {
    await piece.setMintingEnabled(true);
    expect(await piece.mintingEnabled()).to.be.true;
  });

  it("calcTokenId()", async function () {
    const firstTokenId = await piece.calcTokenId(1, 1, 1);
    const lastTokenId = await piece.calcTokenId(
      puzzlesPerTier.length,
      rowCount,
      columnCount
    );
    expect(firstTokenId).to.equal(1);
    expect(lastTokenId).to.equal(
      puzzlesPerTier.length * rowCount * columnCount
    );
  });

  it("getTokenIdsOfTier()", async function () {
    for (const tier of fillRange(1, puzzlesPerTier.length)) {
      expect(
        (await piece.getTokenIdsOfTier(tier)).map((id) => id.toNumber())
      ).to.deep.equal(
        fillRange(
          1 + (tier - 1) * rowCount * columnCount,
          rowCount * columnCount + (tier - 1) * rowCount * columnCount
        )
      );
    }
  });

  it("mintAllPieces()", async function () {
    const accounts = await ethers.getSigners();
    await piece.mintAllPieces(accounts[0].address);
    expect(
      (
        await piece.balanceOfBatch(
          Array(puzzlesPerTier.length * rowCount * columnCount).fill(
            accounts[0].address
          ),
          fillRange(1, puzzlesPerTier.length * rowCount * columnCount)
        )
      ).map((bn) => bn.toNumber())
    ).to.deep.equal(
      Array(0).concat(
        ...puzzlesPerTier.map((puzzles) =>
          Array(rowCount * columnCount).fill(puzzles)
        )
      )
    );
  });

  it("uri()", async function () {
    expect(await piece.mintingDone()).to.be.true;
    const uri = await piece.uri(1);
    expect(uri).to.be.equal(
      "https://bafybeianv56sdv2ajdopcdvi5f6hrt65rww6oryg3olrmec5bwb6zlsdpi.ipfs.dweb.link/{id}.json"
    );
  });
});
