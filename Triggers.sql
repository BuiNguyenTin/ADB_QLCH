-- Trigger: Cập nhật điểm tích lũy khi thêm hóa đơn
CREATE TRIGGER CapNhatDiemTichLuy
ON HoaDon
AFTER INSERT
AS
BEGIN
    -- Cập nhật điểm tích lũy
    UPDATE TheThanhVien
    SET DiemTichLuy = DiemTichLuy + FLOOR(INSERTED.TienThanhToan / 100000)
    FROM TheThanhVien
    INNER JOIN KhachHang ON TheThanhVien.MaKhachHang = KhachHang.MaKhachHang
    INNER JOIN INSERTED ON KhachHang.MaKhachHang = INSERTED.MaKhachHang;
END;


-- Trigger: Cập nhật loại thẻ theo điểm tích lũy và thời gian
DROP TRIGGER CapNhatLoaiThe
GO
CREATE TRIGGER CapNhatLoaiThe
ON HoaDon
AFTER INSERT
AS
BEGIN
    -- Cập nhật loại thẻ dựa trên điểm tích lũy và ngày lập thẻ
    UPDATE TheThanhVien
    SET LoaiThe = 
        CASE 
            -- Nếu điểm >= 100 trong vòng 1 năm kể từ ngày đạt Silver hoặc Gold
            WHEN DiemTichLuy >= 100 AND DATEDIFF(YEAR, NgayLap, GETDATE()) <= 1 THEN 
                'GOLD'
            -- Nếu điểm >= 50 và nhỏ hơn 100 trong vòng 1 năm kể từ ngày đạt Silver
            WHEN DiemTichLuy >= 50 AND DATEDIFF(YEAR, NgayLap, GETDATE()) <= 1 THEN 
                'SILVER'
            -- Nếu điểm < 50 trong vòng 1 năm, hạ xuống Member
            WHEN DiemTichLuy < 50 AND DATEDIFF(YEAR, NgayLap, GETDATE()) <= 1 THEN 
                'MEMBER'
            ELSE 
                LoaiThe -- Giữ nguyên nếu không có thay đổi
        END
    FROM TheThanhVien
    INNER JOIN KhachHang ON TheThanhVien.MaKhachHang = KhachHang.MaKhachHang
    INNER JOIN INSERTED ON KhachHang.MaKhachHang = INSERTED.MaKhachHang;
END;

