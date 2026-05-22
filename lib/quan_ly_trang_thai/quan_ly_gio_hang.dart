import 'package:flutter/material.dart';

import '../mo_hinh/muc_gio_hang.dart';
import '../mo_hinh/san_pham.dart';

class QuanLyGioHang extends ChangeNotifier {
  final List<MucGioHang> _ds = [];

  List<MucGioHang> get danhSach => List.unmodifiable(_ds);

  int get tongTien {
    return _ds.fold<int>(0, (sum, item) => sum + item.thanhTien);
  }

  int get tongSoLuong {
    return _ds.fold<int>(0, (sum, item) => sum + item.soLuong);
  }

  bool get isEmpty => _ds.isEmpty;

  bool get isNotEmpty => _ds.isNotEmpty;

  bool daCoTrongGio(String maSanPham) {
    return _ds.any((item) => item.sanPham.maSanPham == maSanPham);
  }

  MucGioHang? timTheoMaSanPham(String maSanPham) {
    try {
      return _ds.firstWhere((item) => item.sanPham.maSanPham == maSanPham);
    } catch (_) {
      return null;
    }
  }

  bool coTheThem(SanPham sanPham) {
    if (!sanPham.dangBan) return false;
    if (sanPham.tonKho <= 0) return false;

    final item = timTheoMaSanPham(sanPham.maSanPham);

    if (item == null) return true;

    return item.soLuong < sanPham.tonKho;
  }

  String? lyDoKhongTheThem(SanPham sanPham) {
    if (!sanPham.dangBan) {
      return 'Sản phẩm đang ngừng bán';
    }

    if (sanPham.tonKho <= 0) {
      return 'Sản phẩm đã hết hàng';
    }

    final item = timTheoMaSanPham(sanPham.maSanPham);

    if (item != null && item.soLuong >= sanPham.tonKho) {
      return 'Số lượng trong giỏ đã đạt tối đa tồn kho';
    }

    return null;
  }

  bool them(SanPham sanPham) {
    final lyDo = lyDoKhongTheThem(sanPham);

    if (lyDo != null) {
      return false;
    }

    final index = _ds.indexWhere(
      (item) => item.sanPham.maSanPham == sanPham.maSanPham,
    );

    if (index >= 0) {
      _ds[index].soLuong++;
    } else {
      _ds.add(MucGioHang(sanPham: sanPham));
    }

    notifyListeners();
    return true;
  }

  void giam(String maSanPham) {
    final index = _ds.indexWhere((item) => item.sanPham.maSanPham == maSanPham);

    if (index < 0) return;

    if (_ds[index].soLuong > 1) {
      _ds[index].soLuong--;
    } else {
      _ds.removeAt(index);
    }

    notifyListeners();
  }

  bool tang(String maSanPham) {
    final index = _ds.indexWhere((item) => item.sanPham.maSanPham == maSanPham);

    if (index < 0) return false;

    final item = _ds[index];

    if (item.soLuong >= item.sanPham.tonKho) {
      return false;
    }

    item.soLuong++;
    notifyListeners();
    return true;
  }

  bool capNhatSoLuong(String maSanPham, int soLuongMoi) {
    final index = _ds.indexWhere((item) => item.sanPham.maSanPham == maSanPham);

    if (index < 0) return false;

    if (soLuongMoi <= 0) {
      _ds.removeAt(index);
      notifyListeners();
      return true;
    }

    final tonKho = _ds[index].sanPham.tonKho;

    if (soLuongMoi > tonKho) {
      return false;
    }

    _ds[index].soLuong = soLuongMoi;
    notifyListeners();
    return true;
  }

  void xoa(String maSanPham) {
    _ds.removeWhere((item) => item.sanPham.maSanPham == maSanPham);

    notifyListeners();
  }

  void xoaTatCa() {
    _ds.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> toOrderItems() {
    return _ds.map((item) => item.toOrderItem()).toList();
  }
}
