import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dich_vu/dich_vu_xac_thuc.dart';
import '../chinh/dieu_huong_chinh.dart';
import '../nhan_vien/bang_dieu_khien_nhan_vien.dart';
import '../quan_tri/bang_dieu_khien_quan_tri.dart';

class DangNhap extends StatefulWidget {
  const DangNhap({super.key});

  @override
  State<DangNhap> createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  final formKhachHangKey = GlobalKey<FormState>();
  final formDangKyKey = GlobalKey<FormState>();
  final formAdminKey = GlobalKey<FormState>();
  final formNhanVienKey = GlobalKey<FormState>();

  final emailDangNhap = TextEditingController();
  final matKhauDangNhap = TextEditingController();

  final hoTenDangKy = TextEditingController();
  final emailDangKy = TextEditingController();
  final matKhauDangKy = TextEditingController();
  final nhapLaiMatKhau = TextEditingController();

  final tenAdmin = TextEditingController(text: 'Admin');
  final matKhauAdmin = TextEditingController(text: 'admin');

  final tenNhanVien = TextEditingController();
  final matKhauNhanVien = TextEditingController();

  bool anMatKhauDangNhap = true;
  bool anMatKhauDangKy = true;
  bool anNhapLaiMatKhau = true;
  bool anMatKhauAdmin = true;
  bool anMatKhauNhanVien = true;

  bool dangXuLy = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();

    emailDangNhap.dispose();
    matKhauDangNhap.dispose();

    hoTenDangKy.dispose();
    emailDangKy.dispose();
    matKhauDangKy.dispose();
    nhapLaiMatKhau.dispose();

    tenAdmin.dispose();
    matKhauAdmin.dispose();

    tenNhanVien.dispose();
    matKhauNhanVien.dispose();

