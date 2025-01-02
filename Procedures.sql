-- Procedure: Lấy danh sách khách hàng đủ điều kiện nâng cấp thẻ
CREATE PROCEDURE LayKhachHangNangCapThe
AS
BEGIN
    SELECT KH.MaKhachHang, KH.HoTen, KH.SDT, KH.Email, TT.LoaiThe, TT.DiemTichLuy
    FROM KhachHang KH
    INNER JOIN TheThanhVien TT ON KH.MaKhachHang = TT.MaKhachHang
    WHERE 
        (TT.LoaiThe = 'Member' AND TT.DiemTichLuy >= 50) -- Điều kiện nâng cấp lên Silver
        OR
        (TT.LoaiThe = 'Silver' AND TT.DiemTichLuy >= 100); -- Điều kiện nâng cấp lên Gold
END;

-- Gọi procedure để lấy danh sách khách hàng đủ điều kiện nâng cấp thẻ
EXEC LayKhachHangNangCapThe;

GO

CREATE PROCEDURE sp_TaoTheThanhVien
    @MaKhachHang NVARCHAR(13),
    @MaNhanVien NVARCHAR(10),
    @LoaiThe NVARCHAR(20),  -- Loại thẻ, có thể là 'Silver' hoặc 'Gold'
    @DiemTichLuy INT = 0  -- Điểm tích lũy mặc định là 0
AS
BEGIN
    -- Kiểm tra xem khách hàng có tồn tại trong bảng KhachHang hay không
    IF NOT EXISTS (SELECT 1 FROM KhachHang WHERE MaKhachHang = @MaKhachHang)
    BEGIN
        PRINT 'Khách hàng không tồn tại!';
        RETURN;
    END

    -- Kiểm tra xem nhân viên có tồn tại trong bảng NhanVien hay không
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNhanVien = @MaNhanVien)
    BEGIN
        PRINT 'Nhân viên không tồn tại!';
        RETURN;
    END

    -- Kiểm tra loại thẻ có hợp lệ hay không
    IF @LoaiThe NOT IN ('MEMBER', 'SILVER', 'GOLD')
    BEGIN
        PRINT 'Loại thẻ không hợp lệ!';
        RETURN;
    END

    -- Thực hiện việc tạo thẻ thành viên
    INSERT INTO TheThanhVien (MaThe, MaKhachHang, MaNhanVien, LoaiThe, NgayLap, DiemTichLuy)
    VALUES (@MaKhachHang, @MaKhachHang, @MaNhanVien, @LoaiThe, GETDATE(), @DiemTichLuy);

    PRINT 'Thẻ thành viên đã được tạo thành công!';
END;

GO

DELETE FROM TheThanhVien
 WHERE MaThe = 'KH000001';

SELECT * FROM TheThanhVien
 WHERE MaThe = 'KH000001';

EXEC sp_TaoTheThanhVien 
    @MaKhachHang = 'KH000001', 
    @MaNhanVien = 'NV000001', 
    @LoaiThe = 'GOLD', 
    @DiemTichLuy = 100;

GO

CREATE PROCEDURE sp_DatMon
    @MaChiNhanh NVARCHAR(10),
    @MaNhanVien NVARCHAR(10),
    @NgayDat DATETIME,
    @GioDen DATETIME,
    @SoLuongKhach DECIMAL(10,2),
    @Ban INT,
    @TinhTrangXacNhan BIT,
    @GhiChu NVARCHAR(200),
    @DanhSachMonAn NVARCHAR(MAX)  -- Danh sách các món ăn và số lượng (chuỗi JSON)
