1-Average order payment, Count of orders for the customers. 

select [customer_id] ,count([order_id]) as Num_cst_order, avg([payment_value]) as Average_order_payment

from [dbo].[olist_order_payments_dataset] join [dbo].[olist_customers_dataset]

on [customer_id] = [customer_id]

group by [customer_id] 

=============================================================================
2-Count purchased in Jan-2018 with 5 Review score.

select count(o.[order_id]) as Num_orders 

from [dbo].[olist_orders_dataset] o join [dbo].[olist_order_reviews_dataset] r
on o.[order_id] = r.[order_id]

where format([order_purchase_timestamp],'MMM-yyy') = 'jan-2018' and [review_score] = 5

=================================================================================================
3-Customer purchase trend Year-on-Year.

select count( [order_id]) , format([order_purchase_timestamp],'yyy') as year_

from [dbo].[olist_orders_dataset]

group by format([order_purchase_timestamp],'yyy')

order by format([order_purchase_timestamp],'yyy') desc

==================================================================================================
Average of days between order date and delivery date.

select avg(Datediff(day,cast([order_purchase_timestamp]as date),cast([order_delivered_customer_date]as date))) as Avg_order_delivered_day

from [dbo].[olist_orders_dataset]

==================================================================================================
5-Top 5 Cities with highest revenue from 2016 to 2018.

select top 5 [customer_city] ,sum([payment_value]) as total_rev

from  [dbo].[olist_customers_dataset] c join [dbo].[olist_orders_dataset] o

on c.[customer_id] = o.[customer_id]

join [dbo].[olist_order_payments_dataset] p

on o.[order_id] =p.[order_id]

where format([order_delivered_customer_date],'yyy') between 2016 and 2018

group by [customer_city]

order by sum([payment_value]) desc

==================================================================================================
6-In year 2018, flag each seller as (below target – within target – above target)  based on no of sold items and revenue.

select [seller_id], count(o.[order_id]) as Num_sold_items ,

case when  sum([payment_value]) < 2000 then 'below target'
     when sum([payment_value]) between 2000 and 3000 then 'within target'
	 when sum([payment_value])> 3000 then 'above target' end
     as TOT_Revenue

from [dbo].[olist_order_items_dataset] oi  join [dbo].[olist_order_payments_dataset] op

on op.[order_id] = oi.[order_id] 

join [dbo].[olist_orders_dataset] o

on op.[order_id] = o.[order_id]

where format([order_purchase_timestamp],'yyy')=2018

group by [seller_id]

order by count(o.[order_id]),sum([payment_value]) desc

==================================================================================================
8-SP to get Top N Products sold per each seller, the SP will take N , OrderStartDate, OrderEndDate.

Alter PROCEDURE Top_N_Products_sold_per_seller
	@N int, 
	@OrderStartDate DATE,
	@OrderEndDate DATE

AS
BEGIN
	select top (@N) [seller_id], p.[product_id],p.[product_category_name], count([order_item_id]) as total_Num_sold

	from [dbo].[olist_order_items_dataset] oi join [dbo].[olist_orders_dataset] o
	on oi.[order_id] = o.[order_id]
	JOIN [dbo].[olist_products_dataset] P
	ON P.[product_id]=oi.[product_id]

	WHERE format(cast([order_delivered_customer_date] as date),'yyy') between (@OrderStartDate) and (@OrderEndDate)

	group by [seller_id], p.[product_id],p.[product_category_name]

	order by count([order_item_id]) desc

END
GO

Exec [dbo].[Top_N_Products_sold_per_seller] @n=2 ,@OrderStartDate='2016-01-01' ,@OrderEndDate='2016-01-01'

