const PieceContract = artifacts.require("PieceContract");
const PuzzleContract = artifacts.require("PuzzleContract");
const ArrayUtils = artifacts.require("ArrayUtils");

module.exports = async function (deployer) {
  await deployer.deploy(ArrayUtils, { overwrite: false });
  await deployer.link(ArrayUtils, PieceContract);
  await deployer.link(ArrayUtils, PuzzleContract);
  await deployer.deploy(PieceContract);
  await deployer.deploy(PuzzleContract);
};