AS
BEGIN
    -- Kiểm tra xem chi nhánh có tồn tại trong bảng ChiNhanh hay không
    IF NOT EXISTS (SELECT 1 FROM ChiNhanh WHERE MaChiNhanh = @MaChiNhanh)
    BEGIN
        PRINT 'Chi nhánh không tồn tại!';
        RETURN;
    END

    -- Kiểm tra xem nhân viên có tồn tại trong bảng NhanVien hay không
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNhanVien = @MaNhanVien)
    BEGIN
        PRINT 'Nhân viên không tồn tại!';
        RETURN;
    END

    -- Tạo Phiếu Đặt Món
    DECLARE @MaPhieuDatMon NVARCHAR(10) = '0002221';

    INSERT INTO PhieuDatMon (MaPhieuDatMon, MaChiNhanh, MaNhanVien, NgayDat, GioDen, Ban, SoLuongKhach, TinhTrangXacNhan, GhiChu, NgayLap)
    VALUES (@MaPhieuDatMon, @MaChiNhanh, @MaNhanVien, @NgayDat, @GioDen, @Ban, @SoLuongKhach, @TinhTrangXacNhan, @GhiChu, GETDATE());

    -- Xử lý Danh Sách Món Ăn (Giả sử là một chuỗi JSON chứa thông tin các món ăn và số lượng)
    DECLARE @Json NVARCHAR(MAX) = @DanhSachMonAn;
    -- Nếu sử dụng JSON, sử dụng OPENJSON để chuyển chuỗi JSON thành các cột tương ứng

    INSERT INTO ChiTietPDM (MaChiTietPDM, MaPhieuDatMon, MaMonAn, DatTruoc, SoLuong)
    SELECT NEWID(), @MaPhieuDatMon, 
           JSON_VALUE(value, '$.MaMonAn') AS MaMonAn,
           JSON_VALUE(value, '$.DatTruoc') AS DatTruoc,
           JSON_VALUE(value, '$.SoLuong') AS SoLuong
    FROM OPENJSON(@Json) 
    WITH (
        value NVARCHAR(MAX) AS JSON
    );

    PRINT 'Phiếu đặt món đã được tạo thành công!';
END;


GO

DECLARE @DanhSachMonAn NVARCHAR(MAX) = N'[{"MaMonAn": "MA001", "DatTruoc": 1, "SoLuong": 2}, {"MaMonAn": "MA002", "DatTruoc": 0, "SoLuong": 1}]';

EXEC sp_DatMon 
    @MaChiNhanh = 'CN01',
    @MaNhanVien = 'NV000001',
    @NgayDat = '2025-01-05 14:30:00',
    @GioDen = '2025-01-05 18:00:00',
    @SoLuongKhach = 4,
    @Ban = 2,
    @TinhTrangXacNhan = 0,
    @GhiChu = 'Yêu cầu thêm nước chanh',
    @DanhSachMonAn = @DanhSachMonAn;


GO

SELECT * FROM PhieuDatMon
 WHERE MaPhieuDatMon = '0002221';

SELECT * FROM ChiTietPDM
 WHERE MaPhieuDatMon = '0002221';

DELETE FROM PhieuDatMon
 WHERE MaPhieuDatMon = '0002221';

 DELETE FROM ChiTietPDM
 WHERE MaPhieuDatMon = '0002221';

 GO
 
 -- Them Chi Nhanh moi
DROP PROCEDURE ThemChinhanh
GO
CREATE PROCEDURE ThemChinhanh
    @MaChiNhanh NVARCHAR(10) ,
    @TenChiNhanh NVARCHAR(100),
    @DiaChi NVARCHAR(255),
	@ThanhPho NVARCHAR(255),
    @TGMoCua DATETIME ,
    @TGDongCua DATETIME,
    @SDT NVARCHAR(15),
    @BaiDoXe BIT
AS
BEGIN
    INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThanhPho, TGMoCua, TGDongCua, SDT, BaiDoXe)
    VALUES (@MaChiNhanh, @TenChiNhanh, @DiaChi, @ThanhPho, @TGMoCua, @TGDongCua, @SDT, @BaiDoXe);
END;

