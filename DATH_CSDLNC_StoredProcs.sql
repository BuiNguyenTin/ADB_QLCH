USE DATH_CSDLNC

-- Stored Procedures

-- Them Chi Nhanh moi
CREATE PROCEDURE ThemChinhanh
    @MaChiNhanh NVARCHAR ,
    @TenChiNhanh NVARCHAR,
    @DiaChi NVARCHAR,
	@ThanhPho NVARCHAR,
    @TGMoCua TIME ,
    @TGDongCua TIME,
    @SDT NVARCHAR,
    @BaiDoXe BIT
AS
BEGIN
    INSERT INTO ChiNhanh (MaChiNhanh, TenChiNhanh, DiaChi, ThanhPho, TGMoCua, TGDongCua, SDT, BaiDoXe)
    VALUES (@MaChiNhanh, @TenChiNhanh, @DiaChi, @ThanhPho, @TGMoCua, @TGDongCua, @SDT, @BaiDoXe);
END;

-- Them Thuc Don Chi Nhanh
CREATE PROCEDURE ThemThucDonChiNhanh
	@MaThucDon NVARCHAR,
	@MaChiNhanh NVARCHAR,
	@MaMonAn INT,
	@TrangThai BIT
AS
BEGIN
	INSERT INTO ThucDonChiNhanh(MaThucDon, MaChiNhanh, MaMonAn, TrangThai)
	VALUES (@MaThucDon, @MaChiNhanh, @MaMonAn, @TrangThai);
END

-- Them Khach hang moi
CREATE PROCEDURE ThemKhachHang
    @MaKhachHang NVARCHAR,
	@HoTen NVARCHAR,
    @SDT NVARCHAR,
    @Email NVARCHAR,
    @CCCD NVARCHAR,
    @GioiTinh NVARCHAR
AS
BEGIN
    INSERT INTO KhachHang(MaKhachHang, HoTen, SDT, Email, CCCD, GioiTinh)
    VALUES (@MaKhachHang, @HoTen, @SDT, @Email, @CCCD, @GioiTinh);
END;

-- Them The thanh vien
CREATE PROCEDURE ThemTheThanhVien
    @MaThe NVARCHAR,
    @MaKhachHang NVARCHAR,
    @LoaiThe NVARCHAR,
    @NgayLap DATE,
    @DiemTichLuy INT
AS
BEGIN
    INSERT INTO TheThanhVien (MaThe, MaKhachHang, LoaiThe, NgayLap, DiemTichLuy)
    VALUES (@MaThe, @MaKhachHang, @LoaiThe, @NgayLap, @DiemTichLuy);
END;

-- Them Nhan vien
CREATE PROCEDURE ThemNhanVien
	@MaNhanVien NVARCHAR,
    @HoTenNV NVARCHAR,
    @NgaySinh DATE,
    @GioiTinh NVARCHAR,
    @Luong DECIMAL,
    @MaBoPhan INT
AS
BEGIN
    INSERT INTO NhanVien(MaNhanVien, HoTenNV, NgaySinh, GioiTinh, Luong, MaBoPhan)
    VALUES (@MaNhanVien, @HoTenNV, @NgaySinh, @GioiTinh, @Luong, @MaBoPhan);
END;


-- Them Phieu Dat Mon
CREATE PROCEDURE ThemPhieuDatMon
    @MaPhieuDatMon NVARCHAR,
    @MaChiNhanh NVARCHAR,
    @MaNhanVien NVARCHAR,
	@NgayDat DATE,
	@GioDen DATE,
	@NgayLap DATE,
    @Ban INT,
    @SoLuongKhach DECIMAL,
	@TinhTrangXacNhan BIT,
	@GhiChu NVARCHAR
AS
BEGIN
    INSERT INTO PhieuDatMon(MaPhieuDatMon, MaChiNhanh, MaNhanVien, NgayDat, GioDen, NgayLap, Ban, SoLuongKhach, TinhTrangXacNhan, GhiChu)
    VALUES (@MaPhieuDatMon, @MaChiNhanh, @MaNhanVien, @NgayDat, @GioDen, @NgayLap, @Ban, @SoLuongKhach, @TinhTrangXacNhan, @GhiChu);
END;


-- Them Mon An
CREATE PROCEDURE ThemMonAn
    @MaMonAn NVARCHAR,
    @TenMon NVARCHAR,
    @GiaHienTai DECIMAL,
    @DanhMuc NVARCHAR
AS
BEGIN
    INSERT INTO MonAn(MaMonAn, TenMon, GiaHienTai, DanhMuc)
    VALUES (@MaMonAn, @TenMon, @GiaHienTai, @DanhMuc);
END;

-- Them Bo Phan
CREATE PROCEDURE ThemBoPhan
	@MaBoPhan NVARCHAR,
	@TenBoPhan NVARCHAR
AS
BEGIN
	INSERT INTO BoPhan(MaBoPhan, TenBoPhan)
	VALUES (@MaBoPhan, @TenBoPhan);
END

--Them Chi Nhanh Nhan Vien
CREATE PROCEDURE ThemChiNhanhNhanVien
	@MaNhanVien NVARCHAR,
	@MaChiNhanh NVARCHAR,
	@NgayVaoLam DATE,
	@NgayNghiViec DATE
AS
BEGIN
	INSERT INTO ChiNhanhNhanVien(MaNhanVien, MaChiNhanh, NgayVaoLam, NgayNghiViec)
	VALUES (@MaNhanVien, @MaChiNhanh, @NgayVaoLam, @NgayNghiViec);
END

--