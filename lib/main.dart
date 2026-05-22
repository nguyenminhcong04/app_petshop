import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'dich_vu/dich_vu_xac_thuc.dart';
import 'quan_ly_trang_thai/quan_ly_gio_hang.dart';

import 'man_hinh/chinh/dieu_huong_chinh.dart';
import 'man_hinh/nhan_vien/bang_dieu_khien_nhan_vien.dart';
import 'man_hinh/quan_tri/bang_dieu_khien_quan_tri.dart';
import 'man_hinh/xac_thuc/dang_nhap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        Provider<DichVuXacThuc>(create: (_) => DichVuXacThuc()),
        ChangeNotifierProvider<QuanLyGioHang>(create: (_) => QuanLyGioHang()),
      ],
      child: const AppBanThuCung(),
    ),
  );
}

class AppBanThuCung extends StatelessWidget {
  const AppBanThuCung({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VuiPet - Cửa hàng thú cưng',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF9A5A16),
        scaffoldBackgroundColor: const Color(0xFFFFFAF4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF9A5A16),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: const Color(0xFFFFE0B2),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9A5A16),
              );
            }

            return const TextStyle(fontSize: 12, color: Colors.black87);
          }),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9A5A16),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const TrangDieuHuong(),
    );
  }
}

class TrangDieuHuong extends StatefulWidget {
  const TrangDieuHuong({super.key});

  @override
  State<TrangDieuHuong> createState() => _TrangDieuHuongState();
}

class _TrangDieuHuongState extends State<TrangDieuHuong> {
  late Future<void> khoiTao;

  @override
  void initState() {
    super.initState();
    khoiTao = khoiTaoUngDung();
  }

  Future<void> khoiTaoUngDung() async {
    final dichVuXacThuc = context.read<DichVuXacThuc>();
    await dichVuXacThuc.taiVaiTroDaLuu();
  }

  Widget manHinhLoading() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget manHinhLoi(Object? error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Lỗi khởi tạo ứng dụng: $error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget manHinhTheoVaiTro(DichVuXacThuc dichVuXacThuc) {
    final vaiTro = dichVuXacThuc.vaiTroHienTai;
    final nguoiDung = dichVuXacThuc.nguoiDungHienTai;

    if (vaiTro == 'admin') {
      return const BangDieuKhienQuanTri();
    }

    if (vaiTro == 'staff') {
      return const BangDieuKhienNhanVien();
    }

    if (vaiTro == 'customer' && nguoiDung != null) {
      return const DieuHuongChinh();
    }

    return const DangNhap();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: khoiTao,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return manHinhLoading();
        }

        if (snapshot.hasError) {
          return manHinhLoi(snapshot.error);
        }

        final dichVuXacThuc = context.read<DichVuXacThuc>();

        return manHinhTheoVaiTro(dichVuXacThuc);
      },
    );
  }
}