EXEC ThemChinhanh 
    @MaChiNhanh = 'N002', 
    @TenChiNhanh = N'Chi Nhánh TP.HCM', 
    @DiaChi = N'123 Đường ABC, Quận 1', 
    @ThanhPho = N'TP.HCM', 
    @TGMoCua = '09:00', 
    @TGDongCua = '22:00', 
    @SDT = '0123456789', 
    @BaiDoXe = 1;  -- 1 là có bãi giữ xe, 0 là không có

SELECT * FROM ChiNhanh
 WHERE MaChiNhanh = 'N002';

DELETE FROM ChiNhanh
 WHERE MaChiNhanh = 'N002';

GO

-- Thêm món vào thực đơn của chi nhánh
CREATE PROCEDURE ThemMonVaoThucDon
    @MaThucDon NVARCHAR(10),
    @MaChiNhanh NVARCHAR(10),
    @MaMonAn NVARCHAR(10),
    @TrangThai BIT
AS
BEGIN
    -- Kiểm tra xem món ăn đã có trong thực đơn của chi nhánh này chưa
    IF EXISTS (SELECT 1 FROM ThucDon WHERE MaChiNhanh = @MaChiNhanh AND MaMonAn = @MaMonAn)
    BEGIN
        -- Nếu đã tồn tại, cập nhật trạng thái
        UPDATE ThucDon
        SET TrangThai = @TrangThai
        WHERE MaChiNhanh = @MaChiNhanh AND MaMonAn = @MaMonAn;
    END
    ELSE
    BEGIN
        -- Nếu chưa tồn tại, thêm món vào thực đơn mới
        INSERT INTO ThucDon (MaThucDon, MaChiNhanh, MaMonAn, TrangThai)
        VALUES (@MaThucDon, @MaChiNhanh, @MaMonAn, @TrangThai);
    END
END;

EXEC ThemMonVaoThucDon 
    @MaThucDon = 'TD001', 
    @MaChiNhanh = 'CN01', 
    @MaMonAn = 'MA000001', 
    @TrangThai = 1;  -- 1 là món ăn đang được phục vụ

SELECT * FROM ThucDon
 WHERE MaThucDon = 'TD001';

DELETE FROM ThucDon
 WHERE MaThucDon = 'TD001';

 GO

 -- Thêm khách hàng mới
CREATE PROCEDURE ThemKhachHang
    @MaKhachHang NVARCHAR(13),
    @HoTen NVARCHAR(100),
    @SDT NVARCHAR(15),
    @Email NVARCHAR(255),
    @CCCD NVARCHAR(20),
    @GioiTinh NVARCHAR(10)
AS
BEGIN
    -- Kiểm tra xem mã khách hàng đã tồn tại trong hệ thống chưa
    IF EXISTS (SELECT 1 FROM KhachHang WHERE MaKhachHang = @MaKhachHang)
    BEGIN
        PRINT 'Mã khách hàng đã tồn tại.'
    END
    ELSE
    BEGIN
        -- Nếu chưa tồn tại, thêm khách hàng mới
        INSERT INTO KhachHang (MaKhachHang, HoTen, SDT, Email, CCCD, GioiTinh)
        VALUES (@MaKhachHang, @HoTen, @SDT, @Email, @CCCD, @GioiTinh);
        PRINT 'Khách hàng đã được thêm thành công.'
    END
END;

 EXEC ThemKhachHang 
    @MaKhachHang = '1234567890123', 
    @HoTen = 'Nguyễn Văn A', 
    @SDT = '0901234567', 
    @Email = 'nguyenvana@example.com', 
    @CCCD = '1234567890123', 
    @GioiTinh = 'Nam';

SELECT * FROM KhachHang
 WHERE MaKhachHang = '1234567890123';

DELETE FROM KhachHang
 WHERE MaKhachHang = '1234567890123';

 GO
 -- xem doanh thu mỗi ngày/mỗi tháng/ mỗi quý / mỗi năm
