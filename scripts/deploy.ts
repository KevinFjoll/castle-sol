// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log(`\n[DEPLOYMENT] Deployer: ${deployer.address}`);

  const CastleContract = await ethers.getContractFactory("CastleContract");
  const castle = await CastleContract.deploy();

  console.log(`[DEPLOYMENT] CastleContract: ${castle.address}`);

  const receipt = await (await castle.deploySubContracts()).wait();

  const deployedAddresses = receipt.events?.map((e) => e.address) || [
    undefined,
    undefined,
  ];

  console.log(`[DEPLOYMENT] PuzzleContract: ${deployedAddresses[1]}`);
  console.log(`[DEPLOYMENT] PieceContract: ${deployedAddresses[0]}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
