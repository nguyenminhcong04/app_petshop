import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DichVuXacThuc {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _vaiTro = 'customer';
  String _idNhanVien = '';

  Stream<User?> get theoDoiNguoiDung => _auth.authStateChanges();

  User? get nguoiDungHienTai => _auth.currentUser;

  String get vaiTroHienTai => _vaiTro;

  String get idNhanVienHienTai => _idNhanVien;

  bool get laAdmin => _vaiTro == 'admin';

  bool get laNhanVien => _vaiTro == 'staff';

  bool get laKhachHang => _vaiTro == 'customer';

  Future<void> dangKy({
    required String hoTen,
    required String email,
    required String matKhau,
  }) async {
    final emailChuan = email.trim();
    final hoTenChuan = hoTen.trim();

    if (hoTenChuan.isEmpty) {
      throw Exception('Vui lòng nhập họ tên');
    }

    if (emailChuan.isEmpty || !emailChuan.contains('@')) {
      throw Exception('Email không hợp lệ');
    }

    if (matKhau.length < 6) {
      throw Exception('Mật khẩu phải có ít nhất 6 ký tự');
    }

    final result = await _auth.createUserWithEmailAndPassword(
      email: emailChuan,
      password: matKhau,
    );

    final user = result.user;

    if (user == null) {
      throw Exception('Không thể tạo tài khoản');
    }

    await user.updateDisplayName(hoTenChuan);

    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'fullName': hoTenChuan,
      'email': emailChuan,
      'phone': '',
      'address': '',
      'avatarUrl': '',
      'role': 'customer',
      'rank': 'normal',
      'points': 0,
      'isLocked': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _vaiTro = 'customer';
    _idNhanVien = '';

    await _luuVaiTro('customer');
    await _xoaIdNhanVien();
  }

  Future<void> dangNhap({
    required String email,
    required String matKhau,
  }) async {
    final emailChuan = email.trim();

    if (emailChuan.isEmpty || matKhau.trim().isEmpty) {
      throw Exception('Vui lòng nhập email và mật khẩu');
    }

    final result = await _auth.signInWithEmailAndPassword(
      email: emailChuan,
      password: matKhau,
    );

    final user = result.user;

    if (user == null) {
      throw Exception('Đăng nhập thất bại');
    }

    final userDoc = await _db.collection('users').doc(user.uid).get();

    if (userDoc.exists) {
      final data = userDoc.data() ?? {};
      final role = data['role']?.toString() ?? 'customer';
      final isLocked = data['isLocked'] == true;

      if (isLocked) {
        await _auth.signOut();
        throw Exception('Tài khoản đã bị khóa');
      }

      if (role == 'admin' || role == 'staff') {
        await _auth.signOut();
        throw Exception(
          'Tài khoản này không đăng nhập ở tab khách hàng. Vui lòng chọn đúng vai trò.',
        );
      }

      await _db.collection('users').doc(user.uid).set({
        'email': user.email ?? emailChuan,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      await _db.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': user.displayName ?? '',
        'email': user.email ?? emailChuan,
        'phone': '',
        'address': '',
        'avatarUrl': '',
        'role': 'customer',
        'rank': 'normal',
        'points': 0,
        'isLocked': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    _vaiTro = 'customer';
    _idNhanVien = '';

    await _luuVaiTro('customer');
    await _xoaIdNhanVien();
  }

  Future<void> dangNhapAdmin({
    required String tenDangNhap,
    required String matKhau,
  }) async {
    final tenNhap = tenDangNhap.trim();
    final mk = matKhau.trim();

    if (tenNhap.isEmpty || mk.isEmpty) {
      throw Exception('Vui lòng nhập tên đăng nhập và mật khẩu');
    }

    // Tài khoản admin demo dùng để bảo vệ phần quản trị khi chưa tạo admin trên Firebase Auth.
    if (tenNhap == 'Admin' && mk == 'admin') {
      _vaiTro = 'admin';
      _idNhanVien = '';

      await _luuVaiTro('admin');
      await _xoaIdNhanVien();

      return;
    }

    // Cho phép đăng nhập admin tạo trong Firestore collection users.
    final query = await _db
        .collection('users')
        .where('loginName', isEqualTo: tenNhap)
        .where('role', isEqualTo: 'admin')
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Tên đăng nhập hoặc mật khẩu không đúng');
    }

    final doc = query.docs.first;
    final data = doc.data();

    final passwordDemo = data['passwordDemo']?.toString() ?? '';
    final isLocked = data['isLocked'] == true;

    if (isLocked) {
      throw Exception('Tài khoản Admin đã bị khóa');
    }

    if (passwordDemo != mk) {
      throw Exception('Tên đăng nhập hoặc mật khẩu không đúng');
    }

    await _db.collection('users').doc(doc.id).set({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _vaiTro = 'admin';
    _idNhanVien = '';

    await _luuVaiTro('admin');
    await _xoaIdNhanVien();
  }

  Future<void> dangNhapNhanVien({
    required String tenDangNhap,
    required String matKhau,
  }) async {
    final tenNhap = tenDangNhap.trim();
    final mk = matKhau.trim();

    if (tenNhap.isEmpty || mk.isEmpty) {
      throw Exception('Vui lòng nhập tên đăng nhập và mật khẩu');
    }

    final querySnapshot = await _db
        .collection('users')
        .where('loginName', isEqualTo: tenNhap)
        .where('role', isEqualTo: 'staff')
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Tài khoản nhân viên không tồn tại');
    }

    final doc = querySnapshot.docs.first;
    final data = doc.data();

    final passwordDemo = data['passwordDemo']?.toString() ?? '';
    final isLocked = data['isLocked'] == true;

    if (isLocked) {
      throw Exception('Tài khoản nhân viên đã bị khóa');
    }

    if (passwordDemo != mk) {
      throw Exception('Mật khẩu không đúng');
    }

    await _db.collection('users').doc(doc.id).set({
      'lastLoginAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _vaiTro = 'staff';
    _idNhanVien = doc.id;

    await _luuVaiTro('staff');
    await _luuIdNhanVien(doc.id);
  }

  Future<void> taiVaiTroDaLuu() async {
    final prefs = await SharedPreferences.getInstance();

    _vaiTro = prefs.getString('vaiTro') ?? 'customer';
    _idNhanVien = prefs.getString('idNhanVien') ?? '';

    final user = _auth.currentUser;

    // Nếu không có Firebase user mà vai trò cũ là customer thì quay về màn hình đăng nhập.
    if (user == null && _vaiTro == 'customer') {
      await _xoaPhienDaLuu();
      _vaiTro = 'customer';
      _idNhanVien = '';
      return;
    }

    // Admin demo và staff demo không cần FirebaseAuth user,
    // vì đang đăng nhập bằng SharedPreferences + Firestore users.
    if (_vaiTro == 'admin') {
      _idNhanVien = '';
      return;
    }

    if (_vaiTro == 'staff') {
      if (_idNhanVien.isEmpty) {
        await _xoaPhienDaLuu();
        _vaiTro = 'customer';
      }
      return;
    }

    _vaiTro = 'customer';
  }

  Future<void> dangXuat() async {
    try {
      await _auth.signOut();
    } catch (_) {
      // Admin/staff demo có thể không có FirebaseAuth session.
    }

    _vaiTro = 'customer';
    _idNhanVien = '';

    await _xoaPhienDaLuu();
  }

  Future<String> layIdNhanVienDaLuu() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('idNhanVien') ?? '';
  }

  Future<String> layVaiTroDaLuu() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('vaiTro') ?? 'customer';
  }

  Future<void> _luuVaiTro(String vaiTro) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vaiTro', vaiTro);
  }

  Future<void> _luuIdNhanVien(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idNhanVien', id);
  }

  Future<void> _xoaIdNhanVien() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('idNhanVien');
  }

  Future<void> _xoaPhienDaLuu() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vaiTro');
    await prefs.remove('idNhanVien');
  }
}
