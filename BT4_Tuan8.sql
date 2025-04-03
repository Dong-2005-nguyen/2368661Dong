﻿CREATE DATABASE QLBH888;
GO
USE QLBH888;

CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL
);
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    SupplierID INT,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    UnitInStock INT NOT NULL,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CompanyName VARCHAR(100) NOT NULL,
    Address VARCHAR(200),
    City VARCHAR(50),
    Region VARCHAR(50),
    Country VARCHAR(50)
);
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    LastName VARCHAR(50) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    BirthDate DATE,
    City VARCHAR(50)
);
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
CREATE TABLE OrderDetails (
    OrderID INT,
    ProductID INT,
    UnitPrice DECIMAL(10, 2) NOT NULL,
    Quantity INT NOT NULL,
    Discount DECIMAL(4, 2) DEFAULT 0,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
INSERT INTO Suppliers (SupplierID, SupplierName) 
VALUES 
(1, 'Công ty TNHH CYAD'),
(2, 'Công ty BABYSHARK');

INSERT INTO Products (ProductID, ProductName, SupplierID, UnitPrice, UnitInStock) 
VALUES 
(6, 'Nho khô', 1, 450000, 100),
(7, 'Chuối sấy', 2, 120000, 50),
(8, 'Mít sấy', 1, 220000, 70),
(9, 'Xoài sấy dẻo', 2, 310000, 80);

INSERT INTO Customers (CustomerID, CompanyName, Address, City, Region, Country)
VALUES 
(1, 'Công ty A', '14 Đường Huỳnh Khương An', 'London', 'England', 'UK'),
(2, 'Công ty B', '456 Đường Trần Phú', 'Madrid', 'Spain', 'Spain'),
(3, 'Công ty C', '789 Đường Lê Lợi', 'Hồ Chí Minh', 'Miền Nam', 'Vietnam'),
(4, 'Công ty D', '101 Đường Nguyễn Thái Sơn', 'Hà Nội', 'Miền Bắc', 'Vietnam'),
(5, 'Công ty E', '202 Đường Nguyễn Văn Nghi', 'Tuy Hòa', 'Miền Trung', 'France');

INSERT INTO Employees (EmployeeID, LastName, FirstName, BirthDate, City)
VALUES
(1, 'Tang', 'Diên', '1990-05-21', 'Hà Nội'),
(2, 'Chương', 'Nhược Nam', '1985-10-10', 'Hồ Chí Minh'),
(3, 'Lê', 'Hạo Nam', '1993-07-15', 'Đà Nẵng'),
(4, 'Hứa ', 'Quang Hán', '1988-09-09', 'Hải Phòng');


INSERT INTO Orders (OrderID, CustomerID, EmployeeID, OrderDate)
VALUES
(1, 1, 2, '1998-07-13'),
(2, 2, 3, '1998-07-22'),
(3, 3, 1, '1998-06-10'),
(4, 4, 4, '1997-12-03'),
(5, 5, 2, '1996-06-11');

INSERT INTO OrderDetails (OrderID, ProductID, UnitPrice, Quantity, Discount)
VALUES
(1, 6, 450000, 5, 0.1),
(1, 8, 220000, 20, 0),
(2, 7, 120000, 8, 0.05),
(2, 6, 450000, 12, 0),
(3, 9, 310000, 7, 0),
(4, 8, 220000, 15, 0.2),
(5, 9, 310000, 22, 0.15);

use QLBH888
--CÂU 1
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Products);

--CÂU 2
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE UnitPrice > (
    SELECT AVG(UnitPrice) FROM Products
    WHERE ProductName LIKE 'N%'
);

--CÂU 3
SELECT DISTINCT p1.ProductID, p1.ProductName, p1.UnitPrice
FROM Products p1
WHERE p1.ProductName LIKE 'N%'
AND p1.UnitPrice > ANY (SELECT p2.UnitPrice FROM Products p2 WHERE p2.ProductID <> p1.ProductID);

--CÂU 4
SELECT DISTINCT p.ProductID, p.ProductName, p.UnitPrice
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID;

--CÂU 5
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE UnitPrice > (SELECT MIN(UnitPrice) FROM Products);

