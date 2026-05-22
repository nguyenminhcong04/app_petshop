import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../dich_vu/dich_vu_xac_thuc.dart';
import '../chinh/dieu_huong_chinh.dart';
import 'dang_nhap.dart';

class CongXacThuc extends StatelessWidget {
  const CongXacThuc({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<DichVuXacThuc>();
    return StreamBuilder(
      stream: auth.theoDoiNguoiDung,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) return const DieuHuongChinh();
        return const DangNhap();
      },
    );
  }
}
