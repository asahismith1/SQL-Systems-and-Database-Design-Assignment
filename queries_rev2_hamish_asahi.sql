-- Student Number(s):	10655230 & 10637271
-- Student Name(s):		Asahi Smith & Hamish Christie

USE store;

/*	Query 1 – Item Search (2 marks)
	Write a query that selects the item ID, item name and profit (item price minus item cost) of any items 
	that have a profit of at least $20 and include the words “portable” or “compact” in the item name.  
	Order the results by profit, in descending order.
*/

-- Write Query 1 here
SELECT
	i.ItemID,
	i.ItemName,
	(i.price - i.cost) AS 'Profit'
FROM
	Item AS i
WHERE
	((i.price - i.cost) >= 20)
	AND (i.ItemName LIKE '%Portable%' OR i.ItemName LIKE '%Compact%')
	
ORDER BY
Profit DESC;
GO

-- End Query 1 here

/*	Query 2 – Unpopular Items (2 marks)
	Write a query that selects the item ID, item name, stock and primary supplier details concatenated into “name (phone, website)” format 
	of any items that have never been purchased, i.e. items that do not appear in the ordered item table.  
	Order the results by the stock in descending order.
*/

-- Write Query 2 here
SELECT 
	iv.ItemID,
	iv.ItemName,
	iv.Stock,
	CONCAT (ps.BusinessName, ' (', ps.PhoneNum, ', ', ps.WebsiteURL, ')') AS 'Primary Supplier Details'

FROM Item_View AS iv 
JOIN Supplier AS ps ON iv.PrimarySupplierID = ps.SupplierID
LEFT JOIN
    OrderedItem AS oi ON iv.ItemID = oi.ItemID
WHERE
    oi.ItemID IS NULL
ORDER BY
    iv.Stock DESC;

-- End Query 2 here

/*	Query 3 – Category Interest Summary (2 marks)
	Write a query that concatenates information about categories and customer interests into a single column with an alias of “interest_level”, as pictured in the brief.  

	Ensure that category names are in uppercase, and that categories with nobody interested in them are included and correctly counted.  
	Order the results by the number of interested customers in descending order, followed by the category name in ascending order.
*/

-- Write Query 3 here
SELECT 
	/*UPPER(c.CategoryName) AS Category_Name,
	COUNT(nc.CustomerID) AS Int_Customers,
	CONCAT(UPPER(c.CategoryName), ' - ', COUNT(nc.CustomerID)) AS interest_level*/
	CONCAT(COUNT(nc.CustomerID), ' customer(s) interested in the ', UPPER(c.CategoryName), ' category') AS interest_level
FROM 
	Category AS c
LEFT JOIN NewsletterCategory AS nc ON c.CategoryID = nc.CategoryID
GROUP BY c.CategoryID, c.CategoryName
	ORDER BY 
    COUNT(nc.CustomerID) DESC, 
    c.CategoryName ASC;


-- End Query 3 here

/*	Query 4 – Order Timeline (3 marks)
	Write a query that selects the number of orders, grouped per year and month.
	Each row of the results should include the year, the name of the month and the number of orders placed in that month of that year.
	Order the results chronologically by year then month, and ensure that you have orders across different years and months in your sample data.
*/

-- Write Query 4 here
SELECT 
    YEAR(co.InvoiceDateTime) AS Order_Year,
	DATENAME(month, CONCAT(YEAR(co.InvoiceDateTime), '-', MONTH(co.InvoiceDateTime),'-01')) AS Month_Name,
	/*DATENAME(month, (co.InvoiceDateTime)) AS Month_Name,*/
	COUNT(*) AS Number_of_Orders
FROM 
    Cust_Order AS co
GROUP BY 
    YEAR(co.InvoiceDateTime), MONTH((co.InvoiceDateTime))
ORDER BY 
    Order_Year ASC, 
    MONTH(co.InvoiceDateTime) ASC;


-- End Query 4 here

/*	Query 5 – Top Referrers (3 marks)
	Write a query that selects the customer ID and full name of the top three customers who have referred the most other customers to the store, 
	i.e. the customers whose customer ID appears the most in the referrer column.  Include the number of customers that they have referred in the results.
*/

-- Write Query 5 here
SELECT TOP 3
	c.CustomerID,
	CONCAT(c.FirstName, ' ', c.LastName) AS Customer_Name,
	COUNT (ref.Referrer) AS Referrals 
FROM
	Customer AS c
LEFT JOIN
	Customer AS ref ON c.CustomerID = ref.Referrer
GROUP BY
	c.CustomerID, CONCAT(c.FirstName, ' ', c.LastName)
