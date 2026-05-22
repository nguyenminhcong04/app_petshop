import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dich_vu/dich_vu_du_lieu.dart';
import '../../mo_hinh/san_pham.dart';
import '../../quan_ly_trang_thai/quan_ly_gio_hang.dart';
import '../../tien_ich/dinh_dang.dart';
import '../../tien_ich/ui_chung.dart';

class DanhSachSanPham extends StatefulWidget {
  const DanhSachSanPham({super.key});

  @override
  State<DanhSachSanPham> createState() => _DanhSachSanPhamState();
}

class _DanhSachSanPhamState extends State<DanhSachSanPham> {
  final TextEditingController timKiem = TextEditingController();

  String tuKhoa = '';
  String? danhMucChon;
  int giaTu = 0;
  int giaDen = 10000000;

  final List<String> danhMucLoc = [
    'Chó cảnh',
    'Mèo cảnh',
    'Thức ăn',
    'Phụ kiện',
    'Đồ chơi',
  ];

  @override
  void dispose() {
    timKiem.dispose();
    super.dispose();
  }

  void _xoaBoLoc() {
    setState(() {
      danhMucChon = null;
      giaTu = 0;
      giaDen = 1000000000;
      tuKhoa = '';
      timKiem.clear();
    });
  }

  Widget _hienThiAnhSanPham(String url) {
    if (url.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, color: Colors.grey, size: 42),
          SizedBox(height: 4),
          Text(
            'Chưa có ảnh',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;

        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (context, error, stackTrace) {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 42, color: Colors.grey),
            SizedBox(height: 8),
            Text('Ảnh lỗi', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        );
      },
    );
  }

  void _themVaoGioHang(BuildContext context, SanPham sp) {
    final gio = context.read<QuanLyGioHang>();
    final ok = gio.them(sp);

    if (!ok) {
      final lyDo = gio.lyDoKhongTheThem(sp) ?? 'Không thể thêm sản phẩm';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(lyDo)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${sp.ten}" vào giỏ hàng'),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }

  void _showFilterPanel(BuildContext context) {
    int giaTuTam = giaTu;
    int giaDenTam = giaDen;
    String? danhMucTam = danhMucChon;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lọc sản phẩm',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Danh mục',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: danhMucLoc.map((muc) {
                          final isSelected = danhMucTam == muc;

                          return FilterChip(
                            label: Text(muc),
                            selected: isSelected,
                            selectedColor: const Color(0xFFFFE0B2),
                            checkmarkColor: const Color(0xFF9A5A16),
                            onSelected: (_) {
                              setModalState(() {
                                danhMucTam = isSelected ? null : muc;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Khoảng giá',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(DinhDang.tien(giaTuTam)),
                          Text(DinhDang.tien(giaDenTam)),
                        ],
                      ),
                      RangeSlider(
                        values: RangeValues(
                          giaTuTam.toDouble(),
                          giaDenTam.toDouble(),
                        ),
                        min: 0,
                        max: 1000000000,
                        divisions: 20,
                        labels: RangeLabels(
                          DinhDang.tien(giaTuTam),
                          DinhDang.tien(giaDenTam),
                        ),
                        activeColor: const Color(0xFF9A5A16),
                        onChanged: (values) {
                          setModalState(() {
                            giaTuTam = values.start.toInt();
                            giaDenTam = values.end.toInt();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setModalState(() {
                                  danhMucTam = null;
                                  giaTuTam = 0;
                                  giaDenTam = 10000000;
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Đặt lại'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9A5A16),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  danhMucChon = danhMucTam;
                                  giaTu = giaTuTam;
                                  giaDen = giaDenTam;
                                });

                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.filter_alt),
                              label: const Text('Áp dụng'),
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
      },
    );
  }

  Widget _boLocDangApDung() {
    final coLoc = danhMucChon != null || giaTu != 0 || giaDen != 10000000;

    if (!coLoc && tuKhoa.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          if (tuKhoa.trim().isNotEmpty)
            Chip(
              label: Text('Tìm: $tuKhoa'),
              onDeleted: () {
                setState(() {
                  tuKhoa = '';
                  timKiem.clear();
                });
              },
            ),
          if (danhMucChon != null)
            Chip(
              label: Text('Danh mục: $danhMucChon'),
              onDeleted: () {
                setState(() {
                  danhMucChon = null;
                });
              },
            ),
          if (giaTu != 0 || giaDen != 10000000)
            Chip(
              label: Text('${DinhDang.tien(giaTu)} - ${DinhDang.tien(giaDen)}'),
              onDeleted: () {
                setState(() {
                  giaTu = 0;
                  giaDen = 10000000;
                });
              },
            ),
          ActionChip(
            avatar: const Icon(Icons.clear, size: 18),
            label: const Text('Xóa lọc'),
            onPressed: _xoaBoLoc,
          ),
        ],
      ),
    );
  }

  void _showProductDetail(BuildContext context, SanPham sp) {
    final gio = context.read<QuanLyGioHang>();
    final lyDoKhongThem = gio.lyDoKhongTheThem(sp);
    final coTheThem = lyDoKhongThem == null;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      height: 230,
                      width: double.infinity,
                      child: Container(
                        color: Colors.grey.shade200,
                        child: _hienThiAnhSanPham(sp.hinhAnh),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    sp.ten.isEmpty ? 'Chưa có tên sản phẩm' : sp.ten,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DinhDang.tien(sp.gia),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9A5A16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chipThongTin(
                        Icons.category,
                        sp.danhMuc.isEmpty ? 'Chưa có danh mục' : sp.danhMuc,
                      ),
                      _chipThongTin(
                        Icons.cruelty_free,
                        sp.giongLoai.isEmpty ? 'Chưa có giống' : sp.giongLoai,
                      ),
                      _chipThongTin(
                        Icons.business,
                        sp.thuongHieu.isEmpty
                            ? 'Chưa có thương hiệu'
                            : sp.thuongHieu,
                      ),
                      _chipThongTin(
                        Icons.color_lens,
                        sp.mauSac.isEmpty ? 'Chưa có màu' : sp.mauSac,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        sp.conHang
                            ? 'Còn hàng: ${sp.tonKho}'
                            : sp.trangThaiHienThi,
                        style: TextStyle(
                          color: sp.conHang ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        sp.maKho.isEmpty ? 'SKU: Chưa có' : 'SKU: ${sp.maKho}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Mô tả sản phẩm',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sp.moTa.isEmpty ? 'Sản phẩm chưa có mô tả.' : sp.moTa,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                  ),
                  if (!coTheThem) ...[
                    const SizedBox(height: 12),
                    Text(
                      lyDoKhongThem,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Thêm vào giỏ hàng'),
                      onPressed: coTheThem
                          ? () {
                              Navigator.pop(context);
                              _themVaoGioHang(context, sp);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9A5A16),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade700,
                      ),
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

  Widget _chipThongTin(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 17),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _theSanPham(BuildContext context, SanPham sp) {
    final conHang = sp.conHang;

    return GestureDetector(
      onTap: () => _showProductDetail(context, sp),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: _hienThiAnhSanPham(sp.hinhAnh),
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
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        DinhDang.tien(sp.gia),
                        style: const TextStyle(
                          color: Color(0xFF9A5A16),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conHang
                                  ? 'Còn ${sp.tonKho}'
                                  : sp.trangThaiHienThi,
                              style: TextStyle(
                                fontSize: 11,
                                color: conHang ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: conHang
                                ? () => _themVaoGioHang(context, sp)
                                : null,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: conHang
                                    ? const Color(0xFF9A5A16)
                                    : Colors.grey.shade300,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_shopping_cart,
                                color: conHang ? Colors.white : Colors.grey,
                                size: 17,
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
            if (!conHang)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.32),
                  alignment: Alignment.center,
                  child: Text(
                    sp.trangThaiHienThi.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
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
              Icons.shopping_bag_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'Không tìm thấy sản phẩm',
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Bạn hãy thử đổi từ khóa hoặc xóa bộ lọc.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = DichVuDuLieu();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9A5A16),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Lọc sản phẩm',
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterPanel(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: timKiem,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: tuKhoa.trim().isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            tuKhoa = '';
                            timKiem.clear();
                          });
                        },
                      )
                    : null,
                hintText: 'Tìm sản phẩm...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  tuKhoa = value;
                });
              },
            ),
          ),
          _boLocDangApDung(),
          Expanded(
            child: StreamBuilder<List<SanPham>>(
              stream: data.laySanPham(
                tuKhoa: tuKhoa,
                danhMuc: danhMucChon ?? '',
                giaTu: giaTu,
                giaDen: giaDen,
                chiLayDangBan: false,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return UiChung.loading();
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Lỗi tải sản phẩm: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return UiChung.trong('Không có dữ liệu sản phẩm');
                }

                final ds = snapshot.data!;

                if (ds.isEmpty) {
                  return _manHinhTrong();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 400));
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.66,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: ds.length,
                    itemBuilder: (context, index) {
                      return _theSanPham(context, ds[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
