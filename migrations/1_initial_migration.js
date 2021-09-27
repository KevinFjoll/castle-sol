const PieceContract = artifacts.require("PieceContract");
const PuzzleContract = artifacts.require("PuzzleContract");

module.exports = function (deployer) {
  deployer.deploy(PieceContract);
  deployer.deploy(PuzzleContract);
};
