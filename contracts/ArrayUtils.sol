pragma solidity >=0.7.6;

library ArrayUtils {
  function indexOf(uint256[] memory self, uint256 value)
    public
    pure
    returns (bool, uint256)
  {
    for (uint256 i = 0; i < self.length; i++)
      if (self[i] == value) return (true, i);
    return (false, 0);
  }
}