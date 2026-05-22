import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dich_vu/dich_vu_xac_thuc.dart';
import '../../tien_ich/dinh_dang.dart';
import '../../tien_ich/nut_thong_bao.dart';
import '../quan_tri/quan_ly_lich_hen_admin.dart';
import '../quan_tri/quan_ly_lich_lam_admin.dart';
import '../quan_tri/thong_ke_admin_mo_rong.dart';
import '../xac_thuc/dang_nhap.dart';

class BangDieuKhienQuanTri extends StatefulWidget {
  const BangDieuKhienQuanTri({super.key});

  @override
  State<BangDieuKhienQuanTri> createState() => _BangDieuKhienQuanTriState();
}

class _BangDieuKhienQuanTriState extends State<BangDieuKhienQuanTri> {
  int index = 0;

  final List<Widget> manHinh = const [
    ThongKeAdminMoRong(),
    ManHinhSanPhamAdmin(),
    ManHinhDonHangAdmin(),
    QuanLyLichHenAdmin(),
    QuanLyLichLamAdmin(),
    ManHinhTaiKhoanAdmin(),
  ];

  Future<void> dangXuat() async {
    await context.read<DichVuXacThuc>().dangXuat();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DangNhap()),
      (route) => false,
    );
  }

  Future<void> xacNhanDangXuat() async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản Admin không?',
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: manHinh[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          setState(() {
            index = i;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Thống kê'),
          NavigationDestination(icon: Icon(Icons.inventory), label: 'Sản phẩm'),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Đơn hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Lịch hẹn',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_history),
            label: 'Lịch làm',
          ),
          NavigationDestination(
            icon: Icon(Icons.manage_accounts),
            label: 'Tài khoản',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}

class ThanhTieuDeAdmin extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const ThanhTieuDeAdmin({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: const Color(0xFF9A5A16),
      foregroundColor: Colors.white,
      actions: [
        const NutThongBao(role: 'admin'),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const DangNhap()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ManHinhThongKeAdmin extends StatefulWidget {
  const ManHinhThongKeAdmin({super.key});

  @override
  State<ManHinhThongKeAdmin> createState() => _ManHinhThongKeAdminState();
}

class _ManHinhThongKeAdminState extends State<ManHinhThongKeAdmin> {
  String kieuThongKe = 'Tháng';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThanhTieuDeAdmin(title: 'Thống kê'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            value: kieuThongKe,
            decoration: const InputDecoration(
              labelText: 'Chọn kiểu thống kê',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Tháng', child: Text('Theo tháng')),
              DropdownMenuItem(value: 'Quý', child: Text('Theo quý')),
              DropdownMenuItem(value: 'Năm', child: Text('Theo năm')),
            ],
            onChanged: (value) {
              setState(() {
                kieuThongKe = value ?? 'Tháng';
              });
            },
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('orders').snapshots(),
            builder: (context, orderSnapshot) {
              final orders = orderSnapshot.data?.docs ?? [];
              int doanhThu = 0;

              for (final doc in orders) {
                final data = doc.data();
                final status = data['orderStatus']?.toString() ?? '';
                final total = data['totalAmount'];

                if (status == 'DA_HOAN_THANH') {
                  doanhThu += _parseInt(total);
                }
              }

              return Column(
                children: [
                  OThongKe(
                    icon: Icons.attach_money,
                    title: 'Doanh thu đơn hoàn thành',
                    value: DinhDang.tien(doanhThu),
                  ),
                  OThongKe(
                    icon: Icons.receipt_long,
                    title: 'Tổng số đơn hàng',
                    value: '${orders.length}',
                  ),
                ],
              );
            },
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream:
                FirebaseFirestore.instance.collection('products').snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return OThongKe(
                icon: Icons.inventory,
                title: 'Sản phẩm',
                value: '$count',
              );
            },
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              final count = snapshot.data?.docs.length ?? 0;
              return OThongKe(
                icon: Icons.people,
                title: 'Tài khoản',
                value: '$count',
              );
            },
          ),
        ],
      ),
    );
  }
}

class OThongKe extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const OThongKe({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF9A5A16)),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class ManHinhSanPhamAdmin extends StatelessWidget {
  const ManHinhSanPhamAdmin({super.key});