---CÂU 6
SELECT o.OrderID, o.CustomerID, c.CompanyName, c.City
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE c.City IN ('London', 'Madrid');
---CÂU 7
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE ProductName LIKE '%Box%'
AND UnitPrice < (SELECT AVG(UnitPrice) FROM Products);
--CÂU 8
SELECT ProductID, ProductName
FROM Products
WHERE ProductID IN (
    SELECT TOP 1 ProductID
    FROM OrderDetails
    GROUP BY ProductID
    ORDER BY SUM(Quantity) DESC
);
--CÂU 9
--NOT EXISTS
SELECT * FROM Customers c
WHERE NOT EXISTS (
    SELECT 1 FROM Orders o WHERE c.CustomerID = o.CustomerID
);

--LEFT JOIN
SELECT c.*
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;

--NOT IN
SELECT * FROM Customers
WHERE CustomerID NOT IN (SELECT CustomerID FROM Orders);

--CÂU 10
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE ProductName LIKE '%Box%'
AND UnitPrice = (SELECT MAX(UnitPrice) FROM Products WHERE ProductName LIKE '%Box%');

---CÂU 11
SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE UnitPrice > (
    SELECT AVG(UnitPrice) FROM Products WHERE ProductID <= 5
);

-- CÂU 12
SELECT p.ProductID, p.ProductName
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY p.ProductID, p.ProductName
HAVING SUM(od.Quantity) > (SELECT AVG(Quantity) FROM OrderDetails);

-- CÂU 13
SELECT DISTINCT c.CustomerID, c.CompanyName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE NOT EXISTS (
    SELECT 1 FROM OrderDetails od2
    WHERE od2.OrderID = od.OrderID AND od2.ProductID < 3
);

--CÂU 14
SELECT p.ProductID, p.ProductName
FROM Products p
JOIN OrderDetails od ON p.ProductID = od.ProductID
JOIN Orders o ON od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 1998 AND MONTH(o.OrderDate) BETWEEN 7 AND 9
GROUP BY p.ProductID, p.ProductName
HAVING COUNT(o.OrderID) > 20;

--- CÂU 15
SELECT ProductID, ProductName
FROM Products
WHERE ProductID NOT IN (
    SELECT DISTINCT ProductID FROM OrderDetails od
    JOIN Orders o ON od.OrderID = o.OrderID
    WHERE YEAR(o.OrderDate) = 1996 AND MONTH(o.OrderDate) = 6
);

-- CÂU 16
SELECT e.EmployeeID, e.LastName, e.FirstName
FROM Employees e
WHERE e.EmployeeID NOT IN (
    SELECT EmployeeID FROM Orders WHERE OrderDate = CAST(GETDATE() AS DATE)
);

-- CÂU 17
SELECT c.CustomerID, c.CompanyName
FROM Customers c
WHERE c.CustomerID NOT IN (
    SELECT DISTINCT o.CustomerID FROM Orders o
    WHERE YEAR(o.OrderDate) = 1997
);
-- CÂU 18
SELECT DISTINCT c.CustomerID, c.CompanyName
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
WHERE p.ProductName LIKE 'T%' AND MONTH(o.OrderDate) = 7;

-- CÂU 19
SELECT City, COUNT(CustomerID) AS SoLuongKhach
FROM Customers
GROUP BY City
HAVING COUNT(CustomerID) > 3;


-- CÂU 20
--Câu hỏi tương ứng cho 3 truy vấn SQL:
---Sản phẩm nào có đơn giá lớn hơn tất cả sản phẩm có tên bắt đầu bằng "B"?
---Sản phẩm nào có đơn giá lớn hơn ít nhất một sản phẩm có tên bắt đầu bằng "B"?
---Sản phẩm nào có đơn giá bằng ít nhất một sản phẩm có tên bắt đầu bằng "B"?

----Ba truy vấn đều so sánh UnitPrice của sản phẩm với giá của nhóm sản phẩm có tên bắt đầu bằng "B", nhưng khác nhau ở cách so sánh:
--- > ALL: Chỉ lấy sản phẩm có giá cao hơn giá cao nhất trong nhóm "B".
---- > ANY: Lấy sản phẩm có giá cao hơn ít nhất một sản phẩm trong nhóm "B".
---- = ANY: Lấy sản phẩm có giá bằng với ít nhất một sản phẩm trong nhóm "B".