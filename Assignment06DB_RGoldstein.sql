--*************************************************************************--
-- Title: Assignment06
-- Author: RGoldstein
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,RGoldstein,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_RGoldstein')
	 Begin 
	  Alter Database [Assignment06DB_RGoldstein] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_RGoldstein;
	 End
	Create Database Assignment06DB_RGoldstein;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_RGoldstein;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
--First, create the views:

--Go
--Create --Drop
--View vCategories
--As
-- Select [CategoryID],[CategoryName]
-- From [dbo].[Categories];
--Go
--Select * From vCategories

--Go
--Create --Drop 
--View vEmployees
--As
--  Select [EmployeeID],[EmployeeFirstName],[EmployeeLastName],[ManagerID]
--  From [dbo].[Employees];
--Go
--Select * From vEmployees

--Go
--Create --Drop 
--View vInventories
--As
--  Select [InventoryID],[InventoryDate],[EmployeeID],[ProductID],[Count]
--  From [dbo].[Inventories]
--Go
--Select * From vInventories

--Go
--Create --Drop 
--View vProducts
--As
--  Select [ProductID],[ProductName],[CategoryID],[UnitPrice]
--  From [dbo].[Products]
--Go
--Select * From vProducts

--Then, add SchemaBinding to protect view:
Go
Create --Drop
View vCategories
With SCHEMABINDING 
As
 Select [CategoryID],[CategoryName]
 From [dbo].[Categories];
Go

Go
Create --Drop 
View vEmployees
With SCHEMABINDING
As
  Select [EmployeeID],[EmployeeFirstName],[EmployeeLastName],[ManagerID]
  From [dbo].[Employees];
Go

Go
Create --Drop 
View vInventories
With SCHEMABINDING
As
  Select [InventoryID],[InventoryDate],[EmployeeID],[ProductID],[Count]
  From [dbo].[Inventories]
Go

Go
Create --Drop 
View vProducts
With SCHEMABINDING
As
  Select [ProductID],[ProductName],[CategoryID],[UnitPrice]
  From [dbo].[Products]
Go

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On [dbo].[Categories] to Public
Grant Select On [vCategories] to Public;

Deny Select on [dbo].[Employees] to Public
Grant Select on [vEmployees] to Public;

Deny Select on [dbo].[Inventories] to Public
Grant Select on [vInventories] to Public;

Deny Select on [dbo].[Products] to Public
Grant Select on [vProducts] to Public;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00

--Columns needed:[CategoryName],[ProductName],[UnitPrice]
--views needed:[dbo].[vCategories],[dbo].[vProducts]
--Connecting point:[dbo].[Categories].[CategoryID]=[dbo].[Products].[CategoryID]

--Write Select Statement:
--Select [CategoryName],[ProductName],[UnitPrice]
--	From [dbo].[vCategories] As C
--	Join [dbo].[vProducts] As P
--	  On C.[CategoryID]=P.[CategoryID];
--Go

--Order by the Select Statement:

--Select [CategoryName],[ProductName],[UnitPrice]
--	From [dbo].[Categories] As C
--	Join [dbo].[Products] As P
--	  On C.[CategoryID]=P.[CategoryID]
--Order by [CategoryName],[ProductName];
--Go

--Create View
Go
Create --Drop 
View [vProductsbyCategories]
With SCHEMABINDING
As
Select Top 1000000000
		 [CategoryName],[ProductName],[UnitPrice]
	From [dbo].[vCategories] As C
	Inner Join [dbo].[vProducts] As P
	  On C.[CategoryID]=P.[CategoryID]
Order by [CategoryName],[ProductName];
Go

-- Question 4 (10% pts): How can you create a view to show a list of Product names and Inventory Counts on each Inventory Date?
--Columns needed:[ProductName],[Count],[InventoryDate]
--Views needed:[dbo].[vProducts],[dbo].[vInventories]
--Connecting point:[dbo].[Products].[ProductID]=[dbo].[Inventories].[ProductID]

