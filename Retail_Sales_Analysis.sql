-- Retail Sales Analysis | MySQL
-- Dataset: Superstore-style retail orders
-- Expected table name: superstore_sales
-- If your imported table has another name, replace `superstore_sales` below.
-- Dates in the provided text appear as DD-MM-YYYY. These queries use STR_TO_DATE.
-- If your import wizard already converted dates to DATE columns, STR_TO_DATE still commonly works on their string representation.

-- 1. Inspect data
SELECT * FROM `superstore_sales` LIMIT 10;

SELECT COUNT(*) AS row_count,
       COUNT(DISTINCT `Row ID`) AS distinct_row_ids,
       COUNT(DISTINCT `Order ID`) AS unique_orders,
       COUNT(DISTINCT `Customer ID`) AS unique_customers,
       SUM(`Sales`) AS total_sales,
       SUM(`Profit`) AS total_profit,
       SUM(`Quantity`) AS total_quantity
FROM `superstore_sales`;

-- 2. Missing-value checks for important fields
SELECT
  SUM(`Order ID` IS NULL OR TRIM(`Order ID`) = '') AS missing_order_id,
  SUM(`Order Date` IS NULL OR TRIM(CAST(`Order Date` AS CHAR)) = '') AS missing_order_date,
  SUM(`Product ID` IS NULL OR TRIM(`Product ID`) = '') AS missing_product_id,
  SUM(`Sales` IS NULL) AS missing_sales,
  SUM(`Profit` IS NULL) AS missing_profit
FROM `superstore_sales`;

-- 3. Overall KPIs
SELECT
  ROUND(SUM(`Sales`), 2) AS total_sales,
  ROUND(SUM(`Profit`), 2) AS total_profit,
  SUM(`Quantity`) AS total_quantity,
  COUNT(DISTINCT `Order ID`) AS unique_orders,
  COUNT(DISTINCT `Customer ID`) AS unique_customers,
  ROUND(100 * SUM(`Profit`) / NULLIF(SUM(`Sales`), 0), 2) AS profit_margin_pct
FROM `superstore_sales`;

-- 4. Year-wise performance
SELECT YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y')) AS order_year,
       ROUND(SUM(`Sales`), 2) AS total_sales,
       ROUND(SUM(`Profit`), 2) AS total_profit,
       COUNT(DISTINCT `Order ID`) AS unique_orders
FROM `superstore_sales`
GROUP BY YEAR(STR_TO_DATE(`Order Date`, '%d-%m-%Y'))
ORDER BY order_year;

-- 5. Monthly sales and profit trend
SELECT DATE_FORMAT(STR_TO_DATE(`Order Date`, '%d-%m-%Y'), '%Y-%m') AS order_month,
       ROUND(SUM(`Sales`), 2) AS total_sales,
       ROUND(SUM(`Profit`), 2) AS total_profit,
       COUNT(DISTINCT `Order ID`) AS unique_orders
FROM `superstore_sales`
GROUP BY DATE_FORMAT(STR_TO_DATE(`Order Date`, '%d-%m-%Y'), '%Y-%m')
ORDER BY order_month;

-- 6. Category performance
SELECT `Category`,
       ROUND(SUM(`Sales`), 2) AS total_sales,
       ROUND(SUM(`Profit`), 2) AS total_profit,
       SUM(`Quantity`) AS units_sold
FROM `superstore_sales`
GROUP BY `Category`
ORDER BY total_sales DESC;

-- 7. Sub-category performance (including loss-making sub-categories)
SELECT `Category`, `Sub-Category`,
       ROUND(SUM(`Sales`), 2) AS total_sales,
       ROUND(SUM(`Profit`), 2) AS total_profit,
       SUM(`Quantity`) AS units_sold
FROM `superstore_sales`
GROUP BY `Category`, `Sub-Category`
ORDER BY total_profit ASC;

-- 8. Regional performance
SELECT `Region`, `State`,
       ROUND(SUM(`Sales`), 2) AS total_sales,
       ROUND(SUM(`Profit`), 2) AS total_profit,
       COUNT(DISTINCT `Order ID`) AS unique_orders
