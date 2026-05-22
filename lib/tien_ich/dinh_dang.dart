import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DinhDang {
  static final NumberFormat _tienVietNam = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  static final NumberFormat _soNguyen = NumberFormat.decimalPattern('vi_VN');

  static String tien(dynamic value) {
    final soTien = parseInt(value);

    try {
      return _tienVietNam.format(soTien);
    } catch (_) {
      return '$soTien đ';
    }
  }

  static String so(dynamic value) {
    final number = parseInt(value);

    try {
      return _soNguyen.format(number);
    } catch (_) {
      return number.toString();
    }
  }

  static int parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.round();

    if (value is num) return value.toInt();

    final text = value
        .toString()
        .replaceAll('đ', '')
        .replaceAll('₫', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();

    return int.tryParse(text) ?? 0;
  }

  static double parseDouble(dynamic value) {
    if (value == null) return 0;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    if (value is num) return value.toDouble();

    final text = value
        .toString()
        .replaceAll('đ', '')
        .replaceAll('₫', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(text) ?? 0;
  }

  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is Timestamp) return value.toDate();

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static String ngay(dynamic value) {
    final dateTime = parseDateTime(value);

    if (dateTime == null) return 'Chưa có';

    final ngay = dateTime.day.toString().padLeft(2, '0');
    final thang = dateTime.month.toString().padLeft(2, '0');
    final nam = dateTime.year.toString();

    return '$ngay/$thang/$nam';
  }

  static String ngayGio(dynamic value) {
    final dateTime = parseDateTime(value);

    if (dateTime == null) return 'Chưa có';

    final ngay = dateTime.day.toString().padLeft(2, '0');
    final thang = dateTime.month.toString().padLeft(2, '0');
    final nam = dateTime.year.toString();
    final gio = dateTime.hour.toString().padLeft(2, '0');
    final phut = dateTime.minute.toString().padLeft(2, '0');

    return '$ngay/$thang/$nam $gio:$phut';
  }

  static String gio(dynamic value) {
    final dateTime = parseDateTime(value);

    if (dateTime == null) return 'Chưa có';

    final gio = dateTime.hour.toString().padLeft(2, '0');
    final phut = dateTime.minute.toString().padLeft(2, '0');

    return '$gio:$phut';
  }

  static String ngayTuIso(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Chưa có';
    }

    final dateTime = DateTime.tryParse(value);

    if (dateTime == null) {
      return value;
    }

    return ngay(dateTime);
  }

  static String ngayGioTuIso(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Chưa có';
    }

    final dateTime = DateTime.tryParse(value);

    if (dateTime == null) {
      return value;
    }

    return ngayGio(dateTime);
  }

  static String rutGonNoiDung(String text, {int maxLength = 60}) {
    final noiDung = text.trim();

    if (noiDung.length <= maxLength) {
      return noiDung;
    }

    return '${noiDung.substring(0, maxLength)}...';
  }

  static String trangThaiDonHang(String status) {
    switch (status) {
      case 'CHO_XAC_NHAN':
        return 'Chờ xác nhận';
      case 'CHO_DUYET':
        return 'Chờ duyệt';
      case 'DA_DUYET':
        return 'Đã duyệt';
      case 'DANG_GIAO':
        return 'Đang giao';
      case 'DA_HOAN_THANH':
      case 'HOAN_THANH':
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'DA_HUY':
      case 'HUY':
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status.isEmpty ? 'Chờ xác nhận' : status;
    }
  }

  static String trangThaiLichHen(String status) {
    switch (status) {
      case 'CHO_DUYET':
        return 'Chờ duyệt';
      case 'DA_DAT':
        return 'Đã đặt';
      case 'DA_DUYET':
        return 'Đã duyệt';
      case 'FULL_LICH':
        return 'Full lịch / đổi giờ';
      case 'DA_HUY':
        return 'Đã hủy';
      case 'HOAN_THANH':
        return 'Hoàn thành';
      default:
        return status.isEmpty ? 'Chờ duyệt' : status;
    }
  }

  static String trangThaiLichLam(String status) {
    switch (status) {
      case 'CHO_ADMIN_DUYET':
        return 'Chờ Admin duyệt';
      case 'DA_DUYET':
        return 'Đã duyệt';
      case 'TU_CHOI':
        return 'Từ chối';
      default:
        return status.isEmpty ? 'Chờ Admin duyệt' : status;
    }
  }
}
