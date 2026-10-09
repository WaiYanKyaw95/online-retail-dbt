What the project is about
A dbt project that transforms a real online retail transaction raw data into a dimensional star schema, built on DuckDB with BigQuery as planned target.
Why this project
I wanted to learn data modeling properly. I’m reading Kimball’s Data Warehouse Toolkit and Adamson’s Star Schema: The Complete Reference, which helps me with theoretical knowledge. Also, analytics engineering sparks my interest since I like to explore and work with data, know the value of bad data and software engineering is of my interest. So, I decided to give it a try with this data set since there are only a handful of fields in the raw data, which can be easier to work on as a first project and learning by doing will give me a hands-on experience, working with dbt, DuckDB and BigQuery.
What I learned
Through this project, I learned
-	how to structure a dbt project
-	again, the importance of understanding the data I’m working on
-	writing tests and docs, paired with version control in Git and GitHub
-	working locally with DuckDB and pushing it to BigQuery afterward.
Overview
The screenshot shows a lineage from raw data into a dimensional star schema.
Models
staging
-	`stg_online_retail` - one row per invoice line, overlap removed and duplicates flagged.
marts
-	`fct_sales` - one row per invoice line, cancellations flagged and line amount calculated.
-	`dim_product` - one row per stock code with classified product categories from seed and product flagged.
-	`dim_customer` - one row per customer id, with first and last purchase dates and net revenue.
-	`dim_date`- one row per day; dates from 2009-01-01 to 2011-12-31, with date part information.
Seeds
Why seeds? It replaces messy SQL `CASE` statements. Also, since it’s inside the project, I can write tests and docs. And, everyone who’s working together on this project will have a consistent reference to them.
-	`special_stock_codes` - non-product codes, classified for product categories and includes reasons for each code, showing where I made assumptions.
Data and where to download
Online Retail II is a real data set that includes transactions occurring for a UK-based non-store online retail between 01/12/2009 and 09/12/2011. You can download the zip file here: https://archive.ics.uci.edu/dataset/502/online+retail+ii 
Decisions taken along the way (with codes that shows how to query the information that led to the decision)
-	Overlapped
-	duplicates
-	several descriptions per stock code – chose most frequent ones
-	null customer id – unknown
-	26 stock codes that are not products – used seeds for this purpose – look up tables, can apply test and include docs. Easy reference.
Tests
-	Generic – not null and unique
-	Relationships – they are used to see if the values from one table are present in another. Relationship tests in the projects relate from `fct_sales` to 
o	`dim_product` on `stock_code`
o	`dim_customer` on `customer_id`
-	Accepted values – they are used to only allow the values from a list and therefore the test will fail if the value is not one of the values from the list. I used `accepted_values` test for `product_category` in the `dim_product` model.
How to run (need to update)
First, clone the repo. Then `uv sync`. Move downloaded data into `data/`. Run `dbt deps` for dependencies. Then `dbt build` will handle everything (`dbt seeds`, `dbt run`, `dbt test`).
`dbt docs generate` to produce lineage, and `dbt docs serve` to see the lineage and docs on a local site.
Next steps
-	If any

Overlapped
SELECT COUNT(*), source_file FROM main.stg_online_retail
WHERE invoice_datetime >= '2010-12-01'
AND invoice_datetime < '2010-12-10'
GROUP BY source_file;

Duplicates
---
Several description per stock code
SELECT stock_code, COUNT(DISTINCT description) FROM main.stg_online_retail
GROUP BY stock_code
HAVING COUNT(DISTINCT description) > 1;
