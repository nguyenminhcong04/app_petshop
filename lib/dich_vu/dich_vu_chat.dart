import 'package:cloud_firestore/cloud_firestore.dart';
import '../mo_hinh/phong_chat.dart';

class DichVuChat {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> taoPhongChatVaGuiThongBao(String uid, String tenKhach) async {
    final maPhong = 'CHAT_${DateTime.now().millisecondsSinceEpoch}';

    final phongChat = PhongChat(
      maPhong: maPhong,
      maNguoiDung: uid,
      tenNguoiDung: tenKhach,
      thoiGianTao: DateTime.now(),
      daDong: false,
    );

    await _db.collection('chat_rooms').doc(maPhong).set(phongChat.toMap());

    return maPhong;
  }

  Stream<List<TinNhan>> layTinNhanPhong(String maPhong) {
    return _db
        .collection('chat_rooms')
        .doc(maPhong)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TinNhan.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<void> guiTinNhan(
    String maPhong,
    String maGuiTu,
    String noiDung,
    String vaiTro,
  ) async {
    final maTinNhan = 'msg_${DateTime.now().millisecondsSinceEpoch}';

    final tinNhan = TinNhan(
      maTinNhan: maTinNhan,
      maPhong: maPhong,
      maGuiTu: maGuiTu,
      noiDung: noiDung,
      thoiGian: DateTime.now(),
      vaiTro: vaiTro,
    );

    await _db
        .collection('chat_rooms')
        .doc(maPhong)
        .collection('messages')
        .doc(maTinNhan)
        .set(tinNhan.toMap());
  }

  Future<void> dongPhongChat(String maPhong) async {
    await _db.collection('chat_rooms').doc(maPhong).update({'closed': true});
  }
}
