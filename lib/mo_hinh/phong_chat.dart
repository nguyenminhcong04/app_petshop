class PhongChat {
  final String maPhong;
  final String maNguoiDung;
  final String tenNguoiDung;
  final DateTime thoiGianTao;
  final bool daDong;

  PhongChat({
    required this.maPhong,
    required this.maNguoiDung,
    required this.tenNguoiDung,
    required this.thoiGianTao,
    this.daDong = false,
  });

  Map<String, dynamic> toMap() => {
    'roomId': maPhong,
    'userId': maNguoiDung,
    'userName': tenNguoiDung,
    'createdAt': thoiGianTao.toIso8601String(),
    'closed': daDong,
  };

  factory PhongChat.fromMap(Map<String, dynamic> map, String id) => PhongChat(
    maPhong: map['roomId'] ?? id,
    maNguoiDung: map['userId'] ?? '',
    tenNguoiDung: map['userName'] ?? '',
    thoiGianTao: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    daDong: map['closed'] ?? false,
  );
}

class TinNhan {
  final String maTinNhan;
  final String maPhong;
  final String maGuiTu;
  final String noiDung;
  final DateTime thoiGian;
  final String vaiTro;

  TinNhan({
    required this.maTinNhan,
    required this.maPhong,
    required this.maGuiTu,
    required this.noiDung,
    required this.thoiGian,
    required this.vaiTro,
  });

  Map<String, dynamic> toMap() => {
    'messageId': maTinNhan,
    'roomId': maPhong,
    'sender': maGuiTu,
    'content': noiDung,
    'timestamp': thoiGian.toIso8601String(),
    'role': vaiTro,
  };

  factory TinNhan.fromMap(Map<String, dynamic> map, String id) => TinNhan(
    maTinNhan: map['messageId'] ?? id,
    maPhong: map['roomId'] ?? '',
    maGuiTu: map['sender'] ?? '',
    noiDung: map['content'] ?? '',
    thoiGian: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    vaiTro: map['role'] ?? 'customer',
  );
}
