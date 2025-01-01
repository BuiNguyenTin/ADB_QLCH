import random
from faker import Faker
import pandas as pd
from datetime import datetime, timedelta

fake = Faker()

# Số lượng records
num_khachhang = 100000
num_nhanvien = 5000
num_chinhanh = 20
num_thanhpho = 40
num_monan = 30
num_bophan = 10
num_thucdon = 30
num_danhgia = 20000
num_phieudatmon = 30000
num_chitietphieudatmon = 50000
num_thethanhvien = 100000

# Ngày hiện tại
current_date = datetime.now()

# Hàm tạo danh sách các records với các thuộc tính được điều chỉnh
def generate_data():
    start_index = 1

    # Chi nhánh
    chinhanh_data = []
    for i in range(start_index, start_index + num_chinhanh):
        lastDigit = random.randrange(100, 1000)
        firstDigit = random.randrange(1000, 10000)
        chinhanh = {
            'MACHINHANH': f'CN{i:02d}',
            'TENCHINHANH': fake.name(),
            'DIACHI': fake.address(),
            'THANHPHO': fake.city(),
            'TGMOCUA': fake.time(),
            'TGDONGCUA': fake.time(),
            'SDT': f'0{firstDigit}{i:02d}{lastDigit}',
            'BAIDOXE': fake.boolean(chance_of_getting_true=50),
        }
        chinhanh_data.append(chinhanh)

    # Bộ phận
    bophan_data = []
    for i in range(start_index, start_index + num_bophan):
        bophan = {
            'MABOPHAN': f'BP{i:02d}',
            'TENBOPHAN': random.choice(['Đầu bếp', 'Phục vụ', 'Thu ngân', 'Quản lý']),
        }
        bophan_data.append(bophan)

    # Nhân viên
    nhanvien_data = []
    for i in range(start_index, start_index + num_nhanvien):
        lastDigit = random.randrange(100, 1000)
        firstDigit = random.randrange(10, 100)
        nhanvien = {
            'MANHANVIEN': f'NV{i:06d}',
            'HOTENNV': fake.name(),
            'NGAYSINH': fake.date_of_birth(),
            'GIOITINH': random.choice(['NAM', 'NỮ']),
            'LUONG': fake.pyfloat(min_value=1000000, max_value=20000000, right_digits=2),
            'MABOPHAN': random.choice(bophan_data)['MABOPHAN'],
            'MACHINHANH': random.choice(chinhanh_data)['MACHINHANH'],
        }
        nhanvien_data.append(nhanvien)
    
    # MonAn
    monan_data = []
    ten_monan_list = [ 'Sushi cá hồi', 'Sushi cá ngừ', 'Sushi lươn', 'Sushi tôm', 'Sushi mực', 'Sushi bạch tuộc', 'Sushi trứng cá hồi', 'Sushi trứng gà', 'Sushi cá trích ép trứng', 'Sushi sò đỏ',
                      'Maki cá hồi', 'Maki cá ngừ', 'Maki dưa chuột', 'Maki bơ', 'California Roll', 'Spider Roll', 'Dragon Roll', 'Rainbow Roll', 'Philadelphia Roll', 'Spicy Tuna Roll',
                      'Sashimi cá hồi', 'Sashimi cá ngừ', 'Sashimi sò điệp', 'Sashimi cá cam', 'Sashimi bạch tuộc', 'Sashimi cá kiếm',
                      'Tempura (Tôm, rau củ chiên giòn)', 'Miso Soup (Súp miso)', 'Edamame (Đậu nành hấp muối)', 'Gyoza (Hành phi chiên giòn)']
    ten_danhmuc_list = [ 'Sushi', 'Sushi', 'Sushi', 'Sushi', 'Sushi', 'Sushi', 'Sushi', 'Sushi', 'Sushi', 'Sushi',
                      'Maki', 'Maki', 'Maki', 'Maki', 'Maki', 'Maki', 'Maki', 'Maki', 'Maki', 'Maki',
                      'Sashimi', 'Sashimi', 'Sashimi', 'Sashimi', 'Sashimi', 'Sashimi',
                      'Tempura', 'Miso Soup', 'Món ăn kèm', 'Món ăn kèm']
    for i in range(len(ten_monan_list)):
        monan = {
            'MAMONAN': f'MA{i+1:06d}',
            'TENMONAN': ten_monan_list[i],
            'GIAHIENTAI': fake.pyfloat(min_value=20000, max_value=300000, right_digits=2),
            'DANHMUC': ten_danhmuc_list[i],
            'HOTROGIAO': fake.boolean(chance_of_getting_true=50),
        }
        monan_data.append(monan)


    # Khách hàng
    khachhang_data = []
    ssn_list = [fake.ssn() for _ in range(10000)]
    for i in range(start_index, start_index + num_khachhang):
        lastDigit = random.randrange(100, 1000)
        khachhang = {
            'MAKHACHHANG': f'KH{i:06d}',
            'HOTEN': fake.name(),
            'SODIENTHOAIBN': f'0{i:06d}{lastDigit}',
            'EMAIL': fake.email(),
            'CCCD': random.choice(ssn_list),
            'GIOITINH': random.choice(['NAM', 'NỮ']),
        }
        khachhang_data.append(khachhang)

    # Thực đơn
    thucdon_data = []
    for i in range(start_index, start_index + num_thucdon):
        
        thucdon = {
            'MATHUCDON': f'TD{i:04d}',
            'MACHINHANH': random.choice(chinhanh_data)['MACHINHANH'],
            'MAMONAN': random.choice(monan_data)['MAMONAN'],
            'TRANGTHAI': fake.boolean(chance_of_getting_true=50),
        }
        thucdon_data.append(thucdon)

    # Thẻ thành viên
    thethanhvien_data = []
    for i, khachhang in enumerate(khachhang_data, start=start_index):
        thethanhvien = {
            'MATHE': f'{i:06d}',
            'MAKHACHHANG': khachhang.get('MAKHACHHANG'),
            'MANHANVIEN': random.choice(nhanvien_data)['MANHANVIEN'],
            'LOAITHE': random.choice(['MEMBER', 'SILVER', 'GOLD']),
            'NGAYLAP': fake.date_this_decade(),
            'DIEMTICHLUY': fake.random_int(min=0, max=1000),
        }
        thethanhvien_data.append(thethanhvien)

    # Chi nhánh nhân viên
    chinhanhnhanvien_data = []
    for i in range(start_index, start_index + num_nhanvien):
        nhanvien = random.choice(nhanvien_data)
        chinhanh = random.choice(chinhanh_data)
        chinhanhnhanvien = {
            'MANHANVIEN': nhanvien['MANHANVIEN'],
            'MACHINHANH': chinhanh['MACHINHANH'],
            'NGAYVAOLAM': fake.date_this_decade(),
            'GHICHUKHDT': fake.sentence() if random.choice([True, False]) else None,
            'NGAYNGHIVIEC': fake.date_this_decade() if random.choice([True, False]) else None,
        }
        chinhanhnhanvien_data.append(chinhanhnhanvien)
        
    # Phiếu đặt món
    phieudatmon_data = []
    for i in range(start_index, start_index + num_phieudatmon):
        phieudatmon = {
            'MAPHIEUDATMON': f'PDM{i:05d}',
            'MACHINHANH': random.choice(chinhanh_data)['MACHINHANH'],
            'MANHANVIEN': random.choice(nhanvien_data)['MANHANVIEN'],
            'NGAYDAT': fake.date_this_decade(),
            'GIODEN': fake.time(),
            'NGAYLAP': fake.date_this_decade(),
            'BAN': fake.random_int(min=1, max=50),
            'SOLUONGKHACH': fake.random_int(min=1, max=20),
            'TINHTRANGXACNHAN': fake.boolean(chance_of_getting_true=50),
            'GHICHU': fake.sentence() if random.choice([True, False]) else None,
        }
        phieudatmon_data.append(phieudatmon)
    
    # Hóa đơn
    hoadon_data = []
    for i, phieudatmon in enumerate(phieudatmon_data, start=start_index):
        tong_tien = round(random.uniform(20, 200), 2)
        giam_gia = round(random.uniform(0, min(tong_tien * 0.3, 30)), 2)
        hoadon = {
            'MAHOADON': f'HD{i:05d}',
            'MAPHIEUDATMON': phieudatmon.get('MAPHIEUDATMON'),
            'MANHANVIEN': random.choice(nhanvien_data)['MANHANVIEN'],
            'MAKHACHHANG': khachhang_data[random.randint(1, 29999)]['MAKHACHHANG'],
            "TONGTIEN": tong_tien,
            "TIENGIAMGIA": giam_gia,
            "TIENTHANHTOAN": tong_tien - giam_gia,
            'NGAYTHANHTOAN': phieudatmon.get('NGAYDAT'),
            'PHUONGTHUCTHANHTOAN': random.choice(['TIỀN MẶT', 'THẺ']),
        }
        hoadon_data.append(hoadon)
        
    # Đánh giá
    danhgia_data = []
    for i in range(start_index, start_index + num_danhgia):
        hoadon = random.choice(hoadon_data)
        danhgia = {
            'MADANHGIA': f'DG{i:05d}',
            'MAKHACHHANG': khachhang_data[random.randint(1, 29999)]['MAKHACHHANG'],
            'HOADON': hoadon['MAHOADON'],
            'DIEMPHUCVU': fake.random_int(min=1, max=5),
            'DIEMVITRI': fake.random_int(min=1, max=5),
            'DIEMCHATLUONGMONAN': fake.random_int(min=1, max=5),
            'DIEMGIAGIA': fake.random_int(min=1, max=5),
            'DIEMKHONGGIAN': fake.random_int(min=1, max=5),
            'TGTRUYCAP': fake.date_this_decade(),
            'BINHLUAN': fake.sentence() if random.choice([True, False]) else None,
        }
        danhgia_data.append(danhgia)
        
    # Chi tiết phiếu đặt món
    chitietpdm_data = []
    for i in range(start_index, start_index + num_chitietphieudatmon):
        chitietpdm = {
            'MACHITIETPDM': f'CTPDM{i:05d}',
            'MAPHIEUDATMON': random.choice(phieudatmon_data)['MAPHIEUDATMON'],
            'MAMONAN': random.choice(monan_data)['MAMONAN'],
            'SOLUONG': fake.random_int(min=1, max=5),
            'DATTRUOC': fake.boolean(chance_of_getting_true=50),
        }
        chitietpdm_data.append(chitietpdm)

    return chinhanh_data, bophan_data, nhanvien_data, monan_data, khachhang_data, thucdon_data, thethanhvien_data, chinhanhnhanvien_data, danhgia_data, phieudatmon_data, chitietpdm_data, hoadon_data