FROM `superstore_sales`
GROUP BY `Region`, `State`
ORDER BY total_sales DESC;

-- 9. Customer segment performance
SELECT `Segment`,
       ROUND(SUM(`Sales`), 2) AS total_sales,
       ROUND(SUM(`Profit`), 2) AS total_profit,
       COUNT(DISTINCT `Order ID`) AS unique_orders,
       COUNT(DISTINCT `Customer ID`) AS unique_customers
FROM `superstore_sales`
GROUP BY `Segment`
ORDER BY total_sales DESC;

-- 10. Shipping mode analysis
SELECT `Ship Mode`,
       COUNT(DISTINCT `Order ID`) AS unique_orders,
       ROUND(AVG(DATEDIFF(
         STR_TO_DATE(`Ship Date`, '%d-%m-%Y'),
         STR_TO_DATE(`Order Date`, '%d-%m-%Y')
       )), 2) AS avg_shipping_days,
       ROUND(SUM(`Sales`), 2) AS total_sales,
       ROUND(SUM(`Profit`), 2) AS total_profit
FROM `superstore_sales`
GROUP BY `Ship Mode`
ORDER BY unique_orders DESC;

-- 11. Discount analysis
SELECT `Discount`,
       COUNT(*) AS line_items,
       ROUND(SUM(`Sales`), 2) AS total_sales,
       ROUND(SUM(`Profit`), 2) AS total_profit,
       ROUND(AVG(`Profit`), 2) AS avg_profit_per_line
FROM `superstore_sales`
GROUP BY `Discount`
ORDER BY `Discount`;

-- 12. Product performance: top 10 by profit
SELECT `Product ID`, `Product Name`,
       ROUND(SUM(`Sales`), 2) AS total_sales,
       ROUND(SUM(`Profit`), 2) AS total_profit,
       SUM(`Quantity`) AS units_sold
FROM `superstore_sales`
GROUP BY `Product ID`, `Product Name`
ORDER BY total_profit DESC
LIMIT 10;

-- 13. Products with the lowest total profit
SELECT `Product ID`, `Product Name`,
       ROUND(SUM(`Sales`), 2) AS total_sales,
       ROUND(SUM(`Profit`), 2) AS total_profit,
       SUM(`Quantity`) AS units_sold
FROM `superstore_sales`
GROUP BY `Product ID`, `Product Name`
ORDER BY total_profit ASC
LIMIT 10;

-- 14. City performance
SELECT `City`, `State`, `Region`,
       ROUND(SUM(`Sales`), 2) AS total_sales,
       ROUND(SUM(`Profit`), 2) AS total_profit
FROM `superstore_sales`
GROUP BY `City`, `State`, `Region`
ORDER BY total_sales DESC
LIMIT 20;

-- 15. Order vs ship date quality check
SELECT COUNT(*) AS rows_with_ship_before_order
FROM `superstore_sales`
WHERE STR_TO_DATE(`Ship Date`, '%d-%m-%Y') < STR_TO_DATE(`Order Date`, '%d-%m-%Y');

-- 16. Line items with negative profit
SELECT `Order ID`, `Product ID`, `Product Name`, `Category`, `Sub-Category`,
       `Sales`, `Discount`, `Profit`
FROM `superstore_sales`
WHERE `Profit` < 0
ORDER BY `Profit` ASC
LIMIT 50;

-- 17. Dashboard-ready KPI summary
SELECT
  COUNT(*) AS line_items,
  COUNT(DISTINCT `Order ID`) AS unique_orders,
  COUNT(DISTINCT `Customer ID`) AS unique_customers,
  ROUND(SUM(`Sales`), 2) AS total_sales,
  ROUND(SUM(`Profit`), 2) AS total_profit,
  SUM(`Quantity`) AS units_sold,
  ROUND(AVG(`Discount`), 3) AS average_discount,
  ROUND(100 * SUM(`Profit`) / NULLIF(SUM(`Sales`), 0), 2) AS profit_margin_pct
FROM `superstore_sales`;