CREATE PROCEDURE ThongKeDoanhThuChiTiet
    @LoaiThoiGian NVARCHAR(10), -- 'NGAY', 'THANG', 'NAM'
    @GiaTriThoiGian NVARCHAR(20), -- Giá trị cụ thể: 'yyyy-MM-dd', 'yyyy-MM', hoặc 'yyyy'
    @MaChiNhanh NVARCHAR(10) = NULL -- Mã chi nhánh (NULL nếu muốn xem tất cả các chi nhánh)
AS
BEGIN
    SET NOCOUNT ON;

    -- Điều kiện cố định cho từng loại thời gian
    IF @LoaiThoiGian = 'NGAY'
    BEGIN
        SELECT 
            c.TenChiNhanh,
            CONVERT(VARCHAR, h.NgayThanhToan, 23) AS ThoiGian,
            SUM(h.TienThanhToan) AS TongDoanhThu
        FROM 
            HoaDon h
        JOIN 
            PhieuDatMon pdm ON h.MaPhieuDatMon = pdm.MaPhieuDatMon
        JOIN 
            ChiNhanh c ON pdm.MaChiNhanh = c.MaChiNhanh
        WHERE 
            CONVERT(VARCHAR, h.NgayThanhToan, 23) = @GiaTriThoiGian
            AND (@MaChiNhanh IS NULL OR c.MaChiNhanh = @MaChiNhanh)
        GROUP BY 
            c.TenChiNhanh, 
            CONVERT(VARCHAR, h.NgayThanhToan, 23)
        ORDER BY 
            ThoiGian;
    END
    ELSE IF @LoaiThoiGian = 'THANG'
    BEGIN
        SELECT 
            c.TenChiNhanh,
            FORMAT(h.NgayThanhToan, 'yyyy-MM') AS ThoiGian,
            SUM(h.TienThanhToan) AS TongDoanhThu
        FROM 
            HoaDon h
        JOIN 
            PhieuDatMon pdm ON h.MaPhieuDatMon = pdm.MaPhieuDatMon
        JOIN 
            ChiNhanh c ON pdm.MaChiNhanh = c.MaChiNhanh
        WHERE 
            FORMAT(h.NgayThanhToan, 'yyyy-MM') = @GiaTriThoiGian
            AND (@MaChiNhanh IS NULL OR c.MaChiNhanh = @MaChiNhanh)
        GROUP BY 
            c.TenChiNhanh, 
            FORMAT(h.NgayThanhToan, 'yyyy-MM')
        ORDER BY 
            ThoiGian;
    END
    ELSE IF @LoaiThoiGian = 'NAM'
    BEGIN
        SELECT 
            c.TenChiNhanh,
            CAST(YEAR(h.NgayThanhToan) AS NVARCHAR) AS ThoiGian,
            SUM(h.TienThanhToan) AS TongDoanhThu
        FROM 
            HoaDon h
        JOIN 
            PhieuDatMon pdm ON h.MaPhieuDatMon = pdm.MaPhieuDatMon
        JOIN 
            ChiNhanh c ON pdm.MaChiNhanh = c.MaChiNhanh
        WHERE 
            YEAR(h.NgayThanhToan) = CAST(@GiaTriThoiGian AS INT)
            AND (@MaChiNhanh IS NULL OR c.MaChiNhanh = @MaChiNhanh)
        GROUP BY 
            c.TenChiNhanh, 
            YEAR(h.NgayThanhToan)
        ORDER BY 
            ThoiGian;
    END
END;

GO

-- Thống kê doanh thu theo ngày cho chi nhánh với mã 'CN001'
EXEC ThongKeDoanhThuChiTiet
    @LoaiThoiGian = 'NGAY',
    @GiaTriThoiGian = '2023-04-01',
    @MaChiNhanh = 'CN01';

-- Thống kê doanh thu theo tháng cho tất cả các chi nhánh
EXEC ThongKeDoanhThuChiTiet
    @LoaiThoiGian = 'THANG',
    @GiaTriThoiGian = '2024-01',
    @MaChiNhanh = NULL;

