DECLARE last_update TIMESTAMP;
DECLARE last_block INT64;

SET (last_update, last_block) = (
  SELECT AS STRUCT MAX(block_timestamp) AS t, MAX(block_number) AS n FROM `privacyexplorer.tornado_transactions.traces`
);

INSERT `privacyexplorer.tornado_transactions.traces` SELECT * FROM `bigquery-public-data.crypto_ethereum.traces`
  WHERE block_timestamp >= last_update AND block_number > last_block
  AND (`from_address` IN ( SELECT `address` FROM `privacyexplorer.tornado_transactions.tornadocontracts` )
   OR  `to_address` IN ( SELECT `address` FROM `privacyexplorer.tornado_transactions.tornadocontracts` ))
  AND SUBSTR(`input`, 1, 10) IN ("0xb214faa5", "0x21a0adb6");

INSERT `privacyexplorer.tornado_transactions.transactions` SELECT * FROM `bigquery-public-data.crypto_ethereum.transactions` WHERE
  block_timestamp >= last_update AND block_number > last_block AND
  `hash` IN ( SELECT `transaction_hash` FROM `privacyexplorer.tornado_transactions.traces` WHERE
     block_timestamp >= last_update AND block_number > last_block);
