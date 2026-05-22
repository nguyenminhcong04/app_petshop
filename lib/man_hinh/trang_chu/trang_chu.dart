import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../mo_hinh/san_pham.dart';
import '../../quan_ly_trang_thai/quan_ly_gio_hang.dart';
import '../../tien_ich/dinh_dang.dart';
import '../chat/chat_khach_hang.dart';
import '../don_hang/don_hang_cua_toi.dart';
import '../gio_hang/gio_hang.dart';
import '../dat_lich/dat_lich_dich_vu.dart';
import '../san_pham/danh_sach_san_pham.dart';

class TrangChu extends StatelessWidget {
  const TrangChu({super.key});

  void moManHinh(BuildContext context, Widget manHinh) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => manHinh));
  }

  void themVaoGioHang(BuildContext context, SanPham sanPham) {
    final gio = context.read<QuanLyGioHang>();
    final ok = gio.them(sanPham);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            gio.lyDoKhongTheThem(sanPham) ?? 'Không thể thêm sản phẩm',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm "${sanPham.ten}" vào giỏ hàng')),
    );
  }

  Widget banner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9A5A16), Color(0xFFD18A35)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VuiPet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Mua sắm, đặt lịch spa và chăm sóc thú cưng dễ dàng trên điện thoại.',
                  style: TextStyle(color: Colors.white, height: 1.35),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF9A5A16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => moManHinh(context, const DanhSachSanPham()),
                  icon: const Icon(Icons.storefront),
                  label: const Text(
                    'Mua sắm ngay',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 58),
          ),
        ],
      ),
    );
  }

  Widget oChucNang({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget khuChucNangNhanh(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tieuDeMuc('Chức năng nhanh', Icons.dashboard_customize),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.82,
            children: [
              oChucNang(
                context: context,
                title: 'Cửa hàng',
                subtitle: 'Xem và mua sản phẩm',
                icon: Icons.storefront,
                color: Colors.brown,
                onTap: () => moManHinh(context, const DanhSachSanPham()),
              ),
              oChucNang(
                context: context,
                title: 'Giỏ hàng',
                subtitle: 'Kiểm tra sản phẩm đã chọn',
                icon: Icons.shopping_cart,
                color: Colors.green,
                onTap: () => moManHinh(context, const GioHang()),
              ),
              oChucNang(
                context: context,
                title: 'Đặt lịch',
                subtitle: 'Spa, tắm, khách sạn thú cưng',
                icon: Icons.calendar_month,
                color: Colors.orange,
                onTap: () => moManHinh(context, const DatLichDichVu()),
              ),
              oChucNang(
                context: context,
                title: 'Chat tư vấn',
                subtitle: 'Nhắn tin với cửa hàng',
                icon: Icons.chat,
                color: Colors.deepPurple,
                onTap: () => moManHinh(context, const ChatKhachHang()),
              ),
            ],
          ),
          const SizedBox(height: 10),
          oChucNang(
            context: context,
            title: 'Đơn hàng của tôi',
            subtitle: 'Theo dõi lịch sử và trạng thái đơn hàng',
            icon: Icons.receipt_long,
            color: Colors.blue,
            onTap: () => moManHinh(context, const DonHangCuaToi()),
          ),
        ],
      ),
    );
  }

  Widget tieuDeMuc(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9A5A16)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget dichVuNoiBat(BuildContext context) {
    final items = [
      {
        'title': 'Spa thú cưng',
        'subtitle': 'Tắm, sấy, chải lông, vệ sinh tai',
        'icon': Icons.spa,
        'color': Colors.pink,
      },
      {
        'title': 'Khách sạn thú cưng',
        'subtitle': 'Trông giữ thú cưng khi bạn bận',
        'icon': Icons.home_work,
        'color': Colors.teal,
      },
      {
        'title': 'Tư vấn chăm sóc',
        'subtitle': 'Hỗ trợ chọn thức ăn, phụ kiện phù hợp',
        'icon': Icons.support_agent,
        'color': Colors.indigo,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tieuDeMuc('Dịch vụ nổi bật', Icons.pets),
          const SizedBox(height: 8),
          ...items.map((item) {
            final color = item['color'] as Color;

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.12),
                  foregroundColor: color,
                  child: Icon(item['icon'] as IconData),
                ),
                title: Text(
                  item['title'].toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item['subtitle'].toString()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => moManHinh(context, const DatLichDichVu()),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget anhSanPham(String url) {
    if (url.trim().isEmpty) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Colors.grey, size: 36),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.grey, size: 36),
          ),
        );
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return Container(
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
    );
  }

  void xemChiTietSanPham(BuildContext context, SanPham sp) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: anhSanPham(sp.hinhAnh),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    sp.ten,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DinhDang.tien(sp.gia),
                    style: const TextStyle(
                      color: Color(0xFF9A5A16),
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.category, size: 17),
                        label: Text(
                          sp.danhMuc.isEmpty ? 'Chưa có danh mục' : sp.danhMuc,
                        ),
                      ),
                      Chip(
                        avatar: const Icon(Icons.warehouse, size: 17),
                        label: Text('Kho: ${sp.tonKho}'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.verified, size: 17),
                        label: Text(sp.trangThaiHienThi),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mô tả',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sp.moTa.isEmpty ? 'Sản phẩm chưa có mô tả.' : sp.moTa,
                    style: const TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9A5A16),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: sp.conHang
                          ? () {
                              Navigator.pop(context);
                              themVaoGioHang(context, sp);
                            }
                          : null,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Thêm vào giỏ hàng'),
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

  Widget theSanPham(BuildContext context, SanPham sp) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => xemChiTietSanPham(context, sp),
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 165,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: anhSanPham(sp.hinhAnh),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 9),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sp.ten.isEmpty ? 'Chưa có tên' : sp.ten,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      DinhDang.tien(sp.gia),
                      style: const TextStyle(
                        color: Color(0xFF9A5A16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sp.conHang
                                ? 'Còn ${sp.tonKho}'
                                : sp.trangThaiHienThi,
                            style: TextStyle(
                              color: sp.conHang ? Colors.green : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: sp.conHang
                              ? () => themVaoGioHang(context, sp)
                              : null,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: sp.conHang
                                ? const Color(0xFF9A5A16)
                                : Colors.grey.shade300,
                            foregroundColor: sp.conHang
                                ? Colors.white
                                : Colors.grey,
                            child: const Icon(
                              Icons.add_shopping_cart,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sanPhamNoiBat(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: tieuDeMuc('Sản phẩm nổi bật', Icons.shopping_bag),
              ),
              TextButton(
                onPressed: () => moManHinh(context, const DanhSachSanPham()),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 255,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .limit(8)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Lỗi tải sản phẩm: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final sanPhams = docs
                    .map((doc) {
                      return SanPham.fromMap(doc.data(), doc.id);
                    })
                    .where((sp) {
                      return sp.dangBan;
                    })
                    .toList();

                if (sanPhams.isEmpty) {
                  return const Center(
                    child: Text(
                      'Chưa có sản phẩm nổi bật',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sanPhams.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return theSanPham(context, sanPhams[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget loiIch() {
    final items = [
      {
        'icon': Icons.local_shipping,
        'title': 'Giao hàng nhanh',
        'subtitle': 'Đặt hàng dễ dàng, cửa hàng liên hệ xác nhận.',
      },
      {
        'icon': Icons.verified,
        'title': 'Sản phẩm rõ ràng',
        'subtitle': 'Quản lý tồn kho, giá bán và thông tin chi tiết.',
      },
      {
        'icon': Icons.support_agent,
        'title': 'Hỗ trợ trực tuyến',
        'subtitle': 'Chat với nhân viên khi cần tư vấn.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tieuDeMuc('Vì sao chọn VuiPet?', Icons.favorite),
          const SizedBox(height: 8),
          ...items.map((item) {
            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFE0B2),
                  foregroundColor: Color(0xFF9A5A16),
                  child: Icon(Icons.pets),
                ),
                title: Text(
                  item['title'].toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item['subtitle'].toString()),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: ListView(
          children: [
            banner(context),
            khuChucNangNhanh(context),
            dichVuNoiBat(context),
            sanPhamNoiBat(context),
            loiIch(),
          ],
        ),
      ),
    );
  }
}
