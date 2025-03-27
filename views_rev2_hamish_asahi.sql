-- Student Number(s):  10655230 & 10637271
-- Student Name(s):    Asahi Smith & Hamish Christie

USE store;
GO

/*	Order View (2 marks)
	Create a view that selects the following details of all orders (use column aliases as appropriate):
	 • All of the columns from the order table
	 • The customer’s first and last name concatenated into a full name (e.g. “John Smith”)
	 • The billing address and the delivery address
*/

-- Write your Order View here


CREATE VIEW Order_View AS
SELECT
	o.*,
	CONCAT(c.FirstName, ' ', c.LastName) AS 'Customer Name',
	ba.AddressDetail AS 'Billing Address',
	da.AddressDetail AS 'Delivery Address'
	
FROM
	Cust_Order AS o
	JOIN Customer AS c ON o.CustomerID = c.CustomerID
	JOIN Cust_Address AS ba ON o.BillingAddress = ba.AddressID
	JOIN Cust_Address AS da ON o.DeliveryAddress = da.AddressID

GO

/*	Item */

/*	Item View (3 marks)
	Create a view that selects the following details of all items (use column aliases as appropriate):
	 • All of the columns from the item table
	 • The “profit” made from selling the item (item price minus item cost)
	 • Details of the item’s primary supplier concatenated into “Name (phone, URL)” format, e.g. “Deal Express (+86 591 613 8356, http://dealexpress.com.cn/)”
	 • Details of the item’s secondary supplier in the same format, or “N/A” if the item does not have a secondary supplier
*/

-- Write your Item View here
CREATE VIEW  Item_View AS
SELECT
	i.*,
	(i.price - i.cost) AS 'Profit',
	CONCAT(ps.BusinessName, ' (', ps.PhoneNum, ', ', ps.WebsiteURL, ')') AS 'Primary Supplier Details',
	CASE
		WHEN ss.SupplierID IS NULL THEN 'N/A'
		ELSE CONCAT (ss.BusinessName, ' (', ss.PhoneNum, ', ', ss.WebsiteURL, ')') 
		END AS 'Secondary Supplier Details'

FROM 
	Item AS i

	JOIN Supplier AS ps ON i.PrimarySupplierID = ps.SupplierID
	LEFT JOIN Supplier AS ss ON i.SecondarySupplierID = ss.SupplierID;

GO

--	If you wish to create additional views to use in the queries which follow, include them in this file.


