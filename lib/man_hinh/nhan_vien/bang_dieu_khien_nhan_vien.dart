import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../dich_vu/dich_vu_xac_thuc.dart';
import '../xac_thuc/dang_nhap.dart';
import 'chat_sos_nhan_vien.dart';
import 'dang_ky_lich_lam_nhan_vien.dart';
import 'quan_ly_lich_hen_nhan_vien.dart';

class BangDieuKhienNhanVien extends StatefulWidget {
  const BangDieuKhienNhanVien({super.key});

  @override
  State<BangDieuKhienNhanVien> createState() => _BangDieuKhienNhanVienState();
}

class _BangDieuKhienNhanVienState extends State<BangDieuKhienNhanVien> {
  int index = 0;

  final List<Widget> manHinh = const [
    ChatSosNhanVien(),
    QuanLyLichHenNhanVien(),
    DangKyLichLamNhanVien(),
  ];

  final List<String> tieuDe = const [
    'Chat hỗ trợ',
    'Lịch hẹn khách đặt',
    'Đăng ký lịch làm',
  ];

  Future<void> _xacNhanDangXuat() async {
    final dongY = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản nhân viên không?',
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
      await _dangXuat();
    }
  }

  Future<void> _dangXuat() async {
    await context.read<DichVuXacThuc>().dangXuat();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DangNhap()),
      (route) => false,
    );
  }

  Widget _thongKeNhanVien() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      color: const Color(0xFFFFFAF4),
      child: Row(
        children: [
          Expanded(
            child: _theThongKeStream(
              title: 'Chờ duyệt',
              icon: Icons.pending_actions,
              color: Colors.orange,
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .snapshots(),
              boLoc: (data) {
                final status = data['status']?.toString() ?? '';
                return status == 'CHO_DUYET' || status == 'DA_DAT';
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _theThongKeStream(
              title: 'Đã duyệt',
              icon: Icons.check_circle,
              color: Colors.green,
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .snapshots(),
              boLoc: (data) {
                final status = data['status']?.toString() ?? '';
                return status == 'DA_DUYET';
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _theThongKeStream(
              title: 'Chat',
              icon: Icons.chat,
              color: Colors.blue,
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .snapshots(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _theThongKeStream({
    required String title,
    required IconData icon,
    required Color color,
    required Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    bool Function(Map<String, dynamic> data)? boLoc,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        int count = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs;

          if (boLoc == null) {
            count = docs.length;
          } else {
            count = docs.where((doc) => boLoc(doc.data())).length;
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 5),
              Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _noiDungTheoTab() {
    return Column(
      children: [
        _thongKeNhanVien(),
        Expanded(child: manHinh[index]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: AppBar(
        title: Text(tieuDe[index]),
        centerTitle: true,
        backgroundColor: const Color(0xFF9A5A16),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: _xacNhanDangXuat,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _noiDungTheoTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Lịch hẹn',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_history_outlined),
            selectedIcon: Icon(Icons.work_history),
            label: 'Lịch làm',
          ),
        ],
      ),
    );
  }
}
