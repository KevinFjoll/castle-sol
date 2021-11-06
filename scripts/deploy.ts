// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const CastleContract = await ethers.getContractFactory("CastleContract");
  // const PuzzleContract = await ethers.getContractFactory("PuzzleContract");
  // const PieceContract = await ethers.getContractFactory("PieceContract");
  // const StringUtils = await ethers.getContractFactory("StringUtils");
  // const ArrayUtils = await ethers.getContractFactory("ArrayUtils");
  const castle = await CastleContract.deploy();

  await castle.deployed();

  console.log(`CastleContract deployed to: ${castle.address}`);

  // await castle.deploySubContracts();

  // console.log(
  //   `PuzzleContract deployed to: ${await castle.puzzleContract()} and PieceContract to: ${await castle.pieceContract()}`
  // );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
