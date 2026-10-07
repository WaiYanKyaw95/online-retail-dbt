# import
import duckdb

# connect to the duckdb
conn = duckdb.connect("C:/Users/USER/Desktop/Analytics_Engineering/online_retail/online_retail.duckdb")
# create a schema if not exists
conn.execute("CREATE SCHEMA IF NOT EXISTS raw")
# create or replace the table, from csv
conn.execute("CREATE OR REPLACE TABLE raw.online_retail_2009_2010 AS SELECT * FROM read_csv_auto('data/raw_2009_2010.csv')")
conn.execute("CREATE OR REPLACE TABLE raw.online_retail_2010_2011 AS SELECT * FROM read_csv_auto('data/raw_2010_2011.csv')")

# close the connection
conn.close()
