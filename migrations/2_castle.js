const CastleContract = artifacts.require("CastleContract");
const PieceContract = artifacts.require("PieceContract");
const PuzzleContract = artifacts.require("PuzzleContract");
const StringUtils = artifacts.require("StringUtils");
const ArrayUtils = artifacts.require("ArrayUtils");

module.exports = async function (deployer) {
  await deployer.deploy(StringUtils, { overwrite: false });
  await deployer.link(StringUtils, PieceContract);
  await deployer.link(StringUtils, PuzzleContract);

  await deployer.deploy(ArrayUtils, { overwrite: false });
  await deployer.link(ArrayUtils, CastleContract);

  await deployer.deploy(CastleContract);
};
