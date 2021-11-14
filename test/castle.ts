/* eslint-disable no-unused-expressions */
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { CastleContract, PieceContract, PuzzleContract } from "../typechain";

describe("CastleContract", function () {
  let castle: CastleContract;
  describe("CastleContract Deploy", function () {
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

    it("deploySubContracts() again", async function () {
      try {
        await castle.deploySubContracts();
      } catch (e: any) {
        expect(e).to.not.be.undefined;
        expect(e.message).to.contain("ALREADY_DEPLOYED");
      }
    });
  });

  describe("CastleContract Functions", function () {
    let piece: PieceContract, puzzle: PuzzleContract;
    let puzzleSize: number;
    let puzzlesPerTier: number[];
    let accounts: SignerWithAddress[];

    const fillRange = (start: number, end: number) => {
      return Array(end - start + 1)
        .fill(0)
        .map((_, index: number) => start + index);
    };

    this.beforeAll(async function () {
      puzzleSize = (await castle.rowCount()) * (await castle.columnCount());
      puzzlesPerTier = await Promise.all(
        [0, 1, 2, 3].map(async (tier) => await castle.puzzlesPerTier(tier))
      );
      accounts = await ethers.getSigners();
      piece = await ethers.getContractAt(
        "PieceContract",
        await castle.pieceContract()
      );
      puzzle = await ethers.getContractAt(
        "PuzzleContract",
        await castle.puzzleContract()
      );
    });

    it("runMinting() before prepare", async function () {
      const accounts = await ethers.getSigners();
      expect(accounts[0]?.address).to.be.a("string");
      if (accounts[0].address) {
        try {
          await castle.runMinting(accounts[0].address);
        } catch (e: any) {
          expect(e).to.not.be.undefined;
          expect(e.message).to.contain("MINTING_DISABLED");
        }
      }
    });

    it("prepareMinting()", async function () {
      await castle.prepareMinting();
      const pieceEnabled = await piece.mintingEnabled();
      const puzzleEnabled = await puzzle.mintingEnabled();
      expect(pieceEnabled).to.be.true;
      expect(puzzleEnabled).to.be.true;
    });

    it("runMinting()", async function () {
      const accounts = await ethers.getSigners();
      expect(accounts[0]?.address).to.be.a("string");
      if (accounts[0].address) {
        await castle.runMinting(accounts[0].address);
        expect(
          (
            await piece.balanceOfBatch(
              Array(puzzleSize).fill(accounts[0].address),
              fillRange(1, puzzleSize)
            )
          ).map((bn) => bn.toNumber())
        ).to.deep.equal(Array(puzzleSize).fill(1));
        expect(
          (
            await puzzle.balanceOfBatch(
              Array(puzzlesPerTier.length).fill(castle.address),
              fillRange(1, puzzlesPerTier.length)
            )
          ).map((bn) => bn.toNumber())
        ).to.deep.equal(puzzlesPerTier);
      }
    });

    it("runMinting() again", async function () {
      const accounts = await ethers.getSigners();
      expect(accounts[0]?.address).to.be.a("string");
      if (accounts[0].address) {
        try {
          await castle.runMinting(accounts[0].address);
        } catch (e: any) {
          expect(e).to.not.be.undefined;
          expect(e.message).to.contain("MINTING_DONE");
        }
      }
    });

    it("canLockPiecesForTier()", async function () {
      const accounts = await ethers.getSigners();
      expect(accounts[0]?.address).to.be.a("string");
      if (accounts[0].address) {
        expect(await piece.mintingDone());
        expect(await puzzle.mintingDone());
        fillRange(1, puzzlesPerTier.length).forEach(
          async (tier) =>
            expect(await castle.canLockPiecesForTier(tier)).to.be.true
        );
      }
    });

    it("lockPieces() without approval", async function () {
      const accounts = await ethers.getSigners();
      expect(accounts[0]?.address).to.be.a("string");
      if (accounts[0].address) {
        try {
          await Promise.all(
            fillRange(1, puzzlesPerTier.length).map(
              async (tier) => await castle.lockPieces(tier)
            )
          );
        } catch (e: any) {
          expect(e).to.not.be.undefined;
          expect(e.message).to.contain("NOT_APPROVED");
        }
      }
    });

    it("lockPieces()", async function () {
      const accounts = await ethers.getSigners();
      expect(accounts[0]?.address).to.be.a("string");
      if (accounts[0].address) {
        expect(await piece.mintingDone());
        expect(await puzzle.mintingDone());
        await piece.setApprovalForAll(castle.address, true);
        await Promise.all(
          fillRange(1, puzzlesPerTier.length).map(async (tier) => {
            expect(await castle.canLockPiecesForTier(tier)).to.be.true;
            await castle.lockPieces(tier);
            expect(
              (
                await piece.balanceOfBatch(
                  Array(puzzleSize).fill(castle.address),
                  fillRange(1, puzzleSize)
                )
              ).map((bn) => bn.toNumber())
            ).to.deep.equal(Array(puzzleSize).fill(1));
            expect(await puzzle.balanceOf(accounts[0].address, tier)).to.equal(
              1
            );
          })
        );
      }
    });

    it("retrievePieces() before approval", async function () {
      expect(accounts[0]?.address).to.be.a("string");
      if (accounts[0].address) {
        try {
          for (const tier of fillRange(1, puzzlesPerTier.length)) {
            await castle.retrievePieces(tier);
          }
        } catch (e: any) {
          expect(e).to.not.be.undefined;
          expect(e.message).to.contain("NOT_APPROVED");
        }
      }
    });

    it("retrievePieces()", async function () {
      expect(accounts[0]?.address).to.be.a("string");
      if (accounts[0].address) {
        expect(await piece.mintingDone());
        expect(await puzzle.mintingDone());
        await puzzle.setApprovalForAll(castle.address, true);
        for (const tier of fillRange(1, puzzlesPerTier.length)) {
          expect(await puzzle.balanceOf(accounts[0].address, tier)).to.equal(1);
          await castle.retrievePieces(tier);
          expect(
            (
              await piece.balanceOfBatch(
                Array(puzzleSize).fill(accounts[0].address),
                fillRange(1, puzzleSize)
              )
            ).map((bn) => bn.toNumber())
          ).to.deep.equal(Array(puzzleSize).fill(1));
          expect(await puzzle.balanceOf(castle.address, tier)).to.equal(
            puzzlesPerTier[tier - 1]
          );
        }
      }
    });
  });
});
