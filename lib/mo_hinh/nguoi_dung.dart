class NguoiDung {
  final String uid;
  final String hoTen;
  final String email;
  final String soDienThoai;
  final String diaChi;
  final String vaiTro;
  final String hangThanhVien;
  final int diemTichLuy;

  NguoiDung({
    required this.uid,
    required this.hoTen,
    required this.email,
    this.soDienThoai = '',
    this.diaChi = '',
    this.vaiTro = 'customer',
    this.hangThanhVien = 'normal',
    this.diemTichLuy = 0,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'fullName': hoTen,
        'email': email,
        'phone': soDienThoai,
        'address': diaChi,
        'role': vaiTro,
        'rank': hangThanhVien,
        'points': diemTichLuy,
        'createdAt': DateTime.now().toIso8601String(),
      };

  factory NguoiDung.fromMap(Map<String, dynamic> map) => NguoiDung(
        uid: map['uid'] ?? '',
        hoTen: map['fullName'] ?? '',
        email: map['email'] ?? '',
        soDienThoai: map['phone'] ?? '',
        diaChi: map['address'] ?? '',
        vaiTro: map['role'] ?? 'customer',
        hangThanhVien: map['rank'] ?? 'normal',
        diemTichLuy: map['points'] ?? 0,
      );
}
