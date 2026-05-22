class DonHang {
  final String maDonHang;
  final String maNguoiDung;
  final String emailNguoiDung;
  final String tenNguoiDung;
  final String soDienThoai;
  final String diaChiGiaoHang;
  final List<Map<String, dynamic>> matHang;
  final int tongTien;
  final String phuongThucThanhToan;
  final String trangThaiDonHang;
  final String trangThaiThanhToan;
  final String ghiChu;
  final String ngayTao;
  final String? ngayCapNhat;

  DonHang({
    required this.maDonHang,
    required this.maNguoiDung,
    required this.matHang,
    required this.tongTien,
    this.emailNguoiDung = '',
    this.tenNguoiDung = '',
    this.soDienThoai = '',
    this.diaChiGiaoHang = '',
    this.phuongThucThanhToan = 'COD',
    this.trangThaiDonHang = 'CHO_XAC_NHAN',
    this.trangThaiThanhToan = 'CHUA_THANH_TOAN',
    this.ghiChu = '',
    String? ngayTao,
    this.ngayCapNhat,
  }) : ngayTao = ngayTao ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'orderId': maDonHang,
      'userId': maNguoiDung,
      'userEmail': emailNguoiDung,
      'userName': tenNguoiDung,
      'phone': soDienThoai,
      'address': diaChiGiaoHang,
      'items': matHang,
      'totalAmount': tongTien,
      'paymentMethod': phuongThucThanhToan,
      'orderStatus': trangThaiDonHang,
      'paymentStatus': trangThaiThanhToan,
      'note': ghiChu,
      'createdAt': ngayTao,
      'updatedAt': ngayCapNhat,
    };
  }

  factory DonHang.fromMap(Map<String, dynamic> map) {
    return DonHang(
      maDonHang: map['orderId']?.toString() ?? '',
      maNguoiDung: map['userId']?.toString() ?? '',
      emailNguoiDung: map['userEmail']?.toString() ?? '',
      tenNguoiDung: map['userName']?.toString() ?? '',
      soDienThoai: map['phone']?.toString() ?? '',
      diaChiGiaoHang: map['address']?.toString() ?? '',
      matHang: _parseMatHang(map['items']),
      tongTien: _parseInt(map['totalAmount']),
      phuongThucThanhToan: map['paymentMethod']?.toString() ?? 'COD',
      trangThaiDonHang: map['orderStatus']?.toString() ?? 'CHO_XAC_NHAN',
      trangThaiThanhToan: map['paymentStatus']?.toString() ?? 'CHUA_THANH_TOAN',
      ghiChu: map['note']?.toString() ?? '',
      ngayTao: map['createdAt']?.toString(),
      ngayCapNhat: map['updatedAt']?.toString(),
    );
  }

  DonHang copyWith({
    String? maDonHang,
    String? maNguoiDung,
    String? emailNguoiDung,
    String? tenNguoiDung,
    String? soDienThoai,
    String? diaChiGiaoHang,
    List<Map<String, dynamic>>? matHang,
    int? tongTien,
    String? phuongThucThanhToan,
    String? trangThaiDonHang,
    String? trangThaiThanhToan,
    String? ghiChu,
    String? ngayTao,
    String? ngayCapNhat,
  }) {
    return DonHang(
      maDonHang: maDonHang ?? this.maDonHang,
      maNguoiDung: maNguoiDung ?? this.maNguoiDung,
      emailNguoiDung: emailNguoiDung ?? this.emailNguoiDung,
      tenNguoiDung: tenNguoiDung ?? this.tenNguoiDung,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      diaChiGiaoHang: diaChiGiaoHang ?? this.diaChiGiaoHang,
      matHang: matHang ?? this.matHang,
      tongTien: tongTien ?? this.tongTien,
      phuongThucThanhToan: phuongThucThanhToan ?? this.phuongThucThanhToan,
      trangThaiDonHang: trangThaiDonHang ?? this.trangThaiDonHang,
      trangThaiThanhToan: trangThaiThanhToan ?? this.trangThaiThanhToan,
      ghiChu: ghiChu ?? this.ghiChu,
      ngayTao: ngayTao ?? this.ngayTao,
      ngayCapNhat: ngayCapNhat ?? this.ngayCapNhat,
    );
  }

  static List<Map<String, dynamic>> _parseMatHang(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            }

            if (item is Map) {
              return Map<String, dynamic>.from(item);
            }

            return <String, dynamic>{};
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return [];
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.round();

    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }
}
