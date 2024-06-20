/*

--(Column names & Details) 

order_details_id------>Unique ID of an item in an order
order_id-------------->ID of an order
order_date------------>Date an order was put in (MM/DD/YY)
order_time------------>Time an order was put in (HH:MM:SS AM/PM)
item_id--------------->Matches the menu_item_id in the menu_items table
menu_item_id---------->Unique ID of a menu item
item_name------------->Name of a menu item
category-------------->Category or type of cuisine of the menu item
price----------------->Price of the menu item (US Dollars $)

*/

select * from order_details

------SQL query and DAX formulae(Commented)---------------

----------------------Total Revenue------------------------------------------------------------------------------------

select sum(price) as Total_Revenue
from order_details

----------------------Average Order Value-------------------------------------------------------------------------------

select avg(price) / count(DISTINCT order_details_id) as avg_order_value
from order_details

/*  DAX

AverageOrderValue = 
AVERAGEX(
    SUMMARIZE(
        'public order_details',
        'public order_details'[order_id],
        "OrderTotal", SUM('public order_details'[price])
    ),
    [OrderTotal]
)

*/


------------------------Total items sold-------------------------------------------------------------------------------

select count(category)
from order_details

------------------------Daily trends for total orders diff iteams------------------------------------------------------

SELECT 
    to_char(order_date, 'Day') as order_day,
    count(DISTINCT order_details_id) as orders
FROM 
    order_details
GROUP BY 
    to_char(order_date, 'Day'),
    date_part('dow', order_date)
ORDER BY 
    date_part('dow', order_date)

/*

Orders =
CALCULATE (
DISTINCTCOUNT ( 'public order_details'[order_details_id] ),
FILTER (
'public order_details',
FORMAT ( 'public order_details'[order_date], "dddd" ) = 'public order_details'[OrderDay]
)
)

OrderDay = FORMAT ( 'public order_details'[order_date], "dddd" )
*/

---------------------Monthly trends for total orders diff iteams----------------------------------------------------------

SELECT 
    to_char(order_date, 'Month') AS order_month,
    count(DISTINCT order_details_id) AS orders,
    EXTRACT(MONTH FROM order_date) AS month_num
FROM 
    order_details
GROUP BY 
    to_char(order_date, 'Month'), 
    EXTRACT(MONTH FROM order_date)
ORDER BY 
    month_num;

/*
MonthlyOrders = 
CALCULATE (
    DISTINCTCOUNT ( 'public order_details'[order_details_id] ),
    FILTER (
        'public order_details',
        FORMAT ( 'public order_details'[order_date], "MMMM YYYY" ) = 'public order_details'[OrderMonth]
    )
)

OrderMonth = FORMAT ( 'public order_details'[order_date], "MMMM YYYY" )

*/



----------------------% of Sales by item Category-------------------------------------------------------------------

SELECT
    item_name,
    ROUND(SUM(price) *100 / (SELECT SUM(price) FROM order_details ),2) AS percent_of_Sales 

from order_details
group by item_name
order by percent_of_Sales DESC

/*

Total_Sales_All_Items = CALCULATE(SUM('public order_details'[price]), ALL('public order_details'))

Percentage_of_Sales = 
DIVIDE (
    'public order_details'[price],
    CALCULATE(SUM('public order_details'[price]), ALL('public order_details'))
)

*/

-------------------------Top 5 Best Sellers by Revenue, Total Quantity & Total Orders---------------------------------

select 
      item_name,
      sum(price) as total_revenue

from order_details
group by item_name
order by total_revenue DESC
LIMIT 5

/*
Percentage_of_Sales = 
DIVIDE(
    'public order_details'[price],
    CALCULATE(SUM('public order_details'[price]), ALL('public order_details'))
)

Item_Rank_highest = 
RANKX(
    ALL('public order_details'[item_name]),
    CALCULATE(SUM('public order_details'[Percentage_of_Sales])),
    ,
    DESC,
    DENSE
)


drag the Item_Rank_Lowest measure to the "Tooltips" area.
Set the filter condition to Item_Rank_Lowest is less than or equal to 5.

*/

-------------------5 lowest Sellers by Revenue, Total Quantity & Total Orders-------------------------------------------

select 
      item_name,
      sum(price) as total_revenue

from order_details
group by item_name
order by total_revenue ASC
LIMIT 5

/*

Item_Rank_Lowest = 
RANKX(
    ALL('public order_details'[item_name]),
    CALCULATE(SUM('public order_details'[Percentage_of_Sales])),
    ,
    ASC,
    DENSE
)

Set the filter to show items where Item_Rank_Lowest is less than or equal to 5.

*/

--------------customers each day--------------------------------------------------------------------------------------

SELECT
    DATE_TRUNC('Day', order_date) AS order_day,
    COUNT(DISTINCT order_id) AS num_customers
FROM
    order_details
GROUP BY
    DATE_TRUNC('Day', order_date)
ORDER BY
    order_day;

/*

Order_Month_Year = FORMAT('public order_details'[order_date], "MMM YYYY")

Num_Customers_Monthly = 
CALCULATE(
    COUNTROWS(DISTINCT('public order_details'[order_id])),
    ALLEXCEPT('public order_details', 'public order_details'[Order_Month_Year])
)

--Clustered bar chart

*/
------------------------Busiest hours----------------------------------------------------------------------------------

SELECT
    EXTRACT(HOUR FROM order_time) AS hour_of_day,
    COUNT(DISTINCT order_id) AS num_customers
FROM
    order_details
GROUP BY
    EXTRACT(HOUR FROM order_time)
ORDER BY
   EXTRACT(HOUR FROM order_time),  num_customers ASC;

/*

Hour_of_Day = HOUR('public order_details'[order_time])

Num_Customers_Per_Hour = 
CALCULATE(
    COUNTROWS(DISTINCT('public order_details'[order_id])),
    ALLEXCEPT('public order_details', 'public order_details'[Hour_of_Day])
)

*/


------------------------------price distribution-------------------------------------------------------------------

Price Bin = 
SWITCH(
    TRUE(),
    'public order_details'[price] <= 10, "0-10",
    'public order_details'[price] <= 20, "11-20",
    'public order_details'[price] <= 30, "21-30",
    'public order_details'[price] <= 40, "31-40",
    'public order_details'[price] <= 50, "41-50",
    'public order_details'[price] <= 60, "51-60",
    'public order_details'[price] <= 70, "61-70",
    'public order_details'[price] <= 80, "71-80",
    'public order_details'[price] <= 90, "81-90",
    'public order_details'[price] <= 100, "91-100",
    "100+"
)


Order Count = COUNTROWS('Table')

--clustered column chart

--------------------------------------------------------------------------------------------------------------------------



