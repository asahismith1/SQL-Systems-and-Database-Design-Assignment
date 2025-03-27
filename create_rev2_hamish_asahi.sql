-- Student Number(s):  10655230 & 10637271
-- Student Name(s): Asahi Smith & Hamish Christie

/*	Database Creation & Population Script (6 marks)
	Write a script to create the database you designed in Task 1 (incorporating any changes you have made since then).  
	Give your columns the same data types, properties and constraINTs specified in your data dictionary, and name your tables and columns consistently.  
	Include any suitable default values and any necessary/appropriate CHECK or UNIQUE constraINTs.

	Make sure this script can be run multiple times without resulting in any errors (hINT: drop the database if it exists before trying to create it).
	Adapt the code at the start of the “company.sql” file (Module 5) to implement this.  

	See the brief for further information. 
*/
 

-- Write your creation script here

IF DB_ID('store') IS NOT NULL             
	BEGIN
		PRINT 'Database exists - dropping.';
		
		USE master;		
		ALTER DATABASE Store SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		
		DROP DATABASE Store;
	END

GO
PRINT 'Creating database.';

CREATE DATABASE store;

GO

USE store;

GO

CREATE TABLE Customer( 
	CustomerID INT NOT NULL PRIMARY KEY IDENTITY,
	LastName VARCHAR(64) NOT NULL,
	FirstName VARCHAR(64) NOT NULL,
	Cust_Password VARCHAR(64) NOT NULL,
	Email VARCHAR(128) NOT NULL UNIQUE,
	Referrer INT NULL FOREIGN KEY REFERENCES Customer(CustomerID),
	Newsletter CHAR(1) NULL CHECK (Newsletter IN ('Y','N')) DEFAULT 'Y',
	CHECK (CustomerID != Referrer)
)

CREATE TABLE Cust_Address(
	AddressID INT NOT NULL PRIMARY KEY IDENTITY,
	AddressName VARCHAR(64) NULL,
	AddressDetail VARCHAR (256) NOT NULL,
	CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customer(CustomerID)
)

CREATE TABLE Cust_Order(
	InvoiceID INT NOT NULL PRIMARY KEY IDENTITY,
	InvoiceDateTime SMALLDATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	DeliveryAddress INT NOT NULL FOREIGN KEY REFERENCES Cust_Address(AddressID),
	BillingAddress INT NOT NULL FOREIGN KEY REFERENCES Cust_Address(AddressID),
	CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customer(CustomerID)
)

CREATE TABLE Supplier(
	SupplierID SMALLINT NOT NULL PRIMARY KEY IDENTITY,
	BusinessName VARCHAR(64),
	PhoneNum VARCHAR(20),
	WebsiteURL VARCHAR(128)
)

CREATE TABLE Item(
	ItemID SMALLINT NOT NULL PRIMARY KEY IDENTITY,
	ItemName VARCHAR(64) NOT NULL,
	ItemDescription VARCHAR(256) NOT NULL,
	Price MONEY NOT NULL,
	Cost MONEY NOT NULL,
	Stock SMALLINT NOT NULL,
	PrimarySupplierID SMALLINT NOT NULL FOREIGN KEY REFERENCES Supplier(SupplierID),
	SecondarySupplierID SMALLINT NULL FOREIGN KEY REFERENCES Supplier(SupplierID),
	CHECK (SecondarySupplierID != PrimarySupplierID)

)

CREATE TABLE OrderedItem(
	Quantity TINYINT NOT NULL CHECK (Quantity > 0),
	InvoiceID INT NOT NULL FOREIGN KEY REFERENCES Cust_Order(InvoiceID),
	ItemID SMALLINT NOT NULL FOREIGN KEY REFERENCES Item(ItemID),
	PRIMARY KEY (InvoiceID, ItemID)
)

CREATE TABLE Category(
	CategoryID TINYINT NOT NULL PRIMARY KEY IDENTITY,
	CategoryName VARCHAR(64) NOT NULL UNIQUE
)

