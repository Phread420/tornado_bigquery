# Lessons Learned

## Why not look at Deposit and Withdraw events in the logs table?

I got extra Deposit and Withdraw events from (I think) old versions of the Tornado.cash contract.
I got better data by looking for deposit and withdraw method calls in the traces table.

## Why create partial copies of the transactions and traces tables?

Querying against the full bigquery-public-data:crypto_ethereum
dataset gets expensive. For example, the traces table is 2.5 terabytes, so a full query against
it cost $12.50. See DailyUpdate.sql for the daily query I use to keep just the
Tornado.cash-relevant data in much smaller, less-expensive-to-query tables.

Costs end up under the 1TB-query-per-month, 10GB-storage-per-month free tier limits.

## How to recreate the tornado_transactions dataset

Download, install, and configure the bq command-line tool from Google.

Create a tornado_transactions dataset.

On the command line, using the bq tool, create the tornadocontracts, traces, and transactions tables:

```
bq load tornado_transactions.tornadocontracts ./tornadocontracts.csv ./tornadocontracts_schema.json
bq mk --schema ./traces_schema.json tornado_transactions.traces
bq mk --schema ./transactions_schema.json tornado_transactions.transactions
```

Copy the Tornado.cash-relevant rows from the public dataset into your traces and transactions tables with:
```
INSERT `tornado_transactions.traces` SELECT * FROM `bigquery-public-data.crypto_ethereum.traces`
  WHERE (`from_address` IN ( SELECT `address` FROM `tornado_transactions.tornadocontracts` )
   OR  `to_address` IN ( SELECT `address` FROM `tornado_transactions.tornadocontracts` ))
  AND SUBSTR(`input`, 1, 10) IN ("0xb214faa5", "0x21a0adb6");

INSERT `tornado_transactions.transactions` SELECT * FROM `bigquery-public-data.crypto_ethereum.transactions`
 WHERE `hash` IN ( SELECT `transaction_hash` FROM `tornado_transactions.traces` );
```

Use the queries in DailyUpdate.sql to update those tables with the latest transactions (either run
manually or schedule it to run daily).

## What about other chains?
I suspect some people are using Tornado with the same address on multiple chains-- e.g. depositing 10ETH on the ethereum chain, and 1000MATIC on the polygon chain from address A, then withdrawing to address B on both chains.

There's a public BigQuery dataset [for the polygon chain](https://blog.polygon.technology/polygon-blockchain-datasets-are-now-available-on-google-bigquery-67e91a32aaee/).

Annoyingly, it currently uses a very slightly different table schema than the crypto_ethereum dataset (I filed [two](https://github.com/blockchain-etl/polygon-etl/issues/44) [issues](https://github.com/blockchain-etl/polygon-etl/issues/45)).

