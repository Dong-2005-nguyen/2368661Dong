CREATE DATABASE QLBH8888;
GO
USE QLBH8888;

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

---BÀI 5
---câu 1

SELECT 
    CAST(CustomerID AS NVARCHAR) AS CodeID, 
    CompanyName AS Name, 
    Address, 
    NULL AS Phone
FROM Customers
UNION ALL
SELECT 
    CAST(EmployeeID AS NVARCHAR) AS CodeID, 
    LastName + ' ' + FirstName AS Name, 
    NULL AS Address, 
    NULL AS Phone
FROM Employees;

-- Câu 2
SELECT 
    c.CustomerID, 
    c.CompanyName, 
    c.Address, 
    SUM(od.Quantity * od.UnitPrice) AS ToTal
INTO HDKH_71997
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = 1997 AND MONTH(o.OrderDate) = 7
GROUP BY c.CustomerID, c.CompanyName, c.Address;


SELECT * FROM HDKH_71997;


--- Câu 3
SELECT 
    e.EmployeeID, 
    e.LastName + ' ' + e.FirstName AS Name, 
    e.City AS Address, 
    SUM(od.Quantity * od.UnitPrice) AS ToTal
INTO LuongNV
FROM Employees e
JOIN Orders o ON e.EmployeeID = o.EmployeeID
JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE YEAR(o.OrderDate) = 1996 AND MONTH(o.OrderDate) = 12
GROUP BY e.EmployeeID, e.LastName, e.FirstName, e.City;

SELECT * FROM LuongNV;

---Câu 4
CREATE TABLE Shippers (
    ShipperID INT PRIMARY KEY,
    CompanyName VARCHAR(100)
);

-- Thêm dữ liệu ví dụ
INSERT INTO Shippers (ShipperID, CompanyName) 
VALUES 
(1, 'Gojek'),
(2, 'Lazada');


ALTER TABLE Orders
ADD ShipVia INT;

-- Giả sử ShipVia tham chiếu đến bảng Shippers
ALTER TABLE Orders
ADD FOREIGN KEY (ShipVia) REFERENCES Shippers(ShipperID);

UPDATE Orders
SET ShipVia = 1
WHERE OrderID = 1;

UPDATE Orders
SET ShipVia = 2
WHERE OrderID = 2;


SELECT 
    c.CustomerID, 
    c.CompanyName, 
    SUM(od.Quantity * od.UnitPrice) AS TotalAmount
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Shippers s ON o.ShipVia = s.ShipperID  -- Sử dụng ShipVia để tham chiếu đến công ty vận chuyển
WHERE s.CompanyName = 'Speedy Express'  -- Hoặc bạn có thể thay đổi thành tên công ty khác
    AND (c.Country = 'Germany' OR c.Country = 'USA')
    AND YEAR(o.OrderDate) = 1998
    AND MONTH(o.OrderDate) BETWEEN 1 AND 3  -- Quý 1: Tháng 1, 2, 3
GROUP BY c.CustomerID, c.CompanyName;

---Câu 5
CREATE TABLE dbo.HoaDonBanHang
(
    orderid INT NOT NULL,
    orderdate DATE NOT NULL,
    empid INT NOT NULL,
    custid VARCHAR(5) NOT NULL,
    qty INT NOT NULL,
    CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

INSERT INTO dbo.HoaDonBanHang (orderid, orderdate, empid, custid, qty) VALUES
(30001, '2007-08-02', 3, 'A', 10),
(10001, '2007-12-24', 2, 'A', 12),
(10005, '2007-12-24', 1, 'B', 20),
(40001, '2008-01-09', 2, 'A', 40),
(10006, '2008-01-18', 1, 'C', 14),
(20001, '2008-02-12', 2, 'B', 12),
(40005, '2009-02-12', 3, 'A', 10),
(20002, '2009-02-16', 1, 'C', 20),
(30003, '2009-04-18', 2, 'B', 15),
(30004, '2007-04-18', 3, 'C', 22),
(30007, '2009-09-07', 3, 'D', 30);

--- tính tổng Qty cho mỗi nhân viên
SELECT empid, SUM(qty) AS TotalQty
FROM dbo.HoaDonBanHang
GROUP BY empid;
---- tạo bảng Pivot
SELECT empid, A, B, C, D
FROM 
(
    SELECT empid, custid, qty
    FROM dbo.HoaDonBanHang
) 
AS D
PIVOT (
    SUM(qty) FOR custid IN (A, B, C, D)
	) 
AS P;

---- lấy dữ liệu từ bảng dbo.HoaDonBanHang trả về số hóa đơn đã lập của nhân viên employee trong mỗi năm.
SELECT empid, YEAR(orderdate) AS OrderYear, COUNT(orderid) AS OrderCount
FROM dbo.HoaDonBanHang
GROUP BY empid, YEAR(orderdate);

---- tạo bảng hiển thị số đơn đtawj hàng

SELECT 
    'Orders Count' AS Metric,
    ISNULL([164], 0) AS [164], 
    ISNULL([198], 0) AS [198], 
    ISNULL([223], 0) AS [223], 
    ISNULL([231], 0) AS [231], 
    ISNULL([233], 0) AS [233]
FROM (
    SELECT empid, orderid  -- Chọn cột empid và orderid từ bảng HoaDonBanHang
    FROM dbo.HoaDonBanHang
    WHERE empid IN (164, 198, 223, 231, 233)  -- Chỉ chọn những nhân viên có empid là 164, 198, 223, 231, 233
) AS SourceTable
PIVOT (
    COUNT(orderid)  -- Đếm số lượng đơn hàng cho mỗi nhân viên
    FOR empid IN ([164], [198], [223], [231], [233])  -- Pivot theo empid
) AS PivotTable;