ORDER BY
	Referrals DESC;



-- End Query 5 here

/*	Query 6 – Items Per Customer (3 marks)
	Write a query that selects the customer ID, customer’s full name and the total number of items they have ordered across all of their orders, 
	taking the quantity of ordered items into account.  Customers who have never placed an order should appear in the results with 0 as their total.  
	Order the results by the total in descending order.
*/

-- Write Query 6 here - Hamish

SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS Full_Name,
    COALESCE(SUM(o.Quantity), 0) AS Total_Ordered
FROM
    Customer AS c
LEFT OUTER JOIN
    Cust_Order AS cord ON c.CustomerID = cord.CustomerID
LEFT OUTER JOIN
    OrderedItem AS o ON cord.InvoiceID = o.InvoiceID
GROUP BY
    c.CustomerID, c.FirstName, c.LastName
ORDER BY
    Total_Ordered DESC;

-- End Query 6 here

/*	Query 7 – Category Statistics (4 marks)
	Write a query that selects the following information about all categories (even those with no items):
	 • The category ID and category name
	 • The number of items in the category
	 • The cost (not the price) of the cheapest and most expensive items in the category
	 • The average profit (price minus cost) of all items in the category, rounded to 2 decimal places
	 • The number of customers interested in the category
*/

-- Write Query 7 here
SELECT 
	c.CategoryID,
	c.CategoryName,
	COUNT(DISTINCT ic.ItemID) AS Number_Of_Items,
	MIN(i.Cost) AS Cheapest_Item,
	MAX(i.Cost) AS Most_Expensive_Item,
	ROUND(AVG(i.Price - i.Cost), 2) AS Average_Item_Profit,
	COUNT(DISTINCT nc.CustomerID) AS Interested_Customers
	
FROM
	Category AS c
LEFT JOIN ItemCategory as ic ON c.CategoryID = ic.CategoryID
LEFT JOIN Item as i ON ic.ItemID = i.ItemID
LEFT JOIN NewsletterCategory AS nc ON c.CategoryID = nc.CategoryID

GROUP BY
	c.CategoryID, c.CategoryName
ORDER BY
	c.CategoryID;


-- End Query 7 here

/*	Query 8 – Customer Spending Summary (4 marks)
	Write a query that selects the ID and full name of all customers, as well as the number of orders they have placed and the total amount they have spent 
	(i.e. the sum of the price of each item in each of their orders, taking quantity into account), rounded to the nearest dollar.  
	Customers who have never placed an order should appear in the results with 0 in number of orders and total amount spent.  
	Order the results by the total amount spent in descending order.
*/

-- Write Query 8 here
SELECT 
	c.CustomerID,
	CONCAT(c.FirstName, ' ', c.LastName) AS Customer_Name,
	COUNT(DISTINCT co.InvoiceID) AS Orders_Placed,
	COALESCE(SUM(oi.Quantity * i.Price), 0) AS Total_Spent
	
FROM 
	Customer AS c
	LEFT JOIN Cust_Order AS co ON c.CustomerID = co.CustomerID
	LEFT JOIN OrderedItem AS oi ON co.InvoiceID = oi.InvoiceID
	LEFT JOIN Item AS i ON oi.ItemID = i.ItemID

GROUP BY
	c.CustomerID, c.FirstName, c.LastName
ORDER BY
	Total_Spent DESC;

-- End Query 8 here

/*	Query 9 – Bulky Orders (4 marks)
	Write a query that selects the order ID, delivery address, order date (not including the time) and number of items of any orders containing more than the average number of items per order.    
	Remember to take the quantity of ordered items into account.  Part of this query will involve determining the average number of items per order.  
	Order the results by the number of items in the order in descending order.
*/

-- Write Query 9 here

SELECT
    o.InvoiceID AS OrderID,
    ca.AddressDetail,
    CAST(co.InvoiceDateTime AS DATE) AS Order_Date,
    SUM(o.Quantity) AS Items_Ordered
FROM
    OrderedItem AS o
    LEFT JOIN Cust_Order AS co ON o.InvoiceID = co.InvoiceID
    LEFT JOIN Cust_Address AS ca ON co.CustomerID = ca.CustomerID
GROUP BY
    o.InvoiceID, ca.AddressDetail, co.InvoiceDateTime
HAVING
    SUM(o.Quantity) > (
        SELECT SUM(oi.Quantity) * 1.0 / COUNT(DISTINCT oi.InvoiceID)
        FROM OrderedItem AS oi
    )
ORDER BY
    Items_Ordered DESC;


-- End Query 9 here