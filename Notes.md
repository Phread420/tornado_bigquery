# Why I did what I did: or, what worked and didn't work as I was doing this stuff

## Why not look at Deposit and Withdraw events in the logs table?

I got extra Deposit and Withdraw events from (I think) old versions of the Tornado.cash contract.
I got better data by looking for deposit and withdraw method calls in the traces table.

## Why create partial copies of the transactions and traces tables?

Querying against the full bigquery-public-data:crypto_ethereum
dataset gets expensive. For example, the traces table is 2.5 terabytes, so a full query against
it cost $12.50. See DailyUpdate.sql for the daily query I use to keep just the
Tornado.cash-relevant data in much smaller, less-expensive-to-query tables.

Costs end up under the 1TB-query-per-month, 10GB-storage-per-month free tier limits.

## How to recreate the privacyexplorer.tornado_transactions dataset

TODO... flesh this out:
Schema files for transactions/traces/tornadocontracts tables
Data for tornadocontracts
Initial data for transactions/traces by running DailyUpdate queries without the date/block restrictions
User-defined-function definitions
View definitions
Scheduling DailyUpdate query (see BigQuery documentation)
