/** Tuần 9: 
Bài tập 1: Insert - CACH 2:
Câu 2: Khi bảng CT_HoaDon vẫn còn dữ liệu liên kết đến SanPham thông qua khóa ngoại MaSp,
 thì bạn không thể xóa SanPham được do vi phạm ràng buộc toàn vẹn.**/
 /** Câu 3: Bạn phải xóa bảng con trước, hoặc tắt tạm thời ràng buộc khóa ngoại**/
/** BAITAP2: UPDATE: **/
/** CAU 1: Cập nhật đơn giá bán 100000 cho mã sản phẩm có tên bắt đầu bằng chữ T **/
UPDATE SanPham SET GiaGoc = 100000 WHERE TenSp LIKE 'T%';
SELECT MaSp, TenSp, GiaGoc FROM SanPham
WHERE TenSp LIKE 'T%';
/** CAU 2: Cập nhật số lượng tồn = 50% số lượng tồn hiện có cho những sản phẩm có đơn
vị tính có chữ box **/
UPDATE SanPham SET SLTON = SLTON / 2 WHERE Donvitinh LIKE '%HOP%';
SELECT MaSp, TenSp, Donvitinh, SLTON FROM SanPham
WHERE Donvitinh LIKE '%HOP%';
/** CAU 3: Cập nhật mã nhà cung cấp là 1 trong bảng NHACUNGCAP thành 100? **/
UPDATE NhaCungCap SET MaNCC = 100 WHERE MaNCC = 1;
/** CAU NAY LOI VI KHOA NGOAI**/
/** CAU 4: Tăng điểm tích lũy lên 100 cho những KH mua hàng trong tháng 7/1997 **/
UPDATE KhachHang SET DiemTL = DiemTL + 100
WHERE MaKh IN (SELECT DISTINCT MaKh
    FROM HoaDon
    WHERE MONTH(NgayLapHD) = 7 AND YEAR(NgayLapHD) = 1997);
SELECT KH.MaKh, TenKh, DiemTL FROM KhachHang KH
JOIN HoaDon HD ON KH.MaKh = HD.MaKh
WHERE MONTH(HD.NgayLapHD) = 7 AND YEAR(HD.NgayLapHD) = 1997;
/** CAU 5: Giảm 10% đơn giá bán cho những sản phẩm có SLTON < 10 **/
UPDATE SanPham SET GiaGoc = GiaGoc * 0.9 WHERE SLTON < 10;
SELECT MaSp, TenSp, SLTON, GiaGoc FROM SanPham
WHERE SLTON < 10;
/** CAU 6: Cập nhật giá bán trong CT_HoaDon bằng giá mua từ SanPham cho SP có MaNCC = 4 hoặc 7 **/
UPDATE CT_HoaDon SET Dongia = SP.GiaGoc
FROM CT_HoaDon CT
JOIN SanPham SP ON CT.MaSp = SP.MaSp
WHERE SP.MaNCC IN (4, 7);
SELECT CT.MaHD, CT.MaSp, CT.Dongia, SP.GiaGoc, SP.MaNCC
FROM CT_HoaDon CT
JOIN SanPham SP ON CT.MaSp = SP.MaSp
WHERE SP.MaNCC IN (4, 7);
/** BAI TAP 3: DELETE: **/
/** CAU 1:  Xóa các hóa đơn được lập trong tháng 7 năm 1996. Bạn có thực hiện được không? Vì sao? **/
/** Không thể xóa trực tiếp nếu như hóa đơn đó đã có dữ liệu liên quan trong bảng CT_HoaDon (bảng con) do ràng buộc khóa ngoại.
Phải xóa chi tiết hóa đơn trước rồi mới xóa hóa đơn. **/
DELETE FROM CT_HoaDon
WHERE MaHD IN (SELECT MaHD FROM HoaDon
    WHERE MONTH(NgayLapHD) = 7 AND YEAR(NgayLapHD) = 1996);
DELETE FROM HoaDon
WHERE MONTH(NgayLapHD) = 7 AND YEAR(NgayLapHD) = 1996;

/** CAU 2:  Xóa các hóa đơn của các khách hàng có loại là 'VL' mua hàng trong năm 1996 **/
DELETE FROM CT_HoaDon
WHERE MaHD IN (SELECT MaHD FROM HoaDon HD
    JOIN KhachHang KH ON HD.MaKh = KH.MaKh
    WHERE KH.LoaiKh = 'VL' AND YEAR(NgayLapHD) = 1996);
DELETE FROM HoaDon
WHERE MaHD IN (SELECT MaHD FROM HoaDon HD
    JOIN KhachHang KH ON HD.MaKh = KH.MaKh
    WHERE KH.LoaiKh = 'VL' AND YEAR(NgayLapHD) = 1996);
 /** CAU 3:   Xóa các sản phẩm chưa bán được trong năm 1996 **/
 DELETE FROM SanPham
WHERE MaSp NOT IN (SELECT DISTINCT MaSp FROM HoaDon HD
    JOIN CT_HoaDon CT ON HD.MaHD = CT.MaHD
    WHERE YEAR(NgayLapHD) = 1996);

 /** CAU 4: Xóa các khách hàng vãng lai (Loại là 'VL') cùng với hóa đơn và chi tiết hóa đơn của họ **/
 DELETE FROM CT_HoaDon
WHERE MaHD IN (SELECT MaHD FROM HoaDon HD
    JOIN KhachHang KH ON HD.MaKh = KH.MaKh
    WHERE KH.LoaiKh = 'VL');
DELETE FROM HoaDon
WHERE MaKh IN (SELECT MaKh FROM KhachHang
    WHERE LoaiKh = 'VL');
DELETE FROM KhachHang WHERE LoaiKh = 'VL';

  /** CAU 5:   Tạo bảng HoaDon797 chứa các hóa đơn được lập trong tháng 7 năm 1997, sau đó xóa bằng TRUNCATE **/
SELECT * INTO HoaDon797
FROM HoaDon
WHERE MONTH(NgayLapHD) = 7 AND YEAR(NgayLapHD) = 1997;
/** XOA **/
TRUNCATE TABLE HoaDon797;
