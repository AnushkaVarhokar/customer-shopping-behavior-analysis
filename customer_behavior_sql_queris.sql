SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

SELECT *
FROM customer_behavior
LIMIT 5;

-- Check the database
Select * From customer_behavior limit(20);

-- Check Table Columns & Data Types
Select column_name, data_type From Information_schema.columns
Where table_name = 'customer_behavior';

--information_schema.columns
--This is a system table in PostgreSQL that stores metadata about tables.

--Total Unique Customer 
Select count(Distinct customer_id) From Customer_behavior;

-- Gender Didstibution
select gender, count(*) As total_customers From customer_behavior
group by gender;

-- Age Group Analysis
select age_group, count(*) As total_customers From customer_behavior
group by age_group order by total_customers DESC;

-- Product Category Performance
select category, count(*) As total_orders, Sum(purchase_amount) as revenue
From customer_behavior group by category order by revenue DESC;

-- loaction Analysis
select location, count(*) as orders, Sum(purchase_amount) as revenue
From customer_behavior
as revenue group by location order by revenue DESC;

-- which category has the highest revenue in each season
select season, category, Sum(purchase_amount) as total_revenue
From customer_behavior group by season, category
order by season, total_revenue DESC;

--Which customers used a discount but still spent more than the average purchase amount?
 select customer_id, discount_applied, purchase_amount
 From customer_behavior Where discount_applied = 'Yes'
 And purchase_amount > (select avg(purchase_amount)
 From customer_behavior);

 --Which are the top 5 products with the highest average review rating?
 select item_purchased, avg(review_rating) As avg_rating
 From customer_behavior Group by item_purchased Order by avg_rating DESC limit 5;

 --Compare average purchase amounts between Standard and Express Shipping?
 select shipping_type, avg(purchase_amount) as avg_purchase
 From customer_behavior
 where shipping_type In('Standard', 'Express') 
 Group by shipping_type;

 --Do subscribed customers spend more?
 select subscription_status, avg(purchase_amount) as avg_amount,
 Sum(purchase_amount) as total_revenue
 From customer_behavior
 Group By subscription_status;

 --Top 5 products with highest percentage of discount purchases
 Select item_purchased,round(Count(case when discount_applied = 'Yes' THEN 1 END) * 100.0
       / COUNT(*), 2
       ) AS discount_percentage
FROM customer_behavior
GROUP BY item_purchased
ORDER BY discount_percentage DESC
LIMIT 5;

--Segment customers into New, Returning, and Loyal
Select customer_id,
previous_purchases,
case
When previous_purchases <= 1 THEN 'New'
When previous_purchases BETWEEN 2 AND 5 THEN 'Returning'
Else 'Loyal'
End as customer_segment
From customer_behavior;

--Top 3 most purchased products within each category
With product_count As (
Select category,
item_purchased,
Count(*) As total_purchases,
Rank() Over (
Partition By category
Order by count(*) Desc) AS rank_num
From customer_behavior
Group by category, item_purchased)
Select category,
item_purchased,
total_purchases
From product_count
Where rank_num <= 3;

--Are repeat buyers likely to subscribed?

Select
Case
When previous_purchases > 5 THEN 'Repeat Buyer'
Else 'Non Repeat Buyer'
End as buyer_type,
subscription_status,
Count(*) as total_customers
From customer_behavior
Group By buyer_type, subscription_status;
 