CREATE TABLE ItemCategory(
	ItemID SMALLINT NOT NULL FOREIGN KEY REFERENCES Item(ItemID),
	CategoryID TINYINT NOT NULL FOREIGN KEY REFERENCES Category(CategoryID)
)

CREATE TABLE NewsletterCategory(
	Newsletter CHAR(1) NULL,
	CustomerID INT NOT NULL FOREIGN KEY REFERENCES Customer(CustomerID),
	CategoryID TINYINT NOT NULL FOREIGN KEY REFERENCES Category(CategoryID)
	PRIMARY KEY (CustomerID, CategoryID)
)










/*	Database Population Statements
	Following the SQL statements to create your database and its tables, you must include statements to populate the database with sufficient test data.
	You are only required to populate the database with enough data to make sure that all views and queries return meaningful results.
	
	You can start working on your views and queries and write INSERT statements as needed for testing as you go.
	The final create.sql should be able to create your database and populate it with enough data to make sure that all views and queries return meaningful results.

	Data has been provided for some of the tables.
	Adapt the INSERT statements as needed, and write your own INSERT statements for the remaining tables.
*/


INSERT INTO customer (LastName, FirstName, Cust_Password, Email, Referrer, Newsletter)
VALUES	('Smith', 'Asahi', 'password123', 'asahismith@gmail.com', NULL, 'Y'),
		('Christie', 'Hamish', 'rav4', 'hamishchristie@gmail.com', '1', NULL),
		('Tang', 'Isaac', 'skateboard', 'isaactang@gmail.com', '2', 'N'),
		('Balling', 'Alex', 'buzzcut', 'alexballing@gmail.com', '2', 'Y');


INSERT INTO Cust_Address (AddressName, AddressDetail, CustomerID)
VALUES	('Home', '123 Chair Street', '1'),
		(NULL, '463 Thumb Drive', '2'), 
		('PO BOX', '983 Teacher Ave', '3'),
		('My house', '768 Backpack Place', '4');

INSERT INTO Cust_Order (InvoiceDateTime, DeliveryAddress, BillingAddress, CustomerID)
VALUES	('2022-07-23 13:52:23', '1', '1', '1'),
		('2023-08-04 11:13:57', '1', '1', '2'),
		('2024-08-13 19:43:10', '2', '2', '3'),
		('2024-08-16 10:32:10', '2', '2', '3'),
		('2024-09-01 23:23:23', '3', '3', '3');






/*	The following statement inserts the details of 4 suppliers INTo a table named "supplier".
    It specifies values for columns named "business_name", "phone" and "website".
	Supplier ID numbers are not specified since it is assumed that an auto-incrementing INTeger is being used.
	If required, change the table and column names to match those in your database.
*/

INSERT INTO supplier (BusinessName, PhoneNum, WebsiteURL)
VALUES	('Techsupply Co.', '+61 08 9201 5475', 'http://www.techsupplyco.com'),		-- Supplier 1
		('Gadget World',   '+61 06 7544 4512', 'http://buy.gadgetworld.com.au/'),	-- Supplier 2
		('ElectroGoods',   '+86 258 765 4321', 'http://www.electrogoods.com'),		-- Supplier 3
		('Deal Express',   '+86 591 613 8356', 'http://dealexpress.com.cn/');		-- Supplier 4



/*	The following statement inserts the details of 20 items INTo a table named "item".
    It specifies values for columns named "item_name", "description", "price" (how much the store sells it for), "cost" (how much it costs the store to buy), "stock", "primary_supplier_id" and "secondary_supplier_id".
	Item ID numbers are not specified since it is assumed that an auto-incrementing INTeger is being used.
	If required, change the table and column names to match those in your database.
*/