--Write select statement and order the results by the Product, Date, and Count!:
--Select [ProductName],[Count],[InventoryDate]
--From [dbo].[vProducts] As P
--Join [dbo].[vInventories] As I
--  On P.[ProductID]=I.[ProductID]
-- Group by [ProductName],[Count],[InventoryDate]
-- Order by [ProductName],[InventoryDate],[Count];
--Go

--Create View:
Go
Create --Drop 
View [vInventoriesByProductsByDates]
With SCHEMABINDING
As 
	Select Top 1000000000
		[ProductName],[Count],[InventoryDate]
	From [dbo].[vProducts] As P
	Inner Join [dbo].[vInventories] As I
	  On P.[ProductID]=I.[ProductID]
	 Group by [ProductName],[Count],[InventoryDate]
	 Order by [ProductName],[InventoryDate],[Count];
Go

-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--Columns needed:[InventoryDate],[EmployeeFirstName] + ' '[EmployeeLastName] as EmployeeName
--views needed:[dbo].[vInventories],[dbo].[vEmployees]
--Connecting point:[dbo].[Inventories].[EmployeeID]=[dbo].[Employees].[EmployeeID]
--Group by [InventoryDate]

--Write select statement 
--Select [InventoryDate],(E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) as EmployeeName
--From [dbo].[vInventories] as I 
--Join [dbo].[vEmployees] as E
--On I.[EmployeeID]=E.[EmployeeID]
--Group by I.[InventoryDate],(E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) 
--Order by I.[InventoryDate];
--Go

--Create View:
Go
Create --Drop
View [dbo].[vInventoriesByEmployeesByDates]
With SCHEMABINDING
As 
	Select Top 1000000000
		[InventoryDate],(E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) as EmployeeName
	From [dbo].[vInventories] as I 
	Inner Join [dbo].[vEmployees] as E
	 On I.[EmployeeID]=E.[EmployeeID]
	Group by I.[InventoryDate],(E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) 
	Order by I.[InventoryDate];
Go

-- Here are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--Columns needed:  [CategoryName],[ProductName],[InventoryDate],[Count]
--Views needed:[dbo].[vCategories].[CategoryID],[dbo].[vProducts].[CategoryID],[dbo].[vInventories].[ProductID]
--Connecting point:[dbo].[Categories].[CategoryID]=[dbo].[Products].[CategoryID] and [dbo].[Products].[ProductID]=[dbo].[Inventories].[ProductID]
--Order by [CategoryName],[ProductName],[InventoryDate],[Count]

--Create Select statement:
--Select [CategoryName],[ProductName],[InventoryDate],[Count]
--From [dbo].[vCategories] as C
--Join [dbo].[vProducts] as P
--  On C.[CategoryID]=P.[CategoryID]
--Join [dbo].[vInventories] as I
--  On P.[ProductID]=I.[ProductID]
--Order by C.[CategoryName],P.[ProductName],I.[InventoryDate],I.[Count]
--Go

--Create View:
Go
Create --Drop
View [dbo].[vInventoriesByProductsByCategories]
  With SCHEMABINDING
  As
	Select Top 1000000000
	[CategoryName],[ProductName],[InventoryDate],[Count]
	From [dbo].[vCategories] as C
		Inner Join [dbo].[vProducts] as P
		  On C.[CategoryID]=P.[CategoryID]
		Inner Join [dbo].[vInventories] as I
		  On P.[ProductID]=I.[ProductID]
	Order by C.[CategoryName],P.[ProductName],I.[InventoryDate],I.[Count]
	Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--Create Select statement:
--Select [CategoryName],[ProductName],[InventoryDate],[Count], (E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) as EmployeeName
--From [dbo].[vCategories] as C
--	Join [dbo].[vProducts] as P
--	  On C.[CategoryID]=P.[CategoryID]
--	Join [dbo].[vInventories] as I
--	  On P.[ProductID]=I.[ProductID]
--	Join [dbo].[vEmployees] as E
--	  On I.[EmployeeID]=E.[EmployeeID]
--Order by I.[InventoryDate], C.[CategoryName],P.[ProductName],(E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]);
--Go

