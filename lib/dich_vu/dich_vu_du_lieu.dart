import 'package:cloud_firestore/cloud_firestore.dart';

import '../mo_hinh/don_hang.dart';
import '../mo_hinh/lich_hen.dart';
import '../mo_hinh/san_pham.dart';

class DichVuDuLieu {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  CollectionReference<Map<String, dynamic>> get _appointments =>
      _db.collection('appointments');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');

  // =========================================================
  // SẢN PHẨM
  // =========================================================

  Stream<List<SanPham>> laySanPham({
    String tuKhoa = '',
    String danhMuc = '',
    String giongLoai = '',
    int? giaTu,
    int? giaDen,
    bool chiLayDangBan = true,
  }) {
    Query<Map<String, dynamic>> query = _products;

    if (chiLayDangBan) {
      query = query.where('status', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      final ds = snapshot.docs.map((doc) {
        final data = doc.data();
        return SanPham.fromMap(data, doc.id);
      }).toList();

      final keyword = tuKhoa.trim().toLowerCase();
      final category = danhMuc.trim().toLowerCase();
      final breed = giongLoai.trim().toLowerCase();

      return ds.where((sp) {
        final ten = sp.ten.toLowerCase();
        final dm = sp.danhMuc.toLowerCase();

        final dungTuKhoa = keyword.isEmpty || ten.contains(keyword);
        final dungDanhMuc = category.isEmpty || dm == category;

        final dataMap = sp.toMap();
        final spBreed = (dataMap['breed'] ?? '').toString().toLowerCase();

        final dungGiongLoai = breed.isEmpty || spBreed == breed;
        final dungGiaTu = giaTu == null || sp.gia >= giaTu;
        final dungGiaDen = giaDen == null || sp.gia <= giaDen;

        return dungTuKhoa &&
            dungDanhMuc &&
            dungGiongLoai &&
            dungGiaTu &&
            dungGiaDen;
      }).toList();
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> layTatCaSanPhamAdmin() {
    return _products.snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> layChiTietSanPham(
    String maSanPham,
  ) {
    return _products.doc(maSanPham).get();
  }

  Future<void> themSanPham(SanPham sanPham) async {
    final id = sanPham.maSanPham.isNotEmpty
        ? sanPham.maSanPham
        : _products.doc().id;

    final data = sanPham.toMap();
    data['productId'] = id;
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _products.doc(id).set(data);
  }

  Future<void> themSanPhamTuMap(Map<String, dynamic> data) async {
    final doc = _products.doc();

    await doc.set({
      ...data,
      'productId': doc.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> capNhatSanPham(SanPham sanPham) async {
    final data = sanPham.toMap();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _products.doc(sanPham.maSanPham).update(data);
  }

  Future<void> capNhatSanPhamTuMap(
    String maSanPham,
    Map<String, dynamic> data,
  ) async {
    await _products.doc(maSanPham).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> xoaSanPham(String maSanPham) async {
    await _products.doc(maSanPham).delete();
  }

  Future<void> anSanPham(String maSanPham) async {
    await _products.doc(maSanPham).update({
      'status': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> hienSanPham(String maSanPham) async {
    await _products.doc(maSanPham).update({
      'status': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // ĐƠN HÀNG
  // =========================================================

  Future<void> taoDonHang(DonHang donHang) async {
    await _orders.doc(donHang.maDonHang).set(donHang.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> layDonHangCuaNguoiDung(
    String uid,
  ) {
    return _orders.where('userId', isEqualTo: uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> layTatCaDonHang() {
    return _orders.snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> layChiTietDonHang(
    String maDonHang,
  ) {
    return _orders.doc(maDonHang).get();
  }

  Future<void> capNhatTrangThaiDonHang(
    String maDonHang,
    String trangThai,
  ) async {
    await _orders.doc(maDonHang).update({
      'orderStatus': trangThai,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> capNhatTrangThaiThanhToan(
    String maDonHang,
    String trangThaiThanhToan,
  ) async {
    await _orders.doc(maDonHang).update({
      'paymentStatus': trangThaiThanhToan,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> huyDonHang(String maDonHang) async {
    await capNhatTrangThaiDonHang(maDonHang, 'DA_HUY');
  }

  Future<void> duyetDonHang(String maDonHang) async {
    await capNhatTrangThaiDonHang(maDonHang, 'DA_DUYET');
  }

  Future<void> hoanThanhDonHang(String maDonHang) async {
    await _orders.doc(maDonHang).update({
      'orderStatus': 'DA_HOAN_THANH',
      'paymentStatus': 'DA_THANH_TOAN',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // LỊCH HẸN
  // =========================================================

  Future<void> datLichHen(LichHen lichHen) async {
    await _appointments.doc(lichHen.maLichHen).set(lichHen.toMap());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> layLichHenCuaNguoiDung(
    String uid,
  ) {
    return _appointments.where('userId', isEqualTo: uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> layTatCaLichHen() {
    return _appointments.snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> layChiTietLichHen(
    String maLichHen,
  ) {
    return _appointments.doc(maLichHen).get();
  }

  Future<void> capNhatTrangThaiLichHen(
    String maLichHen,
    String trangThai, {
    String ghiChu = '',
  }) async {
    await _appointments.doc(maLichHen).update({
      'status': trangThai,
      'note': ghiChu,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> duyetLichHen(String maLichHen, {String ghiChu = ''}) async {
    await capNhatTrangThaiLichHen(maLichHen, 'DA_DUYET', ghiChu: ghiChu);
  }

  Future<void> huyLichHen(String maLichHen, {String ghiChu = ''}) async {
    await capNhatTrangThaiLichHen(maLichHen, 'DA_HUY', ghiChu: ghiChu);
  }

  // =========================================================
  // TÀI KHOẢN NGƯỜI DÙNG
  // =========================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> layTatCaNguoiDung() {
    return _users.snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> layThongTinNguoiDung(
    String uid,
  ) {
    return _users.doc(uid).get();
  }

  Future<void> capNhatThongTinNguoiDung(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _users.doc(uid).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> taoNguoiDung(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> khoaTaiKhoan(String uid) async {
    await _users.doc(uid).update({
      'isLocked': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> moKhoaTaiKhoan(String uid) async {
    await _users.doc(uid).update({
      'isLocked': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================================================
  // THÔNG BÁO
  // =========================================================

  Future<void> taoThongBao({
    required String tieuDe,
    required String noiDung,
    String loai = 'SYSTEM',
    String targetUserId = '',
    List<String> targetRoles = const [],
  }) async {
    await _notifications.add({
      'type': loai,
      'title': tieuDe,
      'message': noiDung,
      'targetUserId': targetUserId,
      'targetRoles': targetRoles,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> layThongBaoTheoNguoiDung(
    String uid,
  ) {
    return _notifications.where('targetUserId', isEqualTo: uid).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> layThongBaoTheoVaiTro(
    String role,
  ) {
    return _notifications.where('targetRoles', arrayContains: role).snapshots();
  }

  Future<void> danhDauDaDocThongBao(String id) async {
    await _notifications.doc(id).update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }
}
