/* keccak256 function signatures for Tornado.Cash deposit/withdraw functions */
DECLARE deposit_sig STRING DEFAULT "0xb214faa5";
DECLARE withdraw_sig STRING DEFAULT "0x21a0adb6";

DECLARE last_update TIMESTAMP;
DECLARE last_block INT64;

SET (last_update, last_block) = (
  SELECT AS STRUCT MAX(block_timestamp) AS t, MAX(block_number) AS n FROM `tornado_transactions.traces`
);

INSERT `tornado_transactions.traces` SELECT * FROM `bigquery-public-data.crypto_ethereum.traces`
  WHERE block_timestamp >= last_update AND block_number > last_block
  AND (`from_address` IN ( SELECT `address` FROM `tornado_transactions.tornadocontracts` )
   OR  `to_address` IN ( SELECT `address` FROM `tornado_transactions.tornadocontracts` ))
  AND SUBSTR(`input`, 1, 10) IN (deposit_sig, withdraw_sig);

INSERT `tornado_transactions.transactions` SELECT * FROM `bigquery-public-data.crypto_ethereum.transactions` WHERE
  block_timestamp >= last_update AND block_number > last_block AND
  `hash` IN ( SELECT `transaction_hash` FROM `tornado_transactions.traces` WHERE
     block_timestamp >= last_update AND block_number > last_block);
