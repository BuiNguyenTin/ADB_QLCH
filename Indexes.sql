CREATE INDEX IDX_HoaDon_NgayThanhToan_MaKhachHang ON HoaDon (NgayThanhToan, MaKhachHang);

CREATE INDEX IDX_HoaDon_MaPhieuDatMon ON HoaDon (MaPhieuDatMon);

CREATE INDEX IDX_ChiTietPDM_MaPhieuDatMon_MaMonAn ON ChiTietPDM (MaPhieuDatMon, MaMonAn);

CREATE INDEX IDX_PhieuDatMon_NgayDat_MaChiNhanh ON PhieuDatMon (NgayDat, MaChiNhanh);

CREATE INDEX IDX_MonAn_TenMon ON MonAn (TenMon);

CREATE INDEX IDX_KhachHang_MaKhachHang_TenKhachHang_Email ON KhachHang (MaKhachHang, HoTen, Email);

CREATE INDEX IDX_ChiNhanh_TenChiNhanh ON ChiNhanh (TenChiNhanh);

CREATE INDEX IDX_NhanVien_MaChiNhanh_BoPhan_HoTen ON NhanVien (MaChiNhanh, MaBoPhan, HoTenNV);

CREATE INDEX IDX_BoPhan_TenBoPhan ON BoPhan (TenBoPhan);



DROP INDEX IDX_HoaDon_NgayThanhToan_MaKhachHang ON HoaDon (NgayThanhToan, MaKhachHang);

DROP INDEX IDX_HoaDon_MaPhieuDatMon ON HoaDon (MaPhieuDatMon);

DROP INDEX IDX_ChiTietPDM_MaPhieuDatMon_MaMonAn ON ChiTietPDM (MaPhieuDatMon, MaMonAn);

DROP INDEX IDX_PhieuDatMon_NgayDat_MaChiNhanh ON PhieuDatMon (NgayDat, MaChiNhanh);

DROP INDEX IDX_MonAn_TenMon ON MonAn (TenMon);

DROP INDEX IDX_KhachHang_MaKhachHang_TenKhachHang_Email ON KhachHang (MaKhachHang, HoTen, Email);

DROP INDEX IDX_ChiNhanh_TenChiNhanh ON ChiNhanh (TenChiNhanh);

DROP INDEX IDX_NhanVien_MaChiNhanh_BoPhan_HoTen ON NhanVien (MaChiNhanh, MaBoPhan, HoTenNV);

DROP INDEX IDX_BoPhan_TenBoPhan ON BoPhan (TenBoPhan);