-- Thống kê doanh thu theo năm cho tất cả các chi nhánh
EXEC ThongKeDoanhThuChiTiet
    @LoaiThoiGian = 'NAM',
    @GiaTriThoiGian = '2023',
    @MaChiNhanh = 'CN01';

--  tìm kiếm thông tin nhân viên, xem danh sách nhân viên theo chi nhánh
CREATE PROCEDURE TimKiemNhanVien
    @TuKhoa NVARCHAR(100) = NULL, -- Từ khóa tìm kiếm (có thể là tên, mã nhân viên, hoặc thông tin khác)
    @MaChiNhanh NVARCHAR(10) = NULL -- Mã chi nhánh (NULL nếu muốn xem tất cả các chi nhánh)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        nv.MaNhanVien,
        nv.HoTenNV,
        nv.NgaySinh,
        nv.GioiTinh,
        nv.Luong,
        bp.TenBoPhan,
        cn.TenChiNhanh
    FROM 
        NhanVien nv
    LEFT JOIN 
        BoPhan bp ON nv.MaBoPhan = bp.MaBoPhan
    LEFT JOIN 
        ChiNhanh cn ON nv.MaChiNhanh = cn.MaChiNhanh
    WHERE 
        (@TuKhoa IS NULL OR 
         nv.MaNhanVien LIKE '%' + @TuKhoa + '%' OR 
         nv.HoTenNV LIKE '%' + @TuKhoa + '%' OR 
         nv.GioiTinh LIKE '%' + @TuKhoa + '%')
        AND (@MaChiNhanh IS NULL OR nv.MaChiNhanh = @MaChiNhanh)
    ORDER BY 
        cn.TenChiNhanh, nv.HoTenNV;
END;

GO

-- Tìm kiếm tất cả nhân viên với từ khóa là 'Nguyen'
EXEC TimKiemNhanVien
    @TuKhoa = 'Nguyen',
    @MaChiNhanh = NULL;

-- Tìm kiếm tất cả nhân viên tại chi nhánh 'CN001'
EXEC TimKiemNhanVien
    @TuKhoa = NULL,
    @MaChiNhanh = 'CN01';

-- Tìm kiếm tất cả nhân viên không theo từ khóa và không lọc chi nhánh
EXEC TimKiemNhanVien
    @TuKhoa = NULL,
    @MaChiNhanh = NULL;

GO

--  tìm kiếm hoá đơn theo khách hàng
CREATE PROCEDURE TimKiemHoaDonTheoKhachHang
    @TuKhoa NVARCHAR(100) = NULL -- Từ khóa tìm kiếm (Mã khách hàng, tên khách hàng, hoặc email)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        hd.MaHoaDon,
        kh.HoTen AS TenKhachHang,
        kh.Email AS EmailKhachHang,
        hd.NgayThanhToan,
        hd.TongTien,
        hd.TienGiamGia,
        hd.TienThanhToan,
        hd.PhuongThucThanhToan,
        cn.TenChiNhanh
    FROM 
        HoaDon hd
    JOIN 
        KhachHang kh ON hd.MaKhachHang = kh.MaKhachHang
    LEFT JOIN 
        PhieuDatMon pdm ON hd.MaPhieuDatMon = pdm.MaPhieuDatMon
    LEFT JOIN 
        ChiNhanh cn ON pdm.MaChiNhanh = cn.MaChiNhanh
    WHERE 
        (@TuKhoa IS NULL OR 
         kh.MaKhachHang LIKE '%' + @TuKhoa + '%' OR 
         kh.HoTen LIKE '%' + @TuKhoa + '%' OR 
         kh.Email LIKE '%' + @TuKhoa + '%')
    ORDER BY 
        hd.NgayThanhToan DESC;
END;

GO

