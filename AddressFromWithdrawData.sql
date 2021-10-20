/* Extract address from withdraw method input string
 * EVM function is:
 *  withdraw(bytes _proof, bytes32 _root, bytes32 _nullifierHash, address _recipient, address _relayer, uint256 _fee, uint256 _refund)
 * MethodID: 0x21a0adb6
 * EVM ABI encoding is:
 *  4 byte method signature, 32 bytes _proof, 32 bytes _root, 32 bytes _nullifierHash, 64 bytes address, ...
 *     First 12 bytes of address are always zero, because addresses are 20 byte hashes
 * String-encoded in the database, add 2 for the leading "0x" and double all the number (each byte is two hex digits).
 * So to get to _recipient: 2+8+64+64+64+24 = 226  (and add 1 because SUBSTRING is 1-based).
 */
CREATE OR REPLACE FUNCTION `tornado_transactions.AddressFromWithdrawData`(d STRING) RETURNS STRING AS (
"0x" || SUBSTRING(d, 1+226, 40)
);