--Create View:
Go
Create --Drop
View [dbo].[vInventoriesByProductsByEmployees]
  With SCHEMABINDING
  As
	Select Top 1000000000
	[CategoryName],[ProductName],[InventoryDate],[Count], (E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) as EmployeeName
	From [dbo].[vCategories] as C
		Inner Join [dbo].[vProducts] as P
			On C.[CategoryID]=P.[CategoryID]
		Inner Join [dbo].[vInventories] as I
			On P.[ProductID]=I.[ProductID]
		Inner Join [dbo].[vEmployees] as E
			On I.[EmployeeID]=E.[EmployeeID]
Order by I.[InventoryDate], C.[CategoryName],P.[ProductName],(E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]);
Go

-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  Côte de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaraná Fantástica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalikööri	      2017-01-01	  57	  Steven Buchanan

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, the Inventory Date and Count of each product, 
--and the Employee who took the count for the Products 'Chai' and 'Chang'? 

--Columns needed:  [CategoryName],[ProductName],[InventoryDate],[Count], (E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) as EmployeeName
--Views needed:[dbo].[vCategories],[dbo].[vProducts],[dbo].[vInventories],[dbo].[vEmployees]
--Connecting point:[dbo].[Categories].[CategoryID]=[dbo].[Products].[CategoryID] and [dbo].[Products].[ProductID]=[dbo].[Inventories].[ProductID]
--Where [ProductName] In (Select P.[ProductID] From [dbo].[Products] Where P.[ProductName] LIKE 'Cha[i,n]%')
--Order by [CategoryName],[ProductName],[InventoryDate],[Count]

--Create Select Statement:
--Select [CategoryName],[ProductName],[InventoryDate],[Count], (E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) as EmployeeName
--From [dbo].[vCategories] as C
--	Join [dbo].[vProducts] as P
--	  On C.[CategoryID]=P.[CategoryID]
--	Join [dbo].[vInventories] as I
--		On P.[ProductID]=I.[ProductID]
--	Join [dbo].[vEmployees] as E
--		On I.[EmployeeID]=E.[EmployeeID]
--Where P.[ProductName] In (Select P.[ProductName] From [dbo].[Products] as P Where P.[ProductName] LIKE 'Cha[i,n]%')
--Order by I.[InventoryDate], C.[CategoryName],P.[ProductName],(E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]);
--Go

--Create View:
Go
Create --Drop
View [dbo].[vInventoriesForChaiAndChangByEmployees]
  With SCHEMABINDING
  As
  Select Top 1000000000
			[CategoryName],[ProductName],[InventoryDate],[Count], (E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) as EmployeeName
	From [dbo].[vCategories] as C
		Inner Join [dbo].[vProducts] as P
		  On C.[CategoryID]=P.[CategoryID]
		Inner Join [dbo].[vInventories] as I
			On P.[ProductID]=I.[ProductID]
		Inner Join [dbo].[vEmployees] as E
			On I.[EmployeeID]=E.[EmployeeID]
Where P.[ProductName] In (Select P.[ProductName] From [dbo].[Products] as P Where P.[ProductName] LIKE 'Cha[i,n]%')
Order by I.[InventoryDate], C.[CategoryName],P.[ProductName],(E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]);
Go

-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

--Columns needed:  ([EmployeeFirstName] + ' ' + [EmployeeLastName]) as ManagerName, ([EmployeeFirstName] + ' ' + [EmployeeLastName]) as EmployeeName
--Views needed:[dbo].[vmployees]
--Connecting point:[dbo].[Employees].[CategoryID]=[dbo].[Products].[CategoryID] and [dbo].[Products].[ProductID]=[dbo].[Inventories].[ProductID]
--Where [ProductName] In (Select P.[ProductID] From [dbo].[Products] Where P.[ProductName] LIKE 'Cha[i,n]%')
--Order by [CategoryName],[ProductName],[InventoryDate],[Count]


