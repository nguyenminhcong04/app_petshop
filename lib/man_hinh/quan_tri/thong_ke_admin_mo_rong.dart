import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../tien_ich/dinh_dang.dart';

class ThongKeAdminMoRong extends StatefulWidget {
  const ThongKeAdminMoRong({super.key});

  @override
  State<ThongKeAdminMoRong> createState() => _ThongKeAdminMoRongState();
}

class _ThongKeAdminMoRongState extends State<ThongKeAdminMoRong> {
  String boLoc = 'THANG';

  final Map<String, String> tenBoLoc = const {
    'THANG': 'Tháng này',
    'QUY': 'Quý này',
    'SAU_THANG': '6 tháng gần đây',
    'NAM': 'Năm nay',
    'TAT_CA': 'Tất cả',
  };

  DateTime? ngayBatDauTheoBoLoc() {
    final now = DateTime.now();

    if (boLoc == 'THANG') {
      return DateTime(now.year, now.month, 1);
    }

    if (boLoc == 'QUY') {
      final quyHienTai = ((now.month - 1) ~/ 3) + 1;
      final thangBatDau = (quyHienTai - 1) * 3 + 1;
      return DateTime(now.year, thangBatDau, 1);
    }

    if (boLoc == 'SAU_THANG') {
      return DateTime(now.year, now.month - 5, 1);
    }

    if (boLoc == 'NAM') {
      return DateTime(now.year, 1, 1);
    }

    return null;
  }

  DateTime layDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();

    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  int parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.round();

    if (value is num) return value.toInt();

    final text =
        value.toString().replaceAll('.', '').replaceAll(',', '').trim();

    return int.tryParse(text) ?? 0;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> locTheoThoiGian(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final ngayBatDau = ngayBatDauTheoBoLoc();

    if (ngayBatDau == null) return docs;

    return docs.where((doc) {
      final data = doc.data();
      final createdAt = layDateTime(data['createdAt']);

      if (createdAt.millisecondsSinceEpoch == 0) {
        return false;
      }

      return createdAt.isAfter(ngayBatDau) ||
          createdAt.isAtSameMomentAs(ngayBatDau);
    }).toList();
  }

  bool donDaHoanThanh(String status) {
    return status == 'DA_HOAN_THANH' ||
        status == 'HOAN_THANH' ||
        status == 'COMPLETED';
  }

  bool donDaHuy(String status) {
    return status == 'DA_HUY' || status == 'HUY' || status == 'CANCELLED';
  }

