import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dich_vu/dich_vu_xac_thuc.dart';
import '../chat/chat_khach_hang.dart';
import '../don_hang/don_hang_cua_toi.dart';
import '../xac_thuc/dang_nhap.dart';

class ThongTinCaNhan extends StatefulWidget {
  const ThongTinCaNhan({super.key});

  @override
  State<ThongTinCaNhan> createState() => _ThongTinCaNhanState();
}

class _ThongTinCaNhanState extends State<ThongTinCaNhan> {
  final TextEditingController hoTen = TextEditingController();
  final TextEditingController soDienThoai = TextEditingController();
  final TextEditingController diaChi = TextEditingController();

  bool dangLuu = false;

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    hoTen.dispose();
    soDienThoai.dispose();
    diaChi.dispose();
    super.dispose();
  }

  String hienThiThoiGian(dynamic value) {
    DateTime? dateTime;

    if (value is Timestamp) {
      dateTime = value.toDate();
    } else if (value is String) {
      dateTime = DateTime.tryParse(value);
    } else if (value is DateTime) {
      dateTime = value;
    }

    if (dateTime == null) return 'Chưa có';

    final ngay = dateTime.day.toString().padLeft(2, '0');
    final thang = dateTime.month.toString().padLeft(2, '0');
    final nam = dateTime.year.toString();

    return '$ngay/$thang/$nam';
  }

  Future<void> capNhatThongTin() async {
    final currentUser = user;

    if (currentUser == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập')));
      return;
    }

    if (hoTen.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập họ tên')));
      return;
    }

    setState(() {
      dangLuu = true;
    });

    try {
      await currentUser.updateDisplayName(hoTen.text.trim());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
            'uid': currentUser.uid,
            'fullName': hoTen.text.trim(),
            'email': currentUser.email ?? '',
            'phone': soDienThoai.text.trim(),
            'address': diaChi.text.trim(),
            'role': 'customer',
            'isLocked': false,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật thông tin cá nhân')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi cập nhật thông tin: $e')));
    } finally {
      if (mounted) {
        setState(() {
          dangLuu = false;
        });
      }
    }
  }

  Future<void> doiMatKhau() async {
    final email = user?.email ?? '';

    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tài khoản chưa có email')));
      return;
    }

    final dongY = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đổi mật khẩu'),
          content: Text('Hệ thống sẽ gửi email đặt lại mật khẩu đến:\n$email'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9A5A16),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Gửi email'),
            ),
          ],
        );
      },
    );

    if (dongY != true) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi email đổi mật khẩu')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi gửi email: $e')));
    }
  }

  Future<void> xacNhanDangXuat() async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );

    if (dongY == true) {
      await dangXuat();
    }
  }

  Future<void> dangXuat() async {
    await context.read<DichVuXacThuc>().dangXuat();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DangNhap()),
      (route) => false,
    );
  }

  void moLichSuDonHang() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DonHangCuaToi()),
    );
  }

  void moChatTuVan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatKhachHang()),
    );
  }

  Widget avatarNguoiDung(Map<String, dynamic> data) {
    final name =
        data['fullName']?.toString() ??
        user?.displayName ??
        user?.email ??
        'Khách hàng';

    final firstChar = name.trim().isEmpty ? 'K' : name.trim()[0].toUpperCase();

    return CircleAvatar(
      radius: 45,
      backgroundColor: const Color(0xFF9A5A16),
      foregroundColor: Colors.white,
      child: Text(
        firstChar,
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget thongTinDauTrang(Map<String, dynamic> data) {
    final fullName =
        data['fullName']?.toString() ?? user?.displayName ?? 'Khách hàng';
    final email = data['email']?.toString() ?? user?.email ?? '';
    final rank = data['rank']?.toString() ?? 'normal';
    final points = data['points']?.toString() ?? '0';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            avatarNguoiDung(data),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email.isEmpty ? 'Chưa có email' : email,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.star, size: 17),
                        label: Text('Hạng: $rank'),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        avatar: const Icon(Icons.savings, size: 17),
                        label: Text('$points điểm'),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget formThongTin(Map<String, dynamic> data) {
    hoTen.text = data['fullName']?.toString() ?? user?.displayName ?? '';
    soDienThoai.text = data['phone']?.toString() ?? '';
    diaChi.text = data['address']?.toString() ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin cá nhân',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: hoTen,
              decoration: const InputDecoration(
                labelText: 'Họ tên',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: soDienThoai,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: diaChi,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Địa chỉ giao hàng',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9A5A16),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: dangLuu ? null : capNhatThongTin,
                icon: dangLuu
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(dangLuu ? 'Đang lưu...' : 'Lưu thông tin'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget menuChucNang() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFE0B2),
              foregroundColor: Color(0xFF9A5A16),
              child: Icon(Icons.receipt_long),
            ),
            title: const Text('Đơn hàng của tôi'),
            subtitle: const Text('Xem lịch sử và chi tiết đơn hàng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: moLichSuDonHang,
          ),
          const Divider(height: 1),

          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFE0B2),
              foregroundColor: Color(0xFF9A5A16),
              child: Icon(Icons.chat),
            ),
            title: const Text('Chat tư vấn'),
            subtitle: const Text('Nhắn tin với nhân viên cửa hàng'),
            trailing: const Icon(Icons.chevron_right),
            onTap: moChatTuVan,
          ),
          const Divider(height: 1),

          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFE0B2),
              foregroundColor: Color(0xFF9A5A16),
              child: Icon(Icons.lock_reset),
            ),
            title: const Text('Đổi mật khẩu'),
            subtitle: const Text('Gửi email đặt lại mật khẩu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: doiMatKhau,
          ),
        ],
      ),
    );
  }

  Widget thongTinHeThong(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.verified_user, color: Color(0xFF9A5A16)),
            title: const Text('Vai trò'),
            trailing: Text(data['role']?.toString() ?? 'customer'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.calendar_today, color: Color(0xFF9A5A16)),
            title: const Text('Ngày tạo tài khoản'),
            trailing: Text(hienThiThoiGian(data['createdAt'])),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.update, color: Color(0xFF9A5A16)),
            title: const Text('Cập nhật gần nhất'),
            trailing: Text(hienThiThoiGian(data['updatedAt'])),
          ),
        ],
      ),
    );
  }

  Widget nutDangXuat() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: xacNhanDangXuat,
          icon: const Icon(Icons.logout),
          label: const Text(
            'Đăng xuất',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget manHinhChuaDangNhap() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Vui lòng đăng nhập để xem thông tin cá nhân.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget manHinhLoi(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Lỗi tải thông tin cá nhân: $error',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = user;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFAF4),
        body: manHinhChuaDangNhap(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return manHinhLoi(snapshot.error);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              snapshot.data!.data() ??
              {
                'uid': currentUser.uid,
                'email': currentUser.email ?? '',
                'fullName': currentUser.displayName ?? '',
                'role': 'customer',
              };

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 400));
            },
            child: ListView(
              children: [
                thongTinDauTrang(data),
                formThongTin(data),
                menuChucNang(),
                thongTinHeThong(data),
                nutDangXuat(),
              ],
            ),
          );
        },
      ),
    );
  }
}