# Lưu dữ liệu vào các file Excel
import pandas as pd

def save_to_excel(chinhanh_data, bophan_data, nhanvien_data, monan_data, khachhang_data, thucdon_data, thethanhvien_data, chinhanhnhanvien_data, danhgia_data, phieudatmon_data, chitietpdm_data, hoadon_data
):
    # Create DataFrames
    chinhanh_df = pd.DataFrame(chinhanh_data)
    bophan_df = pd.DataFrame(bophan_data)
    nhanvien_df = pd.DataFrame(nhanvien_data)
    monan_df = pd.DataFrame(monan_data)
    khachhang_df = pd.DataFrame(khachhang_data)
    thucdon_df = pd.DataFrame(thucdon_data)
    thethanhvien_df = pd.DataFrame(thethanhvien_data)
    chinhanhnhanvien_df = pd.DataFrame(chinhanhnhanvien_data)
    danhgia_df = pd.DataFrame(danhgia_data)
    phieudatmon_df = pd.DataFrame(phieudatmon_data)
    chitietpdm_df = pd.DataFrame(chitietpdm_data)
    hoadon_df = pd.DataFrame(hoadon_data)


    # Save DataFrames to Excel with uppercase sheet names
    with pd.ExcelWriter('QuanlyNhaHang.xlsx', engine='openpyxl') as writer:
        chinhanh_df.to_excel(writer, sheet_name='CHINHANH', index=False)
        bophan_df.to_excel(writer, sheet_name='BOPHAN', index=False)
        nhanvien_df.to_excel(writer, sheet_name='NHANVIEN', index=False)
        monan_df.to_excel(writer, sheet_name='MONAN', index=False)
        khachhang_df.to_excel(writer, sheet_name='KHACHHANG', index=False)
        thucdon_df.to_excel(writer, sheet_name='THUCDON', index=False)
        thethanhvien_df.to_excel(writer, sheet_name='THETHANHVIEN', index=False)
        chinhanhnhanvien_df.to_excel(writer, sheet_name='CHINHANHNHANVIEN', index=False)
        danhgia_df.to_excel(writer, sheet_name='DANHGIA', index=False)
        phieudatmon_df.to_excel(writer, sheet_name='PHIEUDATMON', index=False)
        chitietpdm_df.to_excel(writer, sheet_name='CHITIETPDM', index=False)
        hoadon_df.to_excel(writer, sheet_name='HOADON', index=False)

        

# Tạo dữ liệu và lưu vào file Excel
chinhanh_data, bophan_data, nhanvien_data, monan_data, khachhang_data, thucdon_data, thethanhvien_data, chinhanhnhanvien_data, danhgia_data, phieudatmon_data, chitietpdm_data, hoadon_data = generate_data()
save_to_excel(chinhanh_data, bophan_data, nhanvien_data, monan_data, khachhang_data, thucdon_data, thethanhvien_data, chinhanhnhanvien_data, danhgia_data, phieudatmon_data, chitietpdm_data, hoadon_data)