  Future<void> moFormSanPham(
    BuildContext context, {
    String? id,
    Map<String, dynamic>? data,
  }) async {
    final ten = TextEditingController(text: data?['name']?.toString() ?? '');
    final loai = TextEditingController(
      text: data?['category']?.toString() ?? '',
    );
    final giong = TextEditingController(text: data?['breed']?.toString() ?? '');
    final thuongHieu = TextEditingController(
      text: data?['brand']?.toString() ?? '',
    );
    final mauSac = TextEditingController(
      text: data?['color']?.toString() ?? '',
    );
    final maKho = TextEditingController(text: data?['sku']?.toString() ?? '');
    final gia = TextEditingController(text: data?['price']?.toString() ?? '');
    final kho = TextEditingController(text: data?['stock']?.toString() ?? '');
    final moTa = TextEditingController(
      text: data?['description']?.toString() ?? '',
    );
    final hinhAnh = TextEditingController(
      text: data?['imageUrl']?.toString() ?? '',
    );

    bool dangBan = data?['status'] is bool ? data!['status'] as bool : true;
    bool dangLuu = false;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> luuSanPham() async {
              final tenText = ten.text.trim();
              final giaValue = _parseInt(gia.text.trim());
              final khoValue = _parseInt(kho.text.trim());

              if (tenText.isEmpty) {
                _baoLoi(context, 'Vui lòng nhập tên sản phẩm');
                return;
              }

              if (giaValue <= 0) {
                _baoLoi(context, 'Giá sản phẩm phải lớn hơn 0');
                return;
              }

              if (khoValue < 0) {
                _baoLoi(context, 'Số lượng kho không hợp lệ');
                return;
              }

              setDialogState(() {
                dangLuu = true;
              });

              final map = <String, dynamic>{
                'name': tenText,
                'category': loai.text.trim(),
                'breed': giong.text.trim(),
                'brand': thuongHieu.text.trim(),
                'color': mauSac.text.trim(),
                'sku': maKho.text.trim(),
                'price': giaValue,
                'stock': khoValue,
                'imageUrl': hinhAnh.text.trim(),
                'description': moTa.text.trim(),
                'status': dangBan,
                'updatedAt': FieldValue.serverTimestamp(),
              };

              try {
                if (id == null) {
                  final newDoc =
                      FirebaseFirestore.instance.collection('products').doc();
                  map['productId'] = newDoc.id;
                  map['createdAt'] = FieldValue.serverTimestamp();
                  await newDoc.set(map);
                } else {
                  map['productId'] = data?['productId'] ?? id;
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(id)
                      .update(map);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        id == null
                            ? 'Đã thêm sản phẩm'
                            : 'Đã cập nhật sản phẩm',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  _baoLoi(context, 'Lỗi lưu sản phẩm: $e');
                }
              } finally {
                if (context.mounted) {
                  setDialogState(() {
                    dangLuu = false;
                  });
                }
              }
            }

            return AlertDialog(
              title: Text(id == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: ten,
                        decoration: const InputDecoration(
                          labelText: 'Tên sản phẩm *',
                          prefixIcon: Icon(Icons.pets),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: [
                          'Chó cảnh',
                          'Mèo cảnh',
                          'Thức ăn',
                          'Phụ kiện',
                          'Đồ chơi',
                        ].contains(loai.text)
                            ? loai.text
                            : 'Chó cảnh',
                        decoration:
                            const InputDecoration(labelText: 'Loại sản phẩm'),
                        items: const [
                          DropdownMenuItem(
                              value: 'Chó cảnh', child: Text('Chó cảnh')),
                          DropdownMenuItem(
                              value: 'Mèo cảnh', child: Text('Mèo cảnh')),
                          DropdownMenuItem(
                              value: 'Thức ăn', child: Text('Thức ăn')),
                          DropdownMenuItem(
                              value: 'Phụ kiện', child: Text('Phụ kiện')),
                          DropdownMenuItem(
                              value: 'Đồ chơi', child: Text('Đồ chơi')),
                        ],
                        onChanged: (value) {
                          loai.text = value ?? 'Chó cảnh';
                        },
                      ),
                      TextField(
                        controller: giong,
                        decoration: const InputDecoration(
                          labelText: 'Giống loài',
                          prefixIcon: Icon(Icons.cruelty_free),
                        ),
                      ),
                      TextField(
                        controller: thuongHieu,
                        decoration: const InputDecoration(
                          labelText: 'Thương hiệu',
                          prefixIcon: Icon(Icons.business),
                        ),
                      ),
                      TextField(
                        controller: mauSac,
                        decoration: const InputDecoration(
                          labelText: 'Màu sắc',
                          prefixIcon: Icon(Icons.color_lens),
                        ),
                      ),
                      TextField(
                        controller: maKho,
                        decoration: const InputDecoration(
                          labelText: 'Mã kho / SKU',
                          prefixIcon: Icon(Icons.qr_code),
                        ),
                      ),
                      TextField(
                        controller: gia,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá *',
                          prefixIcon: Icon(Icons.price_change),
                        ),
                      ),
                      TextField(
                        controller: kho,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Số lượng kho *',
                          prefixIcon: Icon(Icons.warehouse),
                        ),
                      ),
                      TextField(
                        controller: hinhAnh,
                        decoration: const InputDecoration(
                          labelText: 'Link hình ảnh',
                          prefixIcon: Icon(Icons.image),
                        ),
                      ),
                      TextField(
                        controller: moTa,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          prefixIcon: Icon(Icons.description),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Đang bán'),
                        value: dangBan,
                        onChanged: (value) {
                          setDialogState(() {
                            dangBan = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dangLuu ? null : () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9A5A16),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: dangLuu ? null : luuSanPham,
                  icon: dangLuu
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(dangLuu ? 'Đang lưu...' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> xacNhanXoaSanPham(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) async {
    final ten = data['name']?.toString() ?? 'sản phẩm';

    final dongY = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Xóa sản phẩm'),
          content: Text('Bạn có chắc chắn muốn xóa "$ten" không?'),
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
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (dongY == true) {
      try {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(id)
            .delete();

        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã xóa "$ten"')));
      } catch (e) {
        if (!context.mounted) return;
        _baoLoi(context, 'Lỗi xóa sản phẩm: $e');
      }
    }
  }

  void xemChiTietSanPham(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final ten = data['name']?.toString() ?? '';
    final hinhAnh = data['imageUrl']?.toString() ?? '';
    final gia = _parseInt(data['price']);
    final tonKho = _parseInt(data['stock']);
    final dangBan = data['status'] is bool ? data['status'] as bool : true;

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
                  if (hinhAnh.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        hinhAnh,
                        height: 210,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return _khungAnhLoi();
                        },
                      ),
                    )
                  else
                    _khungAnhLoi(),
                  const SizedBox(height: 16),
                  Text(
                    ten.isEmpty ? 'Chưa có tên sản phẩm' : ten,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chipThongTin(
                        Icons.category,
                        data['category']?.toString() ?? 'Chưa có loại',
                      ),
                      _chipThongTin(
                        Icons.cruelty_free,
                        data['breed']?.toString() ?? 'Chưa có giống',
                      ),
                      _chipThongTin(
                        Icons.business,
                        data['brand']?.toString() ?? 'Chưa có hãng',
                      ),
                      _chipThongTin(
                        Icons.color_lens,
                        data['color']?.toString() ?? 'Chưa có màu',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _dongChiTiet('Giá bán', DinhDang.tien(gia)),
                  _dongChiTiet('Tồn kho', '$tonKho'),
                  _dongChiTiet('Mã kho / SKU', data['sku']?.toString() ?? ''),
                  _dongChiTiet(
                    'Trạng thái',
                    dangBan ? 'Đang bán' : 'Ngừng bán',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data['description']?.toString().isNotEmpty == true
                        ? data['description'].toString()
                        : 'Chưa có mô tả',
                    style: const TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            moFormSanPham(context, id: id, data: data);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Sửa'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            xacNhanXoaSanPham(context, id, data);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Xóa'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _khungAnhLoi() {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
      ),
    );
  }

  Widget _chipThongTin(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 17),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _dongChiTiet(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 110,
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

  Widget _anhSanPham(String hinhAnh) {
    if (hinhAnh.isEmpty) {
      return const Icon(Icons.image_not_supported, color: Colors.grey);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        hinhAnh,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Icon(Icons.broken_image, color: Colors.grey);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThanhTieuDeAdmin(title: 'Quản lý sản phẩm'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9A5A16),
        foregroundColor: Colors.white,
        onPressed: () => moFormSanPham(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải sản phẩm: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Chưa có sản phẩm'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final ten = data['name']?.toString() ?? '';
              final hinhAnh = data['imageUrl']?.toString() ?? '';
              final gia = _parseInt(data['price']);
              final tonKho = _parseInt(data['stock']);
              final dangBan =
                  data['status'] is bool ? data['status'] as bool : true;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: SizedBox(
                    width: 62,
                    height: 62,
                    child: _anhSanPham(hinhAnh),
                  ),
                  title: Text(
                    ten.isEmpty ? 'Chưa có tên sản phẩm' : ten,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Loại: ${data['category'] ?? ''}\n'
                      'Giá: ${DinhDang.tien(gia)} | Kho: $tonKho | ${dangBan ? 'Đang bán' : 'Ngừng bán'}',
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () => xemChiTietSanPham(context, doc.id, data),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'detail') {
                        xemChiTietSanPham(context, doc.id, data);
                      } else if (value == 'edit') {
                        moFormSanPham(context, id: doc.id, data: data);
                      } else if (value == 'delete') {
                        xacNhanXoaSanPham(context, doc.id, data);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'detail',
                        child: Text('Xem chi tiết'),
                      ),
                      PopupMenuItem(value: 'edit', child: Text('Sửa')),
                      PopupMenuItem(value: 'delete', child: Text('Xóa')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ManHinhDonHangAdmin extends StatelessWidget {
  const ManHinhDonHangAdmin({super.key});

  Future<void> capNhatDonHang(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
    String status,
  ) async {
    final tenTrangThai = _tenTrangThaiDon(status);

    try {
      await FirebaseFirestore.instance.collection('orders').doc(id).update({
        'orderStatus': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final userId = data['userId']?.toString() ?? '';

      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'ORDER_STATUS',
        'title': 'Cập nhật đơn hàng',
        'message':
            'Đơn hàng ${data['orderId'] ?? id} đã được cập nhật: $tenTrangThai',
        'targetUserId': userId,
        'targetRoles': ['customer'],
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật đơn hàng: $tenTrangThai')),
      );
    } catch (e) {
      if (!context.mounted) return;
      _baoLoi(context, 'Lỗi cập nhật đơn hàng: $e');
    }
  }

  Future<void> xacNhanCapNhatDonHang(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
    String status,
  ) async {
    final tenTrangThai = _tenTrangThaiDon(status);

    final dongY = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Cập nhật đơn hàng'),
          content: Text(
            'Bạn có chắc chắn muốn chuyển đơn hàng sang trạng thái "$tenTrangThai" không?',
          ),
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
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );

    if (dongY == true) {
      await capNhatDonHang(context, id, data, status);
    }
  }

  void xemChiTietDonHang(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final items = _parseItems(data['items']);
    final maDon = data['orderId']?.toString() ?? id;
    final tongTien = _parseInt(data['totalAmount']);
    final trangThai = data['orderStatus']?.toString() ?? 'CHO_XAC_NHAN';

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
                  _dongChiTiet('Mã đơn', maDon),
                  _dongChiTiet(
                    'Khách hàng',
                    data['userEmail']?.toString() ?? 'Chưa có email',
                  ),
                  _dongChiTiet('Tên khách', data['userName']?.toString() ?? ''),
                  _dongChiTiet(
                    'Số điện thoại',
                    data['phone']?.toString() ?? '',
                  ),
                  _dongChiTiet('Địa chỉ', data['address']?.toString() ?? ''),
                  _dongChiTiet(
                    'Thanh toán',
                    data['paymentMethod']?.toString() ?? 'COD',
                  ),
                  _dongChiTiet('Trạng thái', _tenTrangThaiDon(trangThai)),
                  _dongChiTiet('Tổng tiền', DinhDang.tien(tongTien)),
                  const Divider(height: 26),
                  const Text(
                    'Sản phẩm trong đơn',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (items.isEmpty)
                    const Text('Đơn hàng chưa có sản phẩm')
                  else
                    ...items.map((item) {
                      final ten = item['name']?.toString() ?? 'Sản phẩm';
                      final soLuong = _parseInt(item['quantity']);
                      final gia = _parseInt(item['price']);
                      final thanhTien = gia * soLuong;

                      return Card(
                        child: ListTile(
                          title: Text(ten),
                          subtitle: Text(
                            'Số lượng: $soLuong | Giá: ${DinhDang.tien(gia)}',
                          ),
                          trailing: Text(
                            DinhDang.tien(thanhTien),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: trangThai == 'DA_DUYET'
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  xacNhanCapNhatDonHang(
                                    context,
                                    id,
                                    data,
                                    'DA_DUYET',
                                  );
                                },
                          child: const Text('Duyệt'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: trangThai == 'DA_HOAN_THANH'
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  xacNhanCapNhatDonHang(
                                    context,
                                    id,
                                    data,
                                    'DA_HOAN_THANH',
                                  );
                                },
                          child: const Text('Hoàn thành'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: trangThai == 'DA_HUY'
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  xacNhanCapNhatDonHang(
                                    context,
                                    id,
                                    data,
                                    'DA_HUY',
                                  );
                                },
                          child: const Text('Hủy'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dongChiTiet(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
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

  Widget _trangThaiChip(String status) {
    Color color;

    if (status == 'DA_DUYET') {
      color = Colors.blue;
    } else if (status == 'DA_HOAN_THANH') {
      color = Colors.green;
    } else if (status == 'DA_HUY') {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Chip(
      label: Text(
        _tenTrangThaiDon(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThanhTieuDeAdmin(title: 'Quản lý đơn hàng'),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải đơn hàng: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Chưa có đơn hàng'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              final maDon = data['orderId']?.toString() ?? doc.id;
              final email = data['userEmail']?.toString() ?? 'Khách hàng';
              final tongTien = _parseInt(data['totalAmount']);
              final trangThai =
                  data['orderStatus']?.toString() ?? 'CHO_XAC_NHAN';
              final items = _parseItems(data['items']);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF9A5A16),
                    foregroundColor: Colors.white,
                    child: Icon(Icons.receipt_long),
                  ),
                  title: Text(
                    maDon,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'Khách: $email\n'
                      'Số sản phẩm: ${items.length} | Tổng: ${DinhDang.tien(tongTien)}',
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () => xemChiTietDonHang(context, doc.id, data),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _trangThaiChip(trangThai),
                      SizedBox(
                        height: 30,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'detail') {
                              xemChiTietDonHang(context, doc.id, data);
                            } else {
                              xacNhanCapNhatDonHang(
                                context,
                                doc.id,
                                data,
                                value,
                              );
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'detail',
                              child: Text('Xem chi tiết'),
                            ),
                            PopupMenuItem(
                              value: 'DA_DUYET',
                              child: Text('Duyệt đơn'),
                            ),
                            PopupMenuItem(
                              value: 'DA_HOAN_THANH',
                              child: Text('Hoàn thành'),
                            ),
                            PopupMenuItem(
                              value: 'DA_HUY',
                              child: Text('Hủy đơn'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ManHinhTaiKhoanAdmin extends StatelessWidget {
  const ManHinhTaiKhoanAdmin({super.key});

  Future<void> moFormTaiKhoan(
    BuildContext context, {
    String? id,
    Map<String, dynamic>? data,
  }) async {
    final hoTen = TextEditingController(
      text: data?['fullName']?.toString() ?? '',
    );
    final loginName = TextEditingController(
      text: data?['loginName']?.toString() ?? '',
    );
    final email = TextEditingController(text: data?['email']?.toString() ?? '');
    final soDienThoai = TextEditingController(
      text: data?['phone']?.toString() ?? '',
    );
    final diaChi = TextEditingController(
      text: data?['address']?.toString() ?? '',
    );
    final matKhau = TextEditingController(
      text: data?['passwordDemo']?.toString() ?? '',
    );
    String role = data?['role']?.toString() ?? 'staff';
    bool dangKhoa = data?['isLocked'] == true;
    bool dangLuu = false;

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> luuTaiKhoan() async {
              if (hoTen.text.trim().isEmpty) {
                _baoLoi(context, 'Vui lòng nhập họ tên');
                return;
              }

              if (role != 'customer' && loginName.text.trim().isEmpty) {
                _baoLoi(
                  context,
                  'Vui lòng nhập tên đăng nhập cho Admin/Nhân viên',
                );
                return;
              }

              setDialogState(() {
                dangLuu = true;
              });

              try {
                final map = <String, dynamic>{
                  'fullName': hoTen.text.trim(),
                  'loginName': loginName.text.trim(),
                  'email': email.text.trim(),
                  'phone': soDienThoai.text.trim(),
                  'address': diaChi.text.trim(),
                  'passwordDemo': matKhau.text.trim(),
                  'role': role,
                  'isLocked': dangKhoa,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (id == null) {
                  final query = await FirebaseFirestore.instance
                      .collection('users')
                      .where('loginName', isEqualTo: loginName.text.trim())
                      .limit(1)
                      .get();

                  if (loginName.text.trim().isNotEmpty &&
                      query.docs.isNotEmpty) {
                    if (context.mounted) {
                      _baoLoi(context, 'Tên đăng nhập đã tồn tại');
                    }
                    return;
                  }

                  map['createdAt'] = FieldValue.serverTimestamp();
                  await FirebaseFirestore.instance.collection('users').add(map);
                } else {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(id)
                      .update(map);
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        id == null
                            ? 'Đã thêm tài khoản'
                            : 'Đã cập nhật tài khoản',
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  _baoLoi(context, 'Lỗi lưu tài khoản: $e');
                }
              } finally {
                if (context.mounted) {
                  setDialogState(() {
                    dangLuu = false;
                  });
                }
              }
            }

            return AlertDialog(
              title: Text(id == null ? 'Tạo tài khoản' : 'Sửa tài khoản'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: hoTen,
                        decoration: const InputDecoration(
                          labelText: 'Họ tên *',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      TextField(
                        controller: loginName,
                        decoration: const InputDecoration(
                          labelText: 'Tên đăng nhập',
                          prefixIcon: Icon(Icons.login),
                        ),
                      ),
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      TextField(
                        controller: soDienThoai,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      TextField(
                        controller: diaChi,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      TextField(
                        controller: matKhau,
                        decoration: const InputDecoration(
                          labelText: 'Mật khẩu demo',
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: const InputDecoration(
                          labelText: 'Vai trò',
                          prefixIcon: Icon(Icons.admin_panel_settings),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'customer',
                            child: Text('Khách hàng'),
                          ),
                          DropdownMenuItem(
                            value: 'staff',
                            child: Text('Nhân viên'),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('Admin'),
                          ),
                        ],
                        onChanged: (value) {
                          setDialogState(() {
                            role = value ?? 'staff';
                          });
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Khóa tài khoản'),
                        value: dangKhoa,
                        onChanged: (value) {
                          setDialogState(() {
                            dangKhoa = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dangLuu ? null : () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9A5A16),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: dangLuu ? null : luuTaiKhoan,
                  icon: dangLuu
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(dangLuu ? 'Đang lưu...' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> xacNhanXoaTaiKhoan(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) async {
    final ten = data['fullName']?.toString() ?? 'tài khoản';

    final dongY = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Xóa tài khoản'),
          content: Text('Bạn có chắc chắn muốn xóa "$ten" không?'),
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
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (dongY == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(id).delete();

        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Đã xóa "$ten"')));
      } catch (e) {
        if (!context.mounted) return;
        _baoLoi(context, 'Lỗi xóa tài khoản: $e');
      }
    }
  }

  IconData _iconVaiTro(String role) {
    if (role == 'admin') return Icons.admin_panel_settings;
    if (role == 'staff') return Icons.badge;
    return Icons.person;
  }

  String _tenVaiTro(String role) {
    if (role == 'admin') return 'Admin';
    if (role == 'staff') return 'Nhân viên';
    return 'Khách hàng';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThanhTieuDeAdmin(title: 'Quản lý tài khoản'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9A5A16),
        foregroundColor: Colors.white,
        onPressed: () => moFormTaiKhoan(context),
        child: const Icon(Icons.person_add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải tài khoản: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('Chưa có tài khoản'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final role = data['role']?.toString() ?? 'customer';
              final ten = data['fullName']?.toString() ?? 'Chưa có tên';
              final login = data['loginName']?.toString().isNotEmpty == true
                  ? data['loginName'].toString()
                  : data['email']?.toString() ?? '';
              final isLocked = data['isLocked'] == true;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isLocked ? Colors.grey : const Color(0xFF9A5A16),
                    foregroundColor: Colors.white,
                    child: Icon(_iconVaiTro(role)),
                  ),
                  title: Text(
                    ten,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Login/Email: $login\n'
                    'Vai trò: ${_tenVaiTro(role)} | ${isLocked ? 'Đã khóa' : 'Đang hoạt động'}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        moFormTaiKhoan(context, id: doc.id, data: data);
                      } else if (value == 'delete') {
                        xacNhanXoaTaiKhoan(context, doc.id, data);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Sửa / phân quyền'),
                      ),
                      PopupMenuItem(value: 'delete', child: Text('Xóa')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void _baoLoi(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is num) return value.toInt();

  final text = value.toString().replaceAll('.', '').replaceAll(',', '').trim();
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
      return status;
  }
}
