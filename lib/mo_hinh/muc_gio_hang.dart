import 'san_pham.dart';

class MucGioHang {
  final SanPham sanPham;
  int soLuong;

  MucGioHang({required this.sanPham, this.soLuong = 1});

  int get thanhTien {
    return sanPham.gia * soLuong;
  }

  Map<String, dynamic> toOrderItem() {
    return {
      'productId': sanPham.maSanPham,
      'name': sanPham.ten,
      'category': sanPham.danhMuc,
      'breed': sanPham.giongLoai,
      'brand': sanPham.thuongHieu,
      'color': sanPham.mauSac,
      'sku': sanPham.maKho,
      'price': sanPham.gia,
      'quantity': soLuong,
      'total': thanhTien,
      'imageUrl': sanPham.hinhAnh,
      'description': sanPham.moTa,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'product': sanPham.toMap(),
      'quantity': soLuong,
      'total': thanhTien,
    };
  }

  factory MucGioHang.fromMap(Map<String, dynamic> map) {
    final productMap = map['product'];

    return MucGioHang(
      sanPham: SanPham.fromMap(
        productMap is Map ? productMap : <String, dynamic>{},
        productMap is Map ? (productMap['productId']?.toString() ?? '') : '',
      ),
      soLuong: _parseInt(map['quantity'] ?? map['soLuong']),
    );
  }

  MucGioHang copyWith({SanPham? sanPham, int? soLuong}) {
    return MucGioHang(
      sanPham: sanPham ?? this.sanPham,
      soLuong: soLuong ?? this.soLuong,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 1;

    if (value is int) return value;

    if (value is double) return value.round();

    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 1;
  }
}