-- Tìm kiếm hóa đơn của khách hàng với từ khóa 'Nguyen'
EXEC TimKiemHoaDonTheoKhachHang
    @TuKhoa = 'Nguyen';

-- Tìm kiếm hóa đơn của khách hàng với email 'tinhnguyen@example.com'
EXEC TimKiemHoaDonTheoKhachHang
    @TuKhoa = 'tinhnguyen@example.com';

-- Tìm kiếm tất cả hóa đơn không sử dụng từ khóa
EXEC TimKiemHoaDonTheoKhachHang
    @TuKhoa = NULL;

-- Tìm kiếm hóa đơn của khách hàng có mã 'KH001'
EXEC TimKiemHoaDonTheoKhachHang
    @TuKhoa = 'KH000002';

GO

--  tìm kiếm hoá đơn theo ngày
CREATE PROCEDURE TimKiemHoaDonTheoNgay
    @LoaiThoiGian NVARCHAR(10), -- 'NGAY', 'THANG', hoặc 'KHOANG'
    @GiaTriThoiGian NVARCHAR(20) = NULL, -- Giá trị cụ thể: 'yyyy-MM-dd' (ngày) hoặc 'yyyy-MM' (tháng)
    @NgayBatDau DATE = NULL, -- Ngày bắt đầu (dùng khi @LoaiThoiGian = 'KHOANG')
    @NgayKetThuc DATE = NULL -- Ngày kết thúc (dùng khi @LoaiThoiGian = 'KHOANG')
AS
BEGIN
    SET NOCOUNT ON;

    IF @LoaiThoiGian = 'NGAY'
    BEGIN
        SELECT 
            hd.MaHoaDon,
            hd.NgayThanhToan,
            hd.TongTien,
            hd.TienGiamGia,
            hd.TienThanhToan,
            hd.PhuongThucThanhToan,
            kh.HoTen AS TenKhachHang,
            cn.TenChiNhanh
        FROM 
            HoaDon hd
        JOIN 
            KhachHang kh ON hd.MaKhachHang = kh.MaKhachHang
        LEFT JOIN 
            PhieuDatMon pdm ON hd.MaPhieuDatMon = pdm.MaPhieuDatMon
        LEFT JOIN 
            ChiNhanh cn ON pdm.MaChiNhanh = cn.MaChiNhanh
        WHERE 
            CONVERT(VARCHAR, hd.NgayThanhToan, 23) = @GiaTriThoiGian
        ORDER BY 
            hd.NgayThanhToan DESC;
    END
    ELSE IF @LoaiThoiGian = 'THANG'
    BEGIN
        SELECT 
            hd.MaHoaDon,
            FORMAT(hd.NgayThanhToan, 'yyyy-MM') AS ThoiGian,
            hd.TongTien,
            hd.TienGiamGia,
            hd.TienThanhToan,
            hd.PhuongThucThanhToan,
            kh.HoTen AS TenKhachHang,
            cn.TenChiNhanh
        FROM 
            HoaDon hd
        JOIN 
            KhachHang kh ON hd.MaKhachHang = kh.MaKhachHang
        LEFT JOIN 
            PhieuDatMon pdm ON hd.MaPhieuDatMon = pdm.MaPhieuDatMon
        LEFT JOIN 
            ChiNhanh cn ON pdm.MaChiNhanh = cn.MaChiNhanh
        WHERE 
            FORMAT(hd.NgayThanhToan, 'yyyy-MM') = @GiaTriThoiGian
        ORDER BY 
            hd.NgayThanhToan DESC;
    END
    ELSE IF @LoaiThoiGian = 'KHOANG'
    BEGIN
        SELECT 
            hd.MaHoaDon,
            hd.NgayThanhToan,
            hd.TongTien,
            hd.TienGiamGia,
            hd.TienThanhToan,
            hd.PhuongThucThanhToan,
            kh.HoTen AS TenKhachHang,
            cn.TenChiNhanh
        FROM 
            HoaDon hd
        JOIN 
            KhachHang kh ON hd.MaKhachHang = kh.MaKhachHang
        LEFT JOIN 
            PhieuDatMon pdm ON hd.MaPhieuDatMon = pdm.MaPhieuDatMon
        LEFT JOIN 
            ChiNhanh cn ON pdm.MaChiNhanh = cn.MaChiNhanh
        WHERE 
            hd.NgayThanhToan BETWEEN @NgayBatDau AND @NgayKetThuc
        ORDER BY 
            hd.NgayThanhToan DESC;
    END