    super.dispose();
  }

  void baoLoi(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void baoThanhCong(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  String? batBuoc(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $label';
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }

    if (!value.trim().contains('@')) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  String? validateMatKhau(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }

    if (value.trim().length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }

    return null;
  }

  String hienThiLoiAuth(Object e) {
    final text = e.toString();

    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Tài khoản không tồn tại';
        case 'wrong-password':
          return 'Mật khẩu không đúng';
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'email-already-in-use':
          return 'Email đã được sử dụng';
        case 'weak-password':
          return 'Mật khẩu quá yếu';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng';
        case 'invalid-credential':
          return 'Email hoặc mật khẩu không đúng';
        default:
          return e.message ?? text;
      }
    }

    return text.replaceFirst('Exception: ', '');
  }

  Future<void> dangNhapKhachHang() async {
    if (!(formKhachHangKey.currentState?.validate() ?? false)) return;

    setState(() {
      dangXuLy = true;
    });

    try {
      await context.read<DichVuXacThuc>().dangNhap(
        email: emailDangNhap.text.trim(),
        matKhau: matKhauDangNhap.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DieuHuongChinh()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      baoLoi(hienThiLoiAuth(e));
    } finally {
      if (mounted) {
        setState(() {
          dangXuLy = false;
        });
      }
    }
  }

  Future<void> dangKyKhachHang() async {
    if (!(formDangKyKey.currentState?.validate() ?? false)) return;

    if (matKhauDangKy.text.trim() != nhapLaiMatKhau.text.trim()) {
      baoLoi('Mật khẩu nhập lại không khớp');
      return;
    }

    setState(() {
      dangXuLy = true;
    });

    try {
      await context.read<DichVuXacThuc>().dangKy(
        hoTen: hoTenDangKy.text.trim(),
        email: emailDangKy.text.trim(),
        matKhau: matKhauDangKy.text.trim(),
      );

      if (!mounted) return;

      baoThanhCong('Đăng ký thành công');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DieuHuongChinh()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      baoLoi(hienThiLoiAuth(e));
    } finally {
      if (mounted) {
        setState(() {
          dangXuLy = false;
        });
      }
    }
  }

  Future<void> dangNhapAdmin() async {
    if (!(formAdminKey.currentState?.validate() ?? false)) return;

    setState(() {
      dangXuLy = true;
    });

    try {
      await context.read<DichVuXacThuc>().dangNhapAdmin(
        tenDangNhap: tenAdmin.text.trim(),
        matKhau: matKhauAdmin.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BangDieuKhienQuanTri()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      baoLoi(hienThiLoiAuth(e));
    } finally {
      if (mounted) {
        setState(() {
          dangXuLy = false;
        });
      }
    }
  }

  Future<void> dangNhapNhanVien() async {
    if (!(formNhanVienKey.currentState?.validate() ?? false)) return;

    setState(() {
      dangXuLy = true;
    });

    try {
      await context.read<DichVuXacThuc>().dangNhapNhanVien(
        tenDangNhap: tenNhanVien.text.trim(),
        matKhau: matKhauNhanVien.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const BangDieuKhienNhanVien()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      baoLoi(hienThiLoiAuth(e));
    } finally {
      if (mounted) {
        setState(() {
          dangXuLy = false;
        });
      }
    }
  }

  Future<void> quenMatKhau() async {
    final emailController = TextEditingController(text: emailDangNhap.text);

    final email = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quên mật khẩu'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email tài khoản',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9A5A16),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, emailController.text.trim());
              },
              child: const Text('Gửi email'),
            ),
          ],
        );
      },
    );

    if (email == null || email.trim().isEmpty) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

      if (!mounted) return;

      baoThanhCong('Đã gửi email đặt lại mật khẩu');
    } catch (e) {
      if (!mounted) return;
      baoLoi(hienThiLoiAuth(e));
    }
  }

  Widget logo() {
    return Column(
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            color: const Color(0xFFFFE0B2),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.pets, color: Color(0xFF9A5A16), size: 54),
        ),
        const SizedBox(height: 14),
        const Text(
          'VuiPet',
          style: TextStyle(
            color: Color(0xFF9A5A16),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ứng dụng bán hàng và chăm sóc thú cưng',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget truongNhap({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget nutXuLy({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9A5A16),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: dangXuLy ? null : onPressed,
        icon: dangXuLy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Icon(icon),
        label: Text(
          dangXuLy ? 'Đang xử lý...' : text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget tabKhachHang() {
    return Form(
      key: formKhachHangKey,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Đăng nhập khách hàng',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Đăng nhập để mua hàng, đặt lịch và chat tư vấn.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          truongNhap(
            controller: emailDangNhap,
            label: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
          ),
          const SizedBox(height: 12),
          truongNhap(
            controller: matKhauDangNhap,
            label: 'Mật khẩu',
            icon: Icons.lock,
            obscureText: anMatKhauDangNhap,
            validator: (value) => batBuoc(value, 'mật khẩu'),
            suffixIcon: IconButton(
              icon: Icon(
                anMatKhauDangNhap ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  anMatKhauDangNhap = !anMatKhauDangNhap;
                });
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: dangXuLy ? null : quenMatKhau,
              child: const Text('Quên mật khẩu?'),
            ),
          ),
          const SizedBox(height: 6),
          nutXuLy(
            text: 'Đăng nhập',
            icon: Icons.login,
            onPressed: dangNhapKhachHang,
          ),
        ],
      ),
    );
  }

  Widget tabDangKy() {
    return Form(
      key: formDangKyKey,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Tạo tài khoản khách hàng',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tạo tài khoản để đặt hàng và theo dõi lịch hẹn.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          truongNhap(
            controller: hoTenDangKy,
            label: 'Họ tên',
            icon: Icons.person,
            validator: (value) => batBuoc(value, 'họ tên'),
          ),
          const SizedBox(height: 12),
          truongNhap(
            controller: emailDangKy,
            label: 'Email',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
          ),
          const SizedBox(height: 12),
          truongNhap(
            controller: matKhauDangKy,
            label: 'Mật khẩu',
            icon: Icons.lock,
            obscureText: anMatKhauDangKy,
            validator: validateMatKhau,
            suffixIcon: IconButton(
              icon: Icon(
                anMatKhauDangKy ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  anMatKhauDangKy = !anMatKhauDangKy;
                });
              },
            ),
          ),
          const SizedBox(height: 12),
          truongNhap(
            controller: nhapLaiMatKhau,
            label: 'Nhập lại mật khẩu',
            icon: Icons.lock_reset,
            obscureText: anNhapLaiMatKhau,
            validator: validateMatKhau,
            suffixIcon: IconButton(
              icon: Icon(
                anNhapLaiMatKhau ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  anNhapLaiMatKhau = !anNhapLaiMatKhau;
                });
              },
            ),
          ),
          const SizedBox(height: 18),
          nutXuLy(
            text: 'Đăng ký',
            icon: Icons.person_add,
            onPressed: dangKyKhachHang,
          ),
        ],
      ),
    );
  }

  Widget tabAdmin() {
    return Form(
      key: formAdminKey,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Đăng nhập Admin',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Admin quản lý sản phẩm, đơn hàng, lịch hẹn, tài khoản và thống kê.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          truongNhap(
            controller: tenAdmin,
            label: 'Tên đăng nhập',
            icon: Icons.admin_panel_settings,
            validator: (value) => batBuoc(value, 'tên đăng nhập'),
          ),
          const SizedBox(height: 12),
          truongNhap(
            controller: matKhauAdmin,
            label: 'Mật khẩu',
            icon: Icons.lock,
            obscureText: anMatKhauAdmin,
            validator: (value) => batBuoc(value, 'mật khẩu'),
            suffixIcon: IconButton(
              icon: Icon(
                anMatKhauAdmin ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  anMatKhauAdmin = !anMatKhauAdmin;
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tài khoản demo: Admin / admin',
              style: TextStyle(
                color: Color(0xFF9A5A16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          nutXuLy(
            text: 'Vào trang quản trị',
            icon: Icons.dashboard,
            onPressed: dangNhapAdmin,
          ),
        ],
      ),
    );
  }

  Widget tabNhanVien() {
    return Form(
      key: formNhanVienKey,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Đăng nhập nhân viên',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Nhân viên hỗ trợ chat, xử lý lịch hẹn và đăng ký lịch làm.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 18),
          truongNhap(
            controller: tenNhanVien,
            label: 'Tên đăng nhập',
            icon: Icons.badge,
            validator: (value) => batBuoc(value, 'tên đăng nhập'),
          ),
          const SizedBox(height: 12),
          truongNhap(
            controller: matKhauNhanVien,
            label: 'Mật khẩu',
            icon: Icons.lock,
            obscureText: anMatKhauNhanVien,
            validator: (value) => batBuoc(value, 'mật khẩu'),
            suffixIcon: IconButton(
              icon: Icon(
                anMatKhauNhanVien ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  anMatKhauNhanVien = !anMatKhauNhanVien;
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Tài khoản nhân viên do Admin tạo trong mục Tài khoản. '
              'Ví dụ Firestore: loginName = nv01, passwordDemo = 123456, role = staff.',
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 18),
          nutXuLy(
            text: 'Vào trang nhân viên',
            icon: Icons.work,
            onPressed: dangNhapNhanVien,
          ),
        ],
      ),
    );
  }

  Widget khungDangNhap() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFF3E0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              labelColor: const Color(0xFF9A5A16),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF9A5A16),
              tabs: const [
                Tab(icon: Icon(Icons.person), text: 'Khách hàng'),
                Tab(icon: Icon(Icons.person_add), text: 'Đăng ký'),
                Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin'),
                Tab(icon: Icon(Icons.badge), text: 'Nhân viên'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                tabKhachHang(),
                tabDangKy(),
                tabAdmin(),
                tabNhanVien(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),
            logo(),
            Expanded(child: khungDangNhap()),
          ],
        ),
      ),
    );
  }
}