INSERT INTO item (ItemName, ItemDescription, Price, Cost, Stock, PrimarySupplierID, SecondarySupplierID) 
VALUES	('Ergonomic Wireless Mouse', 'A sleek, ergonomic mouse with a comfortable grip and precise tracking, complete with a USB receiver.', 29.99, 12.00, 100, 1, 2),						-- Item 1
		('RGB Mechanical Keyboard', 'A mechanical keyboard featuring customizable RGB backlighting and durable key switches for a premium typing experience.', 79.99, 43.00, 50, 2, 1),		-- Item 2
		('27-Inch HD Monitor', 'A stunning 27-inch Full HD monitor with vibrant colors and crisp visuals, perfect for both work and play.', 199.99, 150.00, 75, 3, 4),						-- Item 3
		('Adjustable Aluminum Laptop Stand', 'A lightweight and sturdy laptop stand that improves posture and cooling, adjustable to various angles.', 49.99, 30.00, 20, 4, NULL),			-- Item 4
		('Noise Cancelling Over-Ear Headphones', 'Wireless over-ear headphones with advanced noise cancellation technology, delivering immersive sound quality.', 149.99, 80.00, 10, 1, 3),	-- Item 5
		('Portable Charger with Fast Charging', 'A compact 10000mAh power bank with fast charging capabilities to keep your devices powered on the go.', 39.99, 20.00, 150, 2, 4),			-- Item 6
		('Portable Bluetooth Speaker', 'A small yet powerful Bluetooth speaker that delivers deep bass and clear sound, perfect for any occasion.', 59.99, 35.00, 200, 3, 2),				-- Item 7
		('Smart Fitness Tracker Smartwatch', 'A sleek smartwatch with fitness tracking, heart rate monitoring, and smart notifications to keep you connected.', 129.99, 90.00, 120, 4, 3),	-- Item 8
		('1TB USB 3.0 External Hard Drive', 'A high-speed external hard drive with 1TB of storage, ideal for backing up and transferring large files.', 79.99, 50.00, 90, 1, 4),			-- Item 9
		('1080p HD Webcam with Microphone', 'A high-definition webcam with a built-in microphone, perfect for video calls and streaming.', 49.99, 25.00, 80, 2, NULL),						-- Item 10
		('6-in-1 USB-C Hub with HDMI', 'A versatile USB-C hub with multiple ports, including HDMI and Ethernet, to expand your laptop’s connectivity.', 69.99, 40.00, 60, 3, NULL),			-- Item 11
		('High Precision Gaming Mouse', 'A high-performance gaming mouse with adjustable DPI settings and RGB lighting for an enhanced gaming experience.', 59.99, 35.00, 30, 4, NULL),		-- Item 12
		('Adjustable Tablet Stand', 'A durable tablet stand that can be adjusted to various viewing angles, making it perfect for desk use.', 29.99, 15.00, 40, 1, 3),						-- Item 13
		('Fast Wireless Charging Pad', 'A sleek and fast wireless charger that quickly powers up your Qi-compatible devices.', 39.99, 25.00, 70, 2, 3),										-- Item 14
		('WiFi-Enabled Smart LED Light Bulb', 'A smart LED light bulb that can be controlled via WiFi, offering a range of colors and brightness levels.', 19.99, 14.00, 110, 3, 1),		-- Item 15
		('Noise Isolating In-Ear Earbuds', 'Compact in-ear earbuds with excellent noise isolation and superior sound quality.', 29.99, 15.00, 55, 4, 2),									-- Item 16
		('Water-Resistant Laptop Backpack', 'A stylish and water-resistant laptop backpack with multiple compartments to keep your belongings organized.', 69.99, 45.00, 65, 1, 4),			-- Item 17
		('Compact Wireless Keyboard with Touchpad', 'A slim and portable wireless keyboard with an INTegrated touchpad, perfect for on-the-go use.', 49.99, 15.00, 85, 2, NULL),			-- Item 18
		('WiFi-Enabled Smart Plug', 'A smart plug that allows you to control your appliances remotely via a smartphone app or voice commands.', 24.99, 15.00, 95, 3, NULL),					-- Item 19
		('Wireless Bluetooth Headset with Mic', 'A comfortable wireless headset with a built-in microphone, offering clear audio for calls and music.', 79.99, 30.00, 25, 4, NULL);			-- Item 20



