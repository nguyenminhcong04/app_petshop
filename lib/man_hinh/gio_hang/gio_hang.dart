import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../dich_vu/dich_vu_thong_bao.dart';
import '../../quan_ly_trang_thai/quan_ly_gio_hang.dart';
import '../../tien_ich/dinh_dang.dart';

class GioHang extends StatefulWidget {
  const GioHang({super.key});

  @override
  State<GioHang> createState() => _GioHangState();
}

class _GioHangState extends State<GioHang> {
  bool _dangDatHang = false;

  final TextEditingController tenKhach = TextEditingController();
  final TextEditingController soDienThoai = TextEditingController();
  final TextEditingController diaChi = TextEditingController();

  String phuongThucThanhToan = 'COD';

  @override
  void dispose() {
    tenKhach.dispose();
    soDienThoai.dispose();
    diaChi.dispose();
    super.dispose();
  }

  Future<void> _moFormDatHang(BuildContext context) async {
    final gio = context.read<QuanLyGioHang>();

    if (gio.danhSach.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giỏ hàng đang trống')),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin đặt hàng',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: tenKhach,
                      decoration: const InputDecoration(
                        labelText: 'Họ tên người nhận',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: soDienThoai,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: diaChi,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ giao hàng',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: phuongThucThanhToan,
                      decoration: const InputDecoration(
                        labelText: 'Phương thức thanh toán',
                        prefixIcon: Icon(Icons.payments),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'COD',
                          child: Text('Thanh toán khi nhận hàng COD'),
                        ),
                        DropdownMenuItem(
                          value: 'BANKING',
                          child: Text('Chuyển khoản ngân hàng'),
                        ),
                        DropdownMenuItem(
                          value: 'ONLINE',
                          child: Text('Thanh toán online'),
                        ),
                      ],
                      onChanged: (value) {
                        setModalState(() {
                          phuongThucThanhToan = value ?? 'COD';
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    Card(
                      color: Colors.orange.shade50,
                      child: ListTile(
                        leading: const Icon(
                          Icons.shopping_cart,
                          color: Color(0xFF9A5A16),
                        ),
                        title: Text('${gio.danhSach.length} sản phẩm'),
                        subtitle: Text(
                          'Tổng tiền: ${DinhDang.tien(gio.tongTien)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9A5A16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _dangDatHang
                            ? null
                            : () async {
                                Navigator.pop(context);
                                await _datHang(context);
                              },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Xác nhận đặt hàng'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9A5A16),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _datHang(BuildContext context) async {
    final gio = context.read<QuanLyGioHang>();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đặt hàng')),
      );
      return;
    }

    if (tenKhach.text.trim().isEmpty ||
        soDienThoai.text.trim().isEmpty ||
        diaChi.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin nhận hàng')),
      );
      return;
    }

    setState(() => _dangDatHang = true);

    try {
      final maDon = 'DH${DateTime.now().millisecondsSinceEpoch}';
      final uid = user.uid;
      final email = user.email ?? '';
      final tongTienDatHang = gio.tongTien;

      final items = gio.danhSach.map((item) {
        final sp = item.sanPham;

        return {
          'productId': sp.maSanPham,
          'name': sp.ten,
          'price': sp.gia,
          'quantity': item.soLuong,
          'imageUrl': sp.hinhAnh,
        };
      }).toList();

      final orderRef =
          FirebaseFirestore.instance.collection('orders').doc(maDon);

      await FirebaseFirestore.instance.runTransaction((transaction) async {

  // =========================
  // READ TOÀN BỘ TRƯỚC
  // =========================

  final productSnapshots = <DocumentSnapshot>[];

  for (final item in gio.danhSach) {
    final sp = item.sanPham;

    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(sp.maSanPham);

    final snapshot = await transaction.get(productRef);

    productSnapshots.add(snapshot);
  }

  // =========================
  // CHECK TỒN KHO
  // =========================

  for (int i = 0; i < gio.danhSach.length; i++) {
    final item = gio.danhSach[i];
    final snapshot = productSnapshots[i];

    final sp = item.sanPham;

    if (!snapshot.exists) {
      throw Exception(
        'Sản phẩm "${sp.ten}" không tồn tại',
      );
    }

    final data = snapshot.data() as Map<String, dynamic>;

    final int tonKho = data['stock'] ?? 0;

    if (tonKho < item.soLuong) {
      throw Exception(
        'Sản phẩm "${sp.ten}" chỉ còn $tonKho sản phẩm',
      );
    }
  }

  // =========================
  // WRITE SAU
  // =========================

  for (int i = 0; i < gio.danhSach.length; i++) {
    final item = gio.danhSach[i];

    final sp = item.sanPham;

    final snapshot = productSnapshots[i];

    final data = snapshot.data() as Map<String, dynamic>;

    final int tonKho = data['stock'] ?? 0;

    final productRef = FirebaseFirestore.instance
        .collection('products')
        .doc(sp.maSanPham);

    transaction.update(productRef, {
      'stock': tonKho - item.soLuong,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // TẠO ĐƠN HÀNG
  // =========================

  transaction.set(orderRef, {
    'orderId': maDon,
    'userId': uid,
    'userEmail': email,

    'customerInfo': {
      'name': tenKhach.text.trim(),
      'phone': soDienThoai.text.trim(),
      'address': diaChi.text.trim(),
    },

    'items': items,

    'totalAmount': tongTienDatHang,

    'paymentMethod': phuongThucThanhToan,

    'orderStatus': 'CHO_XAC_NHAN',

    'paymentStatus':
        phuongThucThanhToan == 'COD'
            ? 'CHUA_THANH_TOAN'
            : 'CHO_THANH_TOAN',

    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
});

      final tenSanPham = gio.danhSach
          .map((item) => item.sanPham.ten)
          .toList()
          .join(', ');

      final dichVuThongBao = DichVuThongBao();

      await dichVuThongBao.taoThongBaoDonHang(
        uid,
        maDon,
        tongTienDatHang,
      );

      if (email.isNotEmpty) {
        await dichVuThongBao.guiEmailDonHang(
          email,
          maDon,
          tongTienDatHang,
          tenSanPham,
        );
      }

      gio.xoaTatCa();

      if (!context.mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Đặt hàng thành công'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 56,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Mã đơn hàng: $maDon'),
                  Text('Người nhận: ${tenKhach.text.trim()}'),
                  Text('SĐT: ${soDienThoai.text.trim()}'),
                  Text('Địa chỉ: ${diaChi.text.trim()}'),
                  Text('Thanh toán: $phuongThucThanhToan'),
                  const Divider(),
                  Text(
                    'Tổng tiền: ${DinhDang.tien(tongTienDatHang)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9A5A16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Đơn hàng đã được lưu. Admin sẽ xác nhận đơn trong thời gian sớm nhất.',
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9A5A16),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Xong'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đặt hàng: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _dangDatHang = false);
      }
    }
  }

  Future<void> _xacNhanXoaSanPham(
    BuildContext context,
    String maSanPham,
    String tenSanPham,
  ) async {
    final gio = context.read<QuanLyGioHang>();

    final dongY = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa sản phẩm'),
          content: Text('Bạn có muốn xóa "$tenSanPham" khỏi giỏ hàng không?'),
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
      gio.xoa(maSanPham);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa "$tenSanPham" khỏi giỏ hàng')),
      );
    }
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
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, color: Colors.grey);
        },
      ),
    );
  }

  Widget _gioHangTrong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Giỏ hàng của bạn đang trống',
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thêm sản phẩm yêu thích vào giỏ hàng trước khi đặt mua.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemGioHang(BuildContext context, dynamic item) {
    final gio = context.read<QuanLyGioHang>();
    final sanPham = item.sanPham;
    final thanhTien = sanPham.gia * item.soLuong;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _anhSanPham(sanPham.hinhAnh),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sanPham.ten,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DinhDang.tien(sanPham.gia),
                    style: const TextStyle(
                      color: Color(0xFF9A5A16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Thành tiền: ${DinhDang.tien(thanhTien)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _nutSoLuong(
                        icon: Icons.remove,
                        onTap: () => gio.giam(sanPham.maSanPham),
                      ),
                      Container(
                        width: 38,
                        alignment: Alignment.center,
                        child: Text(
                          '${item.soLuong}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _nutSoLuong(
                        icon: Icons.add,
                        onTap: () => gio.them(sanPham),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              tooltip: 'Xóa sản phẩm',
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                _xacNhanXoaSanPham(context, sanPham.maSanPham, sanPham.ten);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutSoLuong({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF9A5A16)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF9A5A16)),
      ),
    );
  }

  Widget _thanhTongTien(BuildContext context, QuanLyGioHang gio) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng cộng (${gio.danhSach.length} sản phẩm)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  DinhDang.tien(gio.tongTien),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9A5A16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: _dangDatHang
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shopping_bag),
                label: Text(
                  _dangDatHang ? 'Đang đặt hàng...' : 'Đặt hàng',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: _dangDatHang ? null : () => _moFormDatHang(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9A5A16),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              'Bạn cần nhập địa chỉ, số điện thoại và chọn phương thức thanh toán trước khi đặt hàng.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gio = context.watch<QuanLyGioHang>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        backgroundColor: const Color(0xFF9A5A16),
        foregroundColor: Colors.white,
        actions: [
          if (gio.danhSach.isNotEmpty)
            IconButton(
              tooltip: 'Xóa toàn bộ giỏ hàng',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                final dongY = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Xóa toàn bộ giỏ hàng'),
                      content: const Text(
                        'Bạn có chắc chắn muốn xóa tất cả sản phẩm trong giỏ hàng không?',
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
                          child: const Text('Xóa tất cả'),
                        ),
                      ],
                    );
                  },
                );

                if (dongY == true) {
                  gio.xoaTatCa();
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: gio.danhSach.isEmpty
                ? _gioHangTrong()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: gio.danhSach.length,
                    itemBuilder: (context, index) {
                      return _itemGioHang(context, gio.danhSach[index]);
                    },
                  ),
          ),
          if (gio.danhSach.isNotEmpty) _thanhTongTien(context, gio),
        ],
      ),
    );
  }
}