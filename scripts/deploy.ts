// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const CastleContract = await ethers.getContractFactory("CastleContract");
  const castle = await CastleContract.deploy();

  console.log(`CastleContract deployed to: ${castle.address}`);

  await castle.deploySubContracts();

  console.log(
    `PuzzleContract deployed to: ${await castle.puzzleContract()} and PieceContract to: ${await castle.pieceContract()}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
