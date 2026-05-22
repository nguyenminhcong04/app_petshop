class SanPham {
  final String maSanPham;
  final String danhMuc;
  final String giongLoai;
  final String thuongHieu;
  final String mauSac;
  final String maKho;
  final String ten;
  final int gia;
  final int tonKho;
  final String hinhAnh;
  final String moTa;
  final bool dangBan;
  final dynamic ngayTao;
  final dynamic ngayCapNhat;

  SanPham({
    required this.maSanPham,
    required this.danhMuc,
    required this.maKho,
    required this.ten,
    required this.gia,
    required this.tonKho,
    required this.hinhAnh,
    required this.moTa,
    this.giongLoai = '',
    this.thuongHieu = '',
    this.mauSac = '',
    this.dangBan = true,
    this.ngayTao,
    this.ngayCapNhat,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': maSanPham,
      'category': danhMuc,
      'breed': giongLoai,
      'brand': thuongHieu,
      'color': mauSac,
      'sku': maKho,
      'name': ten,
      'price': gia,
      'stock': tonKho,
      'imageUrl': hinhAnh,
      'description': moTa,
      'status': dangBan,
      'createdAt': ngayTao,
      'updatedAt': ngayCapNhat,
    };
  }

  factory SanPham.fromMap(Map map, String id) {
    return SanPham(
      maSanPham: _parseString(map['productId'], macDinh: id),
      danhMuc: _parseString(map['category']),
      giongLoai: _parseString(map['breed']),
      thuongHieu: _parseString(map['brand']),
      mauSac: _parseString(map['color']),
      maKho: _parseString(map['sku']),
      ten: _parseString(map['name']),
      gia: _parseInt(map['price']),
      tonKho: _parseInt(map['stock']),
      hinhAnh: _parseString(map['imageUrl']),
      moTa: _parseString(map['description']),
      dangBan: _parseBool(map['status']),
      ngayTao: map['createdAt'],
      ngayCapNhat: map['updatedAt'],
    );
  }

  SanPham copyWith({
    String? maSanPham,
    String? danhMuc,
    String? giongLoai,
    String? thuongHieu,
    String? mauSac,
    String? maKho,
    String? ten,
    int? gia,
    int? tonKho,
    String? hinhAnh,
    String? moTa,
    bool? dangBan,
    dynamic ngayTao,
    dynamic ngayCapNhat,
  }) {
    return SanPham(
      maSanPham: maSanPham ?? this.maSanPham,
      danhMuc: danhMuc ?? this.danhMuc,
      giongLoai: giongLoai ?? this.giongLoai,
      thuongHieu: thuongHieu ?? this.thuongHieu,
      mauSac: mauSac ?? this.mauSac,
      maKho: maKho ?? this.maKho,
      ten: ten ?? this.ten,
      gia: gia ?? this.gia,
      tonKho: tonKho ?? this.tonKho,
      hinhAnh: hinhAnh ?? this.hinhAnh,
      moTa: moTa ?? this.moTa,
      dangBan: dangBan ?? this.dangBan,
      ngayTao: ngayTao ?? this.ngayTao,
      ngayCapNhat: ngayCapNhat ?? this.ngayCapNhat,
    );
  }

  bool get conHang => tonKho > 0 && dangBan;

  String get trangThaiHienThi {
    if (!dangBan) return 'Ngừng bán';
    if (tonKho <= 0) return 'Hết hàng';
    return 'Còn hàng';
  }

  static String _parseString(dynamic value, {String macDinh = ''}) {
    if (value == null) return macDinh;
    return value.toString();
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.round();

    if (value is num) return value.toInt();

    final text = value
        .toString()
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();

    return int.tryParse(text) ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return true;

    if (value is bool) return value;

    final text = value.toString().toLowerCase().trim();

    if (text == 'true' || text == '1' || text == 'dang_ban') {
      return true;
    }

    if (text == 'false' || text == '0' || text == 'ngung_ban') {
      return false;
    }

    return true;
  }
}