  String tenTrangThaiDon(String status) {
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

  Color mauTrangThaiDon(String status) {
    if (donDaHoanThanh(status)) return Colors.green;
    if (donDaHuy(status)) return Colors.red;
    if (status == 'DA_DUYET') return Colors.blue;
    if (status == 'DANG_GIAO') return Colors.deepPurple;
    return Colors.orange;
  }

  Widget boLocThongKe() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: DropdownButtonFormField<String>(
          value: boLoc,
          decoration: const InputDecoration(
            labelText: 'Khoảng thời gian thống kê',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.date_range),
          ),
          items: tenBoLoc.entries.map((entry) {
            return DropdownMenuItem(value: entry.key, child: Text(entry.value));
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              boLoc = value;
            });
          },
        ),
      ),
    );
  }

  Widget oThongKe({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String subtitle = '',
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            foregroundColor: color,
            child: Icon(icon),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget thongKeDonHang(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orders,
  ) {
    final dsLoc = locTheoThoiGian(orders);

    int tongDoanhThu = 0;
    int tongDon = dsLoc.length;
    int donHoanThanh = 0;
    int donHuy = 0;
    int donChoXuLy = 0;

    for (final doc in dsLoc) {
      final data = doc.data();
      final status = data['orderStatus']?.toString() ?? '';
      final total = parseInt(data['totalAmount']);

      if (donDaHoanThanh(status)) {
        tongDoanhThu += total;
        donHoanThanh++;
      } else if (donDaHuy(status)) {
        donHuy++;
      } else {
        donChoXuLy++;
      }
    }

    final giaTriTrungBinh =
        donHoanThanh == 0 ? 0 : (tongDoanhThu / donHoanThanh).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: oThongKe(
                  title: 'Doanh thu',
                  value: DinhDang.tien(tongDoanhThu),
                  icon: Icons.attach_money,
                  color: Colors.green,
                  subtitle: tenBoLoc[boLoc] ?? '',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: oThongKe(
                  title: 'Tổng đơn',
                  value: '$tongDon',
                  icon: Icons.receipt_long,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: oThongKe(
                  title: 'Hoàn thành',
                  value: '$donHoanThanh',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: oThongKe(
                  title: 'Chờ xử lý',
                  value: '$donChoXuLy',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: oThongKe(
                  title: 'Đã hủy',
                  value: '$donHuy',
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: oThongKe(
                  title: 'Giá trị TB/đơn',
                  value: DinhDang.tien(giaTriTrungBinh),
                  icon: Icons.calculate,
                  color: Colors.deepPurple,
                  subtitle: 'Tính trên đơn hoàn thành',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget thongKeSanPham(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> products,
  ) {
    int dangBan = 0;
    int hetHang = 0;
    int tongTonKho = 0;

    for (final doc in products) {
      final data = doc.data();
      final status = data['status'];
      final stock = parseInt(data['stock']);

      if (status == false) {
        continue;
      }

      dangBan++;

      if (stock <= 0) {
        hetHang++;
      }

      tongTonKho += stock;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: oThongKe(
              title: 'Sản phẩm đang bán',
              value: '$dangBan',
              icon: Icons.inventory,
              color: Colors.brown,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: oThongKe(
              title: 'Hết hàng',
              value: '$hetHang',
              icon: Icons.remove_shopping_cart,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: oThongKe(
              title: 'Tồn kho',
              value: '$tongTonKho',
              icon: Icons.warehouse,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget thongKeLichHen(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> appointments,
  ) {
    final dsLoc = locTheoThoiGian(appointments);

    int choDuyet = 0;
    int daDuyet = 0;
    int hoanThanh = 0;
    int daHuy = 0;

    for (final doc in dsLoc) {
      final status = doc.data()['status']?.toString() ?? '';

      if (status == 'DA_DUYET') {
        daDuyet++;
      } else if (status == 'HOAN_THANH') {
        hoanThanh++;
      } else if (status == 'DA_HUY') {
        daHuy++;
      } else {
        choDuyet++;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: oThongKe(
                  title: 'Chờ duyệt',
                  value: '$choDuyet',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: oThongKe(
                  title: 'Đã duyệt',
                  value: '$daDuyet',
                  icon: Icons.event_available,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: oThongKe(
                  title: 'Hoàn thành',
                  value: '$hoanThanh',
                  icon: Icons.task_alt,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: oThongKe(
                  title: 'Đã hủy',
                  value: '$daHuy',
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget tieuDeMuc(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9A5A16)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget donHangGanDay(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orders,
  ) {
    final dsLoc = locTheoThoiGian(orders);

    dsLoc.sort((a, b) {
      final aTime = layDateTime(a.data()['createdAt']);
      final bTime = layDateTime(b.data()['createdAt']);
      return bTime.compareTo(aTime);
    });

    final dsHienThi = dsLoc.take(5).toList();

    if (dsHienThi.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Chưa có đơn hàng trong khoảng thời gian này.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: dsHienThi.map((doc) {
          final data = doc.data();
          final maDon = data['orderId']?.toString() ?? doc.id;
          final email = data['userEmail']?.toString() ?? 'Khách hàng';
          final status = data['orderStatus']?.toString() ?? 'CHO_XAC_NHAN';
          final total = parseInt(data['totalAmount']);

          return Card(
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: mauTrangThaiDon(status),
                foregroundColor: Colors.white,
                child: const Icon(Icons.receipt_long),
              ),
              title: Text(
                maDon,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('$email\n${tenTrangThaiDon(status)}'),
              isThreeLine: true,
              trailing: Text(
                DinhDang.tien(total),
                style: const TextStyle(
                  color: Color(0xFF9A5A16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget bangDoanhThuTheoThang(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orders,
  ) {
    final now = DateTime.now();
    final Map<String, int> doanhThuTheoThang = {};

    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      final key = '${d.month.toString().padLeft(2, '0')}/${d.year}';
      doanhThuTheoThang[key] = 0;
    }

    for (final doc in orders) {
      final data = doc.data();
      final status = data['orderStatus']?.toString() ?? '';

      if (!donDaHoanThanh(status)) continue;

      final createdAt = layDateTime(data['createdAt']);

      if (createdAt.millisecondsSinceEpoch == 0) continue;

      final key =
          '${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';

      if (doanhThuTheoThang.containsKey(key)) {
        doanhThuTheoThang[key] =
            doanhThuTheoThang[key]! + parseInt(data['totalAmount']);
      }
    }

    final maxValue = doanhThuTheoThang.values.isEmpty
        ? 0
        : doanhThuTheoThang.values.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Doanh thu 6 tháng gần đây',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...doanhThuTheoThang.entries.map((entry) {
                final value = entry.value;
                final percent = maxValue == 0 ? 0.0 : value / maxValue;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 58,
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            color: const Color(0xFF9A5A16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 92,
                        child: Text(
                          DinhDang.tien(value),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget bodyThongKe() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, orderSnapshot) {
        if (orderSnapshot.hasError) {
          return Center(
            child: Text('Lỗi tải đơn hàng: ${orderSnapshot.error}'),
          );
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, productSnapshot) {
            if (productSnapshot.hasError) {
              return Center(
                child: Text('Lỗi tải sản phẩm: ${productSnapshot.error}'),
              );
            }

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .snapshots(),
              builder: (context, appointmentSnapshot) {
                if (appointmentSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Lỗi tải lịch hẹn: ${appointmentSnapshot.error}',
                    ),
                  );
                }

                if (!orderSnapshot.hasData ||
                    !productSnapshot.hasData ||
                    !appointmentSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final orders = orderSnapshot.data!.docs;
                final products = productSnapshot.data!.docs;
                final appointments = appointmentSnapshot.data!.docs;

                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 400));
                  },
                  child: ListView(
                    children: [
                      boLocThongKe(),
                      tieuDeMuc('Tổng quan đơn hàng', Icons.analytics),
                      thongKeDonHang(orders),
                      tieuDeMuc('Sản phẩm và kho', Icons.inventory_2),
                      thongKeSanPham(products),
                      tieuDeMuc('Lịch hẹn dịch vụ', Icons.event_available),
                      thongKeLichHen(appointments),
                      tieuDeMuc('Biểu đồ doanh thu', Icons.bar_chart),
                      bangDoanhThuTheoThang(orders),
                      tieuDeMuc('Đơn hàng gần đây', Icons.history),
                      donHangGanDay(orders),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: AppBar(
        title: const Text('Thống kê tổng quan'),
        centerTitle: true,
        backgroundColor: const Color(0xFF9A5A16),
        foregroundColor: Colors.white,
      ),
      body: bodyThongKe(),
    );
  }
}
