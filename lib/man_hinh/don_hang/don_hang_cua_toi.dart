import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../dich_vu/dich_vu_du_lieu.dart';
import '../../tien_ich/dinh_dang.dart';

class DonHangCuaToi extends StatelessWidget {
  const DonHangCuaToi({super.key});

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is num) return value.toInt();

    final text = value
        .toString()
        .replaceAll('.', '')
        .replaceAll(',', '')
        .trim();
    return int.tryParse(text) ?? 0;
  }

  List<Map<String, dynamic>> _parseItems(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            }

            if (item is Map) {
              return Map<String, dynamic>.from(item);
            }

            return <String, dynamic>{};
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return [];
  }

  String _tenTrangThaiDon(String status) {
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
        return 'Đã hoàn thành';
      case 'DA_HUY':
        return 'Đã hủy';
      default:
        return status.isEmpty ? 'Chờ xác nhận' : status;
    }
  }

  Color _mauTrangThai(String status) {
    switch (status) {
      case 'DA_DUYET':
        return Colors.blue;
      case 'DANG_GIAO':
        return Colors.deepPurple;
      case 'DA_HOAN_THANH':
        return Colors.green;
      case 'DA_HUY':
        return Colors.red;
      case 'CHO_DUYET':
      case 'CHO_XAC_NHAN':
      default:
        return Colors.orange;
    }
  }

  String _dinhDangNgay(dynamic value) {
    if (value == null) return 'Chưa có';

    DateTime? dateTime;

    if (value is Timestamp) {
      dateTime = value.toDate();
    } else if (value is String) {
      dateTime = DateTime.tryParse(value);
    }

    if (dateTime == null) return value.toString();

    final ngay = dateTime.day.toString().padLeft(2, '0');
    final thang = dateTime.month.toString().padLeft(2, '0');
    final nam = dateTime.year.toString();
    final gio = dateTime.hour.toString().padLeft(2, '0');
    final phut = dateTime.minute.toString().padLeft(2, '0');

    return '$ngay/$thang/$nam $gio:$phut';
  }

  Widget _chipTrangThai(String status) {
    final color = _mauTrangThai(status);

    return Chip(
      label: Text(
        _tenTrangThaiDon(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _dongChiTiet(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'Chưa có' : value)),
        ],
      ),
    );
  }

  void _xemChiTietDonHang(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final maDon = data['orderId']?.toString() ?? id;
    final trangThai = data['orderStatus']?.toString() ?? 'CHO_XAC_NHAN';
    final thanhToan = data['paymentStatus']?.toString() ?? 'CHUA_THANH_TOAN';
    final phuongThuc = data['paymentMethod']?.toString() ?? 'COD';
    final tongTien = _parseInt(data['totalAmount']);
    final items = _parseItems(data['items']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chi tiết đơn hàng',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          maDon,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _chipTrangThai(trangThai),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _dongChiTiet('Ngày đặt', _dinhDangNgay(data['createdAt'])),
                  _dongChiTiet('Trạng thái', _tenTrangThaiDon(trangThai)),
                  _dongChiTiet('Thanh toán', thanhToan),
                  _dongChiTiet('Phương thức', phuongThuc),
                  _dongChiTiet('Email', data['userEmail']?.toString() ?? ''),
                  _dongChiTiet(
                    'Người nhận',
                    data['userName']?.toString() ?? '',
                  ),
                  _dongChiTiet(
                    'Số điện thoại',
                    data['phone']?.toString() ?? '',
                  ),
                  _dongChiTiet('Địa chỉ', data['address']?.toString() ?? ''),
                  _dongChiTiet('Ghi chú', data['note']?.toString() ?? ''),

                  const Divider(height: 28),

                  const Text(
                    'Sản phẩm đã đặt',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  if (items.isEmpty)
                    const Text('Đơn hàng chưa có sản phẩm')
                  else
                    ...items.map((item) {
                      final ten =
                          item['name']?.toString() ??
                          item['productName']?.toString() ??
                          'Sản phẩm';

                      final maSanPham = item['productId']?.toString() ?? '';
                      final soLuong = _parseInt(
                        item['quantity'] ?? item['soLuong'],
                      );
                      final gia = _parseInt(item['price'] ?? item['gia']);
                      final thanhTien = gia * soLuong;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF9A5A16),
                            foregroundColor: Colors.white,
                            child: Icon(Icons.pets),
                          ),
                          title: Text(
                            ten,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Mã: ${maSanPham.isEmpty ? 'Chưa có' : maSanPham}\n'
                            'Số lượng: $soLuong | Giá: ${DinhDang.tien(gia)}',
                          ),
                          isThreeLine: true,
                          trailing: Text(
                            DinhDang.tien(thanhTien),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9A5A16),
                            ),
                          ),
                        ),
                      );
                    }),

                  const Divider(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng tiền',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DinhDang.tien(tongTien),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF9A5A16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9A5A16),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Đã hiểu'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _manHinhChuaDangNhap() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Vui lòng đăng nhập để xem đơn hàng của bạn.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _manHinhTrong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 82,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bạn chưa có đơn hàng',
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Khi bạn đặt hàng thành công, đơn hàng sẽ hiển thị tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemDonHang(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final maDon = data['orderId']?.toString() ?? id;
    final trangThai = data['orderStatus']?.toString() ?? 'CHO_XAC_NHAN';
    final tongTien = _parseInt(data['totalAmount']);
    final items = _parseItems(data['items']);
    final ngayTao = _dinhDangNgay(data['createdAt']);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _xemChiTietDonHang(context, id, data),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Color(0xFF9A5A16),
                foregroundColor: Colors.white,
                child: Icon(Icons.receipt_long),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maDon,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Ngày đặt: $ngayTao',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Số sản phẩm: ${items.length}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tổng tiền: ${DinhDang.tien(tongTien)}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF9A5A16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _chipTrangThai(trangThai),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng của tôi'),
        backgroundColor: const Color(0xFF9A5A16),
        foregroundColor: Colors.white,
      ),
      body: uid.isEmpty
          ? _manHinhChuaDangNhap()
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: DichVuDuLieu().layDonHangCuaNguoiDung(uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Lỗi tải đơn hàng: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final ds = snapshot.data!.docs;

                if (ds.isEmpty) {
                  return _manHinhTrong();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 400));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: ds.length,
                    itemBuilder: (context, index) {
                      final doc = ds[index];
                      return _itemDonHang(context, doc.id, doc.data());
                    },
                  ),
                );
              },
            ),
    );
  }
}
