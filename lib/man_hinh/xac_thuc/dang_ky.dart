import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DangKy extends StatefulWidget {
  const DangKy({super.key});

  @override
  State<DangKy> createState() => _DangKyState();
}

class _DangKyState extends State<DangKy> {
  final hoTenController = TextEditingController();
  final emailController = TextEditingController();
  final matKhauController = TextEditingController();

  bool dangXuLy = false;

  Future<void> dangKyTaiKhoan() async {
    final hoTen = hoTenController.text.trim();
    final email = emailController.text.trim();
    final matKhau = matKhauController.text.trim();

    if (hoTen.isEmpty || email.isEmpty || matKhau.isEmpty) {
      hienThongBao('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    setState(() {
      dangXuLy = true;
    });

    UserCredential? ketQua;
    try {
      ketQua = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: matKhau,
      );

      final uid = ketQua.user?.uid;
      if (uid == null) {
        throw FirebaseAuthException(
          code: 'unknown',
          message: 'Không lấy được UID người dùng',
        );
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': hoTen,
        'email': email,
        'phone': '',
        'address': '',
        'role': 'customer',
        'rank': 'normal',
        'points': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      hienThongBao('Đăng ký tài khoản thành công');
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'Tài khoản đã tồn tại';
      } else if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu';
      } else if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ';
      } else {
        message = e.message ?? 'Đăng ký thất bại';
      }
      hienThongBao(message);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        hienThongBao(
          'Chưa cấp quyền ghi Firestore. Kiểm tra Rules Firestore của bạn.',
        );
      } else {
        hienThongBao(e.message ?? 'Không thể lưu dữ liệu người dùng');
      }

      if (ketQua?.user != null) {
        await ketQua!.user!.delete().catchError((_) {});
      }
    } catch (e) {
      hienThongBao('Lỗi không xác định: $e');
    } finally {
      if (mounted) {
        setState(() {
          dangXuLy = false;
        });
      }
    }
  }

  void hienThongBao(String noiDung) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(noiDung)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFFAF4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: hoTenController,
              decoration: const InputDecoration(
                labelText: 'Họ tên',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: matKhauController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: dangXuLy ? null : dangKyTaiKhoan,
                child: dangXuLy
                    ? const CircularProgressIndicator()
                    : const Text('Tạo tài khoản'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
