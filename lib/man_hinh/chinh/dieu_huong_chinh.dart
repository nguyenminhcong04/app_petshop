import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dich_vu/dich_vu_xac_thuc.dart';
import '../../quan_ly_trang_thai/quan_ly_gio_hang.dart';
import '../../tien_ich/nut_thong_bao.dart';

import '../ca_nhan/thong_tin_ca_nhan.dart';
import '../dat_lich/dat_lich_dich_vu.dart';
import '../gio_hang/gio_hang.dart';
import '../san_pham/danh_sach_san_pham.dart';
import '../trang_chu/trang_chu.dart';
import '../xac_thuc/dang_nhap.dart';

class DieuHuongChinh extends StatefulWidget {
  const DieuHuongChinh({super.key});

  @override
  State<DieuHuongChinh> createState() => _DieuHuongChinhState();
}

class _DieuHuongChinhState extends State<DieuHuongChinh> {
  int index = 0;

  final List<Widget> manHinh = const [
    TrangChu(),
    DanhSachSanPham(),
    GioHang(),
    DatLichDichVu(),
    ThongTinCaNhan(),
  ];

  final List<String> tieuDe = const [
    'Trang chủ',
    'Cửa hàng',
    'Giỏ hàng',
    'Đặt lịch',
    'Cá nhân',
  ];

  Future<void> xacNhanDangXuat() async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản hiện tại không?',
          ),
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

  PreferredSizeWidget buildAppBar(User? user) {
    return AppBar(
      title: Text(tieuDe[index]),
      centerTitle: true,
      backgroundColor: const Color(0xFF9A5A16),
      foregroundColor: Colors.white,
      actions: [
        NutThongBao(
          role: 'customer',
          userId: user?.uid,
          email: user?.email,
        ),
        IconButton(
          tooltip: 'Đăng xuất',
          icon: const Icon(Icons.logout),
          onPressed: xacNhanDangXuat,
        ),
      ],
    );
  }

  Widget iconGioHang(IconData icon, int soLuong) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (soLuong > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                soLuong > 99 ? '99+' : '$soLuong',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  NavigationDestination destinationGioHang(int soLuong) {
    return NavigationDestination(
      icon: iconGioHang(Icons.shopping_cart_outlined, soLuong),
      selectedIcon: iconGioHang(Icons.shopping_cart, soLuong),
      label: 'Giỏ hàng',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final soLuongGioHang = context.watch<QuanLyGioHang>().tongSoLuong;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: buildAppBar(user),
      body: IndexedStack(
        index: index,
        children: manHinh,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() {
            index = i;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Cửa hàng',
          ),
          destinationGioHang(soLuongGioHang),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Đặt lịch',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
