CREATE NONCLUSTERED  INDEX IDX_HoaDon_NgayThanhToan_MaKhachHang ON HoaDon (NgayThanhToan DESC, MaKhachHang DESC);

CREATE NONCLUSTERED  INDEX IDX_HoaDon_MaPhieuDatMon ON HoaDon (MaPhieuDatMon DESC);

CREATE NONCLUSTERED  INDEX IDX_ChiTietPDM_MaPhieuDatMon_MaMonAn ON ChiTietPDM (MaPhieuDatMon DESC, MaMonAn DESC);

CREATE NONCLUSTERED  INDEX IDX_PhieuDatMon_NgayDat_MaChiNhanh ON PhieuDatMon (NgayDat DESC, MaChiNhanh DESC);

CREATE NONCLUSTERED  INDEX IDX_MonAn_TenMon ON MonAn (TenMon DESC);

CREATE NONCLUSTERED  INDEX IDX_KhachHang_MaKhachHang_TenKhachHang_Email ON KhachHang (MaKhachHang DESC, HoTen DESC, Email DESC);

CREATE NONCLUSTERED  INDEX IDX_ChiNhanh_TenChiNhanh ON ChiNhanh (TenChiNhanh DESC);

CREATE NONCLUSTERED  INDEX IDX_NhanVien_MaChiNhanh_BoPhan_HoTen ON NhanVien (MaChiNhanh DESC, MaBoPhan DESC, HoTenNV DESC);

CREATE NONCLUSTERED  INDEX IDX_BoPhan_TenBoPhan ON BoPhan (TenBoPhan DESC);

CREATE NONCLUSTERED  INDEX IDX_TheThanhVien_LoaiThe_DiemTichLuy ON TheThanhVien(LoaiThe DESC, DiemTichLuy DESC);

CREATE NONCLUSTERED INDEX IDX_KhachHang_MaKhachHang ON KhachHang(MaKhachHang);
CREATE NONCLUSTERED INDEX IDX_TheThanhVien_MaKhachHang ON TheThanhVien(MaKhachHang);
CREATE NONCLUSTERED INDEX IDX_TheThanhVien_LoaiThe_DiemTichLy ON TheThanhVien(LoaiThe, DiemTichLuy);


DROP NONCLUSTERED INDEX IDX_KhachHang_MaKhachHang ON KhachHang;
drop NONCLUSTERED INDEX IDX_TheThanhVien_MaKhachHang ON TheThanhVien;
DROP NONCLUSTERED INDEX IDX_TheThanhVien_LoaiThe_DiemTichLy ON TheThanhVien;



DROP INDEX IDX_HoaDon_NgayThanhToan_MaKhachHang ON HoaDon;

DROP INDEX IDX_HoaDon_MaPhieuDatMon ON HoaDon;

DROP INDEX IDX_ChiTietPDM_MaPhieuDatMon_MaMonAn ON ChiTietPDM;

DROP INDEX IDX_PhieuDatMon_NgayDat_MaChiNhanh ON PhieuDatMon;

DROP INDEX IDX_MonAn_TenMon ON MonAn;

DROP INDEX IDX_KhachHang_MaKhachHang_TenKhachHang_Email ON KhachHang;

DROP INDEX IDX_ChiNhanh_TenChiNhanh ON ChiNhanh;

DROP INDEX IDX_NhanVien_MaChiNhanh_BoPhan_HoTen ON NhanVien;

DROP INDEX IDX_BoPhan_TenBoPhan ON BoPhan;

DROP INDEX IDX_TheThanhVien_LoaiThe_DiemTichLuy ON TheThanhVien;