--Select (M.[EmployeeFirstName] + ' ' + M.[EmployeeLastName]) as Manager,
--	   (E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) as Employee
--From [dbo].[vEmployees] as E
--	Inner Join [dbo].[vEmployees] as M
--	On E.[ManagerID] = M.[EmployeeID]
--Order by (M.[EmployeeFirstName] + ' ' + M.[EmployeeLastName]), (E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]);
--Go
Go
Create --Drop
View [dbo].[vEmployeesByManager]
  With SCHEMABINDING
  As
	 Select Top 1000000000
		(M.[EmployeeFirstName] + ' ' + M.[EmployeeLastName]) as Manager,
	    (E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) as Employee
	From [dbo].[vEmployees] as E
	Inner Join [dbo].[vEmployees] as M
	On E.[ManagerID] = M.[EmployeeID]
Order by (M.[EmployeeFirstName] + ' ' + M.[EmployeeLastName]), (E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]);
Go
 

-- Here are the rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King


-- Question 10 (20% pts): How can you create one view to show all the data from all four BASIC Views? 
-- Also show the Employee's Manager Name and order the data by Category, Product, InventoryID, and Employee.

--Columns needed:  [CategoryID],[CategoryName],[ProductID],[ProductName],[UnitPrice],[InventoryID],[InventoryDate],[Count],[EmployeeID], (E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) as Employee
--Views needed:[dbo].[vCategories],[dbo].[vProducts],[dbo].[vInventories],[dbo].[vEmployees]
--Connecting point:[dbo].[Categories].[CategoryID]=[dbo].[Products].[CategoryID] 
--             and [dbo].[Products].[ProductID]=[dbo].[Inventories].[ProductID]
--             and [dbo].[Inventories].[EmployeeID]=[dbo].[Employees].[EmployeeID]
--			   and [dbo].[Employees] as E, [dbo].[Employees] as M
--Order by [CategoryName],[ProductName],[InventoryID],(E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName])
--View Name:[dbo].[vInventoriesByProductsByCategoriesByEmployees]


--Select C.[CategoryID],C.[CategoryName],P.[ProductID],P.[ProductName],P.[UnitPrice],I.[InventoryID],I.[InventoryDate],I.[Count],E.[EmployeeID], (E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) as Employee
--From [dbo].[vCategories] as C
--		Join[dbo].[vProducts] as P
--		  On C.[CategoryID]=P.[CategoryID]
--		Join [dbo].[vInventories] as I
--		  On P.[ProductID]=I.[ProductID]
--		Join [dbo].[vEmployees] as E
--		  On I.[EmployeeID]=E.[EmployeeID]
--		Join [dbo].[vEmployees] as M
--		  On E.[ManagerID] = M.[EmployeeID]
--Order by [CategoryName],[ProductID],[InventoryID],(E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]);
--Go
			
--Create View:
Go
Create --Drop
View [dbo].[vInventoriesByProductsByCategoriesByEmployees]
  As
  Select Top 1000000000
	C.[CategoryID],C.[CategoryName],P.[ProductID],P.[ProductName],P.[UnitPrice],I.[InventoryID],I.[InventoryDate],I.[Count],E.[EmployeeID], (E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]) as Employee
  From [dbo].[vCategories] as C
	Inner Join[dbo].[vProducts] as P
		On C.[CategoryID]=P.[CategoryID]
	Inner Join [dbo].[vInventories] as I
		On P.[ProductID]=I.[ProductID]
	Inner Join [dbo].[vEmployees] as E
		On I.[EmployeeID]=E.[EmployeeID]
	Inner Join [dbo].[vEmployees] as M
		On E.[ManagerID] = M.[EmployeeID]
Order by [CategoryName],[ProductID],[InventoryID],(E.[EmployeeFirstName] + ' ' + E.[EmployeeLastName]);
Go

-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaraná Fantástica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/