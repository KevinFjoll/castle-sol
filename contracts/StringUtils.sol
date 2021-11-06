// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library StringUtils {
  /** @dev Returns the string representation of a uint256.
   * @param _i the integer to be stringified
   * @return _uintAsString the integer as string
   */
  function uint2str(uint256 _i)
    internal
    pure
    returns (string memory _uintAsString)
  {
    if (_i == 0) {
      return "0";
    }
    uint256 j = _i;
    uint256 len;

    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint256 k = len - 1;

    while (_i != 0) {
      bstr[k--] = bytes1(uint8(48 + (_i % 10)));
      _i /= 10;
    }
    return string(bstr);
  }
}