GO
-- Trigger: Ngăn chặn đặt bàn trùng thời gian và số bàn
CREATE TRIGGER KiemTraDatBanTrung
ON PhieuDatMon
INSTEAD OF INSERT
AS
BEGIN
    -- Kiểm tra trùng lặp bàn, thời gian, và chi nhánh
    IF EXISTS (
        SELECT 1
        FROM PhieuDatMon PDM
        INNER JOIN INSERTED I ON 
            PDM.Ban = I.Ban AND 
            PDM.MaChiNhanh = I.MaChiNhanh AND
            (
                -- Thời gian đến trùng nhau
                (I.GioDen >= PDM.GioDen AND I.GioDen <= DATEADD(HOUR, 2, PDM.GioDen)) OR 
                (PDM.GioDen >= I.GioDen AND PDM.GioDen <= DATEADD(HOUR, 2, I.GioDen))
            )
    )
    BEGIN
        -- Hủy giao dịch và thông báo lỗi
        RAISERROR ('Bàn đã được đặt trong khoảng thời gian này tại chi nhánh này.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- Thêm dữ liệu nếu không trùng
        INSERT INTO PhieuDatMon (MaPhieuDatMon, MaChiNhanh, MaNhanVien, NgayDat, GioDen, NgayLap, Ban, SoLuongKhach, TinhTrangXacNhan, GhiChu)
        SELECT MaPhieuDatMon, MaChiNhanh, MaNhanVien, NgayDat, GioDen, NgayLap, Ban, SoLuongKhach, TinhTrangXacNhan, GhiChu
        FROM INSERTED;
    END
END;

GO

--TEST
DELETE FROM HoaDon
 WHERE MaHoaDon = 'HD99999';

-- Thêm dữ liệu vào bảng HoaDon để kiểm tra trigger
INSERT INTO HoaDon (MaHoaDon,MaNhanVien, MaKhachHang, TongTien, TienGiamGia, TienThanhToan,NgayThanhToan, PhuongThucThanhToan)
VALUES ('HD99999','NV000001', 'KH000002', 2000000, 200000, 1800000, '12/1/2025', 'Cash');

-- Kiểm tra điểm tích lũy của khách hàng sau khi thêm hóa đơn
SELECT * FROM TheThanhVien WHERE MaKhachHang = 'KH000002';

SELECT * FROM HoaDon WHERE MaKhachHang = 'KH000002';

SELECT * FROM KhachHang WHERE MaKhachHang = 'KH000002';

GO

--TEST
DELETE FROM PhieuDatMon
 WHERE MaPhieuDatMon = 'PDM001';

-- Thêm đặt bàn đầu tiên
INSERT INTO PhieuDatMon (MaPhieuDatMon, MaChiNhanh, MaNhanVien, NgayDat, GioDen, NgayLap, Ban, SoLuongKhach, TinhTrangXacNhan, GhiChu)
VALUES ('PDM001', 'CN01', 'NV000001', '2025-01-01', '12:00:00', '2025-01-01', 5, 4, 1, 'Ghi chú 1');

-- Thêm đặt bàn trùng thời gian và bàn -- Lệnh này sẽ bị từ chối và thông báo lỗi.
INSERT INTO PhieuDatMon (MaPhieuDatMon, MaChiNhanh, MaNhanVien, NgayDat, GioDen, NgayLap, Ban, SoLuongKhach, TinhTrangXacNhan, GhiChu)
VALUES ('PDM002', 'CN01', 'NV000002', '2025-01-01', '12:30:00', '2025-01-01', 5, 2, 1, 'Ghi chú 2');

GO

-- Trigger: Ngăn chặn giá món ăn không hợp lệ
CREATE TRIGGER KiemTraGiaMonAn
ON MonAn
INSTEAD OF UPDATE
AS
BEGIN
    -- Kiểm tra nếu giá cập nhật không hợp lệ (nhỏ hơn hoặc bằng 0)
    IF EXISTS (
        SELECT 1
        FROM INSERTED
        WHERE GiaHienTai <= 0
    )
    BEGIN
        -- Hủy giao dịch và thông báo lỗi
        RAISERROR ('Giá món ăn phải lớn hơn 0.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- Thực hiện cập nhật nếu giá hợp lệ
        UPDATE MonAn
        SET TenMon = INSERTED.TenMon,
            GiaHienTai = INSERTED.GiaHienTai,
            DanhMuc = INSERTED.DanhMuc,
            HoTroGiao = INSERTED.HoTroGiao
        FROM MonAn
        INNER JOIN INSERTED ON MonAn.MaMonAn = INSERTED.MaMonAn;
    END
END;

GO
--TEST
DELETE FROM MonAn
 WHERE MaMonAn = 'MA001';

-- Thêm món ăn để kiểm tra
INSERT INTO MonAn (MaMonAn, TenMon, GiaHienTai, DanhMuc, HoTroGiao)
VALUES ('MA001', 'Sushi Cá Hồi', 100000, 'Sashimi Combo', 1);

-- Thử cập nhật giá hợp lệ
UPDATE MonAn
SET GiaHienTai = 120000
WHERE MaMonAn = 'MA001';

-- Thử cập nhật giá không hợp lệ (giá âm)
UPDATE MonAn
SET GiaHienTai = -50000
WHERE MaMonAn = 'MA001';
-- Lệnh này sẽ bị từ chối và thông báo lỗi.

-- Kiểm tra dữ liệu sau khi thử nghiệm
SELECT * FROM MonAn WHERE MaMonAn = 'MA001';