END;

GO

-- Tìm kiếm hóa đơn theo ngày '2025-01-02'
EXEC TimKiemHoaDonTheoNgay
    @LoaiThoiGian = 'NGAY',
    @GiaTriThoiGian = '2024-01-02';

-- Tìm kiếm hóa đơn theo tháng '2025-01'
EXEC TimKiemHoaDonTheoNgay
    @LoaiThoiGian = 'THANG',
    @GiaTriThoiGian = '2024-01';

-- Tìm kiếm hóa đơn trong khoảng thời gian từ '2025-01-01' đến '2025-01-02'
EXEC TimKiemHoaDonTheoNgay
    @LoaiThoiGian = 'KHOANG',
    @NgayBatDau = '2023-01-01',
    @NgayKetThuc = '2024-01-02';

GO

-- thống kê doanh thu theo từng món, món chạy nhất, món bán chậm nhất trong 1 khoảng thời gian cụ thể theo chi nhánh
CREATE PROCEDURE ThongKeDoanhThuMonAn
    @NgayBatDau DATE, -- Ngày bắt đầu của khoảng thời gian
    @NgayKetThuc DATE, -- Ngày kết thúc của khoảng thời gian
    @MaChiNhanh NVARCHAR(10) = NULL -- Mã chi nhánh (NULL nếu muốn xem tất cả chi nhánh)
AS
BEGIN
    SET NOCOUNT ON;

    -- Thống kê doanh thu theo từng món ăn
    SELECT 
        ma.TenMon AS TenMonAn,
        COUNT(ctpdm.MaMonAn) AS SoLuongBan,
        SUM(ma.GiaHienTai * ISNULL(ctpdm.SoLuong, 1)) AS TongDoanhThu,
        cn.TenChiNhanh
    FROM 
        ChiTietPDM ctpdm
    JOIN 
        PhieuDatMon pdm ON ctpdm.MaPhieuDatMon = pdm.MaPhieuDatMon
    JOIN 
        HoaDon hd ON pdm.MaPhieuDatMon = hd.MaPhieuDatMon
    JOIN 
        MonAn ma ON ctpdm.MaMonAn = ma.MaMonAn
    JOIN 
        ChiNhanh cn ON pdm.MaChiNhanh = cn.MaChiNhanh
    WHERE 
        hd.NgayThanhToan BETWEEN @NgayBatDau AND @NgayKetThuc
        AND (@MaChiNhanh IS NULL OR cn.MaChiNhanh = @MaChiNhanh)
    GROUP BY 
        ma.TenMon, cn.TenChiNhanh
    ORDER BY 
        TongDoanhThu DESC;

    -- Món ăn chạy nhất (doanh thu cao nhất)
    PRINT 'Món bán chạy nhất:';
    SELECT TOP 1
        ma.TenMon AS TenMonAn,
        COUNT(ctpdm.MaMonAn) AS SoLuongBan,
        SUM(ma.GiaHienTai * ISNULL(ctpdm.SoLuong, 1)) AS TongDoanhThu,
        cn.TenChiNhanh
    FROM 
        ChiTietPDM ctpdm
    JOIN 
        PhieuDatMon pdm ON ctpdm.MaPhieuDatMon = pdm.MaPhieuDatMon
    JOIN 
        HoaDon hd ON pdm.MaPhieuDatMon = hd.MaPhieuDatMon
    JOIN 
        MonAn ma ON ctpdm.MaMonAn = ma.MaMonAn
    JOIN 
        ChiNhanh cn ON pdm.MaChiNhanh = cn.MaChiNhanh
    WHERE 
        hd.NgayThanhToan BETWEEN @NgayBatDau AND @NgayKetThuc
        AND (@MaChiNhanh IS NULL OR cn.MaChiNhanh = @MaChiNhanh)
    GROUP BY 
        ma.TenMon, cn.TenChiNhanh
    ORDER BY 
        TongDoanhThu DESC;

    -- Món ăn bán chậm nhất (doanh thu thấp nhất)
    PRINT 'Món bán chậm nhất:';
    SELECT TOP 1
        ma.TenMon AS TenMonAn,
        COUNT(ctpdm.MaMonAn) AS SoLuongBan,
        SUM(ma.GiaHienTai * ISNULL(ctpdm.SoLuong, 1)) AS TongDoanhThu,
        cn.TenChiNhanh
    FROM 
        ChiTietPDM ctpdm
    JOIN 
        PhieuDatMon pdm ON ctpdm.MaPhieuDatMon = pdm.MaPhieuDatMon
    JOIN 
        HoaDon hd ON pdm.MaPhieuDatMon = hd.MaPhieuDatMon
    JOIN 
        MonAn ma ON ctpdm.MaMonAn = ma.MaMonAn
    JOIN 
        ChiNhanh cn ON pdm.MaChiNhanh = cn.MaChiNhanh
    WHERE 
        hd.NgayThanhToan BETWEEN @NgayBatDau AND @NgayKetThuc
        AND (@MaChiNhanh IS NULL OR cn.MaChiNhanh = @MaChiNhanh)
    GROUP BY 
        ma.TenMon, cn.TenChiNhanh
    ORDER BY 
        TongDoanhThu ASC;
