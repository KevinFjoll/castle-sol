// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

library StringUtils {
  /** @dev Concatenates five strings.
   * @param _a a string to be concatenated
   * @param _b a string to be concatenated
   * @param _c a string to be concatenated
   * @param _d a string to be concatenated
   * @param _e a string to be concatenated
   * @return _concat the concatenated string
   */
  function strConcat(
    string memory _a,
    string memory _b,
    string memory _c,
    string memory _d,
    string memory _e
  ) internal pure returns (string memory _concat) {
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    bytes memory _be = bytes(_e);
    string memory abcde = new string(
      _ba.length + _bb.length + _bc.length + _bd.length + _be.length
    );
    bytes memory babcde = bytes(abcde);
    uint256 k = 0;
    for (uint256 i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    for (uint256 i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
    for (uint256 i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
    for (uint256 i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
    for (uint256 i = 0; i < _be.length; i++) babcde[k++] = _be[i];
    return string(babcde);
  }

  /** @dev Concatenates four strings.
   * @param _a a string to be concatenated
   * @param _b a string to be concatenated
   * @param _c a string to be concatenated
   * @param _d a string to be concatenated
   * @return _concat the concatenated string
   */
  function strConcat(
    string memory _a,
    string memory _b,
    string memory _c,
    string memory _d
  ) internal pure returns (string memory _concat) {
    return strConcat(_a, _b, _c, _d, "");
  }

  /** @dev Concatenates three strings.
   * @param _a a string to be concatenated
   * @param _b a string to be concatenated
   * @param _c a string to be concatenated
   * @return _concat the concatenated string
   */
  function strConcat(
    string memory _a,
    string memory _b,
    string memory _c
  ) internal pure returns (string memory _concat) {
    return strConcat(_a, _b, _c, "", "");
  }

  /** @dev Concatenates two strings.
   * @param _a a string to be concatenated
   * @param _b a string to be concatenated
   * @return _concat the concatenated string
   */
  function strConcat(string memory _a, string memory _b)
    internal
    pure
    returns (string memory _concat)
  {
    return strConcat(_a, _b, "", "", "");
  }

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
