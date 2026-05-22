import 'package:cloud_firestore/cloud_firestore.dart';

class LichHen {
  final String maLichHen;
  final String maNguoiDung;
  final String emailNguoiDung;
  final String tenNguoiDung;
  final String soDienThoai;
  final String tenDichVu;
  final DateTime thoiGianHen;
  final String ghiChu;
  final String ghiChuPhanHoi;
  final String trangThai;
  final dynamic ngayTao;
  final dynamic ngayCapNhat;

  LichHen({
    required this.maLichHen,
    required this.maNguoiDung,
    required this.tenDichVu,
    required this.thoiGianHen,
    this.emailNguoiDung = '',
    this.tenNguoiDung = '',
    this.soDienThoai = '',
    this.ghiChu = '',
    this.ghiChuPhanHoi = '',
    this.trangThai = 'CHO_DUYET',
    this.ngayTao,
    this.ngayCapNhat,
  });

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': maLichHen,
      'userId': maNguoiDung,
      'userEmail': emailNguoiDung,
      'userName': tenNguoiDung,
      'phone': soDienThoai,
      'serviceName': tenDichVu,
      'appointmentTime': thoiGianHen.toIso8601String(),
      'status': trangThai,
      'note': ghiChu,
      'replyNote': ghiChuPhanHoi,
      'createdAt': ngayTao ?? DateTime.now().toIso8601String(),
      'updatedAt': ngayCapNhat,
    };
  }

  factory LichHen.fromMap(Map<String, dynamic> map, String id) {
    return LichHen(
      maLichHen: _parseString(map['appointmentId'], macDinh: id),
      maNguoiDung: _parseString(map['userId']),
      emailNguoiDung: _parseString(map['userEmail']),
      tenNguoiDung: _parseString(map['userName']),
      soDienThoai: _parseString(map['phone']),
      tenDichVu: _parseString(map['serviceName']),
      thoiGianHen: _parseDateTime(map['appointmentTime']),
      trangThai: _parseString(map['status'], macDinh: 'CHO_DUYET'),
      ghiChu: _parseString(map['note']),
      ghiChuPhanHoi: _parseString(map['replyNote']),
      ngayTao: map['createdAt'],
      ngayCapNhat: map['updatedAt'],
    );
  }

  LichHen copyWith({
    String? maLichHen,
    String? maNguoiDung,
    String? emailNguoiDung,
    String? tenNguoiDung,
    String? soDienThoai,
    String? tenDichVu,
    DateTime? thoiGianHen,
    String? ghiChu,
    String? ghiChuPhanHoi,
    String? trangThai,
    dynamic ngayTao,
    dynamic ngayCapNhat,
  }) {
    return LichHen(
      maLichHen: maLichHen ?? this.maLichHen,
      maNguoiDung: maNguoiDung ?? this.maNguoiDung,
      emailNguoiDung: emailNguoiDung ?? this.emailNguoiDung,
      tenNguoiDung: tenNguoiDung ?? this.tenNguoiDung,
      soDienThoai: soDienThoai ?? this.soDienThoai,
      tenDichVu: tenDichVu ?? this.tenDichVu,
      thoiGianHen: thoiGianHen ?? this.thoiGianHen,
      ghiChu: ghiChu ?? this.ghiChu,
      ghiChuPhanHoi: ghiChuPhanHoi ?? this.ghiChuPhanHoi,
      trangThai: trangThai ?? this.trangThai,
      ngayTao: ngayTao ?? this.ngayTao,
      ngayCapNhat: ngayCapNhat ?? this.ngayCapNhat,
    );
  }

  bool get choDuyet => trangThai == 'CHO_DUYET' || trangThai == 'DA_DAT';

  bool get daDuyet => trangThai == 'DA_DUYET';

  bool get daHuy => trangThai == 'DA_HUY';

  bool get hoanThanh => trangThai == 'HOAN_THANH';

  String get trangThaiHienThi {
    switch (trangThai) {
      case 'CHO_DUYET':
        return 'Chờ duyệt';
      case 'DA_DAT':
        return 'Đã đặt';
      case 'DA_DUYET':
        return 'Đã duyệt';
      case 'DA_HUY':
        return 'Đã hủy';
      case 'HOAN_THANH':
        return 'Hoàn thành';
      default:
        return trangThai;
    }
  }

  static String _parseString(dynamic value, {String macDinh = ''}) {
    if (value == null) return macDinh;
    return value.toString();
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    if (value is DateTime) return value;

    if (value is Timestamp) return value.toDate();

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }
}