END;

GO

-- Thống kê doanh thu món ăn từ ngày '2025-01-01' đến '2025-01-31' cho tất cả chi nhánh
EXEC ThongKeDoanhThuMonAn
    @NgayBatDau = '2024-01-01',
    @NgayKetThuc = '2025-01-31';

-- Thống kê doanh thu món ăn cho chi nhánh có mã 'CN01' từ ngày '2025-01-01' đến '2025-01-31'
EXEC ThongKeDoanhThuMonAn
    @NgayBatDau = '2024-01-01',
    @NgayKetThuc = '2025-01-31',
    @MaChiNhanh = 'CN01';

GO

-- Stored Procedure for dish statistics
CREATE PROCEDURE ThongKeMonAn
    @FromDate DATETIME,
    @ToDate DATETIME
AS
BEGIN
    SELECT 
        MaMonAn,
        COUNT(MaMonAn) AS SoLuong
    FROM ChiTietPDM
    INNER JOIN PhieuDatMon ON ChiTietPDM.MaPhieuDatMon = PhieuDatMon.MaPhieuDatMon
    WHERE NgayDat BETWEEN @FromDate AND @ToDate
    GROUP BY MaMonAn;
END;

GO

-- To retrieve dish statistics from January 1st, 2025 to January 31st, 2025:
EXEC ThongKeMonAn 
    @FromDate = '2024-01-01', 
    @ToDate = '2025-01-31';

GO

-- Stored Procedure for customer statistics
CREATE PROCEDURE ThongKeKhachHang
    @FromDate DATETIME,
    @ToDate DATETIME
AS
BEGIN
    SELECT 
        COUNT(DISTINCT MaKhachHang) AS SoLuongKhachHang
    FROM HoaDon
    WHERE NgayThanhToan BETWEEN @FromDate AND @ToDate;
END;

GO

-- To retrieve customer statistics from January 1st, 2025 to January 31st, 2025:
EXEC ThongKeKhachHang 
    @FromDate = '2024-01-01', 
    @ToDate = '2025-01-31';