/*	The following statement inserts the details of 6 categories INTo a table named "category".
    It specifies values for a column named "category_name".
	Category ID numbers are not specified since it is assumed that an auto-incrementing INTeger is being used.
	If required, change the table and column names to match those in your database.
*/

INSERT INTO category (CategoryName) 
VALUES	('Computers & Accessories'),	-- Category 1
		('Mobile & Tablets'),			-- Category 2
		('Audio & Headphones'),			-- Category 3
		('Home & Office'),				-- Category 4
		('Gaming'),						-- Category 5
		('Optical Media');				-- Category 6 (empty category)


		
/*	The following statement inserts data INTo a table named "category_item" to place the items INTo the categories as indicated above.
    It specifies values for columns named "item_id" and "category_id".
	If required, change the table and column names to match those in your database.
*/

INSERT INTO ItemCategory(ItemID, CategoryID) 
VALUES	(1, 1),						-- Ergonomic Wireless Mouse - Computers & Accessories
		(2, 1),						-- RGB Mechanical Keyboard - Computers & Accessories
		(3, 1),						-- 27-Inch HD Monitor - Computers & Accessories
		(4, 1),						-- Adjustable Aluminum Laptop Stand - Computers & Accessories
		(5, 3), (5, 4),				-- Noise Cancelling Over-Ear Headphones - Audio & Headphones, Home & Office
		(6, 2), (6, 4),				-- Portable Charger with Fast Charging - Mobile & Tablets, Home & Office
		(7, 3), (7, 4),				-- Portable Bluetooth Speaker - Audio & Headphones, Home & Office
		(8, 2),						-- Smart Fitness Tracker Smartwatch - Mobile & Tablets
		(9, 1),						-- 1TB USB 3.0 External Hard Drive - Computers & Accessories
		(10, 1),					-- 1080p HD Webcam with Microphone - Computers & Accessories
		(11, 1),					-- 6-in-1 USB-C Hub with HDMI - Computers & Accessories
		(12, 1), (12, 5),			-- High Precision Gaming Mouse - Computers & Accessories, Gaming
		(13, 1), (13, 2),			-- Adjustable Tablet Stand - Computers & Accessories, Mobile & Tablets
		(14, 2),					-- Fast Wireless Charging Pad - Mobile & Tablets
		(15, 4),					-- WiFi-Enabled Smart LED Light Bulb - Home & Office
		(16, 3), (16, 2),			-- Noise Isolating In-Ear Earbuds - Audio & Headphones, Mobile & Tablets
		(17, 4), (17, 2),			-- Water-Resistant Laptop Backpack - Home & Office, Mobile & Tablets
		(18, 1),					-- Compact Wireless Keyboard with Touchpad - Computers & Accessories
		(19, 4),					-- WiFi-Enabled Smart Plug - Home & Office
		(20, 3), (20, 2), (20, 5);	-- Wireless Bluetooth Headset with Mic - Audio & Headphones, Mobile & Tablets, Gaming



-- Write your INSERT statements for the remaining tables here

INSERT INTO OrderedItem (Quantity, InvoiceID, ItemID)
VALUES	(32, 1, 1),
		(1, 1, 2),
		(23, 1, 3),
		(56, 2, 1),
		(12, 2, 2),
		(18, 3, 6),
		(95, 3, 3),
		(24, 3, 2),
		(1, 4, 5),
		(10, 4, 8);

INSERT INTO NewsletterCategory (Newsletter, CustomerID, CategoryID)
VALUES	('Y', 1, 2),
		(NULL, 2, 3),
		('N', 3, 2),
		('Y', 4, 1);

