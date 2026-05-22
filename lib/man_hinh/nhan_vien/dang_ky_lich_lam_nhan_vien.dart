import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DangKyLichLamNhanVien extends StatefulWidget {
  const DangKyLichLamNhanVien({super.key});

  @override
  State<DangKyLichLamNhanVien> createState() => _DangKyLichLamNhanVienState();
}

class _DangKyLichLamNhanVienState extends State<DangKyLichLamNhanVien> {
  final TextEditingController tenNhanVien = TextEditingController();

  final List<String> thu = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  final List<String> ca = ['Sáng', 'Trưa', 'Tối'];

  final Map<String, bool> lichChon = {};
  bool dangGui = false;

  @override
  void initState() {
    super.initState();

    for (final t in thu) {
      for (final c in ca) {
        lichChon['$t-$c'] = false;
      }
    }
  }

  @override
  void dispose() {
    tenNhanVien.dispose();
    super.dispose();
  }

  DateTime dauTuan(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  DateTime tuanLamTiepTheo() {
    final today = DateTime.now();
    final nextWeek = today.add(const Duration(days: 7));
    return dauTuan(nextWeek);
  }

  String keyTuan(DateTime date) {
    final d = dauTuan(date);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String keyThang(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  String hienNgay(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }

  String hienTimestamp(dynamic value) {
    if (value is Timestamp) {
      final d = value.toDate();
      return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    }

    return 'Chưa có';
  }

  bool laThuBay() {
    return DateTime.now().weekday == DateTime.saturday;
  }

  int demSoCa() {
    return lichChon.values.where((value) => value == true).length;
  }

  String lichText() {
    final list = <String>[];

    lichChon.forEach((key, value) {
      if (value == true) {
        list.add(key);
      }
    });

    return list.join(', ');
  }

  void xoaLuaChon() {
    setState(() {
      lichChon.updateAll((key, value) => false);
    });
  }

  Future<void> luuLichLam() async {
    final ten = tenNhanVien.text.trim();

    if (ten.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên nhân viên')),
      );
      return;
    }

    if (demSoCa() == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 ca làm')),
      );
      return;
    }

    final tuanLam = tuanLamTiepTheo();
    final weekStart = keyTuan(tuanLam);
    final monthKey = keyThang(tuanLam);
    final workWeekText =
        '${hienNgay(tuanLam)} - ${hienNgay(tuanLam.add(const Duration(days: 6)))}';

    setState(() => dangGui = true);

    try {
      final ref = await FirebaseFirestore.instance
          .collection('staff_schedules')
          .add({
        'staffId': ten.toLowerCase().replaceAll(' ', '_'),
        'staffName': ten,
        'scheduleText': lichText(),
        'selectedShiftCount': demSoCa(),

        'weekStart': weekStart,
        'monthKey': monthKey,
        'workWeekText': workWeekText,
        'submitRule':
            'Nhân viên gửi lịch vào thứ 7 hằng tuần cho tuần làm tiếp theo',

        'adminScheduleText': '',
        'adminNote': '',
        'adminShiftCount': 0,

        'baseSalary': 0,
        'bonus': 0,
        'allowance': 0,
        'penalty': 0,
        'totalSalary': 0,

        'status': 'CHO_ADMIN_XEP_LICH',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'STAFF_SCHEDULE',
        'title': 'Nhân viên gửi lịch làm',
        'message': '$ten đã gửi lịch làm cho tuần $workWeekText',
        'scheduleId': ref.id,
        'targetRoles': ['admin'],
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã gửi lịch làm tuần $workWeekText cho admin')),
      );

      xoaLuaChon();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi lịch làm: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => dangGui = false);
      }
    }
  }

  String hienTrangThai(String status) {
    if (status == 'CHO_ADMIN_XEP_LICH') return 'Chờ admin xếp lịch';
    if (status == 'DA_XEP_LICH') return 'Admin đã xếp lịch';
    if (status == 'DA_TU_CHOI') return 'Admin từ chối';
    return status;
  }

  Color mauTrangThai(String status) {
    if (status == 'DA_XEP_LICH') return Colors.green;
    if (status == 'DA_TU_CHOI') return Colors.red;
    return Colors.orange;
  }

  Widget chipTrangThai(String status) {
    final color = mauTrangThai(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        hienTrangThai(status),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget oChonCa(String t, String c) {
    final key = '$t-$c';
    final selected = lichChon[key] ?? false;

    return InkWell(
      onTap: () {
        setState(() {
          lichChon[key] = !selected;
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.all(4),
        height: 42,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF9A5A16) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF9A5A16) : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          selected ? Icons.check : Icons.add,
          color: selected ? Colors.white : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  Widget bangChonLich() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 70,
                    child: Center(
                      child: Text(
                        'Ca',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  ...thu.map(
                    (t) => SizedBox(
                      width: 58,
                      child: Center(
                        child: Text(
                          t,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              ...ca.map((c) {
                return Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        c,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...thu.map(
                      (t) => SizedBox(
                        width: 58,
                        child: oChonCa(t, c),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget lichDaGuiCard(Map<String, dynamic> data) {
    final status = data['status'] ?? 'CHO_ADMIN_XEP_LICH';
    final adminNote = (data['adminNote'] ?? '').toString();
    final workWeekText = (data['workWeekText'] ?? '').toString();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: mauTrangThai(status).withValues(alpha: 0.15),
                  child: Icon(Icons.work_history, color: mauTrangThai(status)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data['staffName'] ?? 'Nhân viên',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                chipTrangThai(status),
              ],
            ),
            const SizedBox(height: 12),

            if (workWeekText.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Tuần làm: $workWeekText',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

            Text(
              'Lịch đã gửi',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(data['scheduleText'] ?? 'Không có'),

            const SizedBox(height: 10),

            Text(
              'Số ca đăng ký: ${data['selectedShiftCount'] ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                adminNote.isEmpty
                    ? 'Lịch admin xếp: Chưa có'
                    : 'Lịch admin xếp: $adminNote',
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Ngày gửi: ${hienTimestamp(data['createdAt'])}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const mauChuDao = Color(0xFF9A5A16);
    final tuanLam = tuanLamTiepTheo();
    final workWeekText =
        '${hienNgay(tuanLam)} - ${hienNgay(tuanLam.add(const Duration(days: 6)))}';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: mauChuDao,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.calendar_month, color: Colors.white, size: 38),
                SizedBox(height: 10),
                Text(
                  'Đăng ký lịch làm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Gửi lịch làm để admin xếp ca cho tuần tiếp theo.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Card(
            color: Colors.orange.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: mauChuDao),
              title: const Text(
                'Quy định gửi lịch',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Nhân viên gửi lịch vào thứ 7 hằng tuần.\n'
                'Lịch này dùng để xếp ca cho tuần: $workWeekText',
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: tenNhanVien,
            decoration: InputDecoration(
              labelText: 'Tên nhân viên',
              prefixIcon: const Icon(Icons.badge),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Bảng chọn ca tuần tới',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton.icon(
                onPressed: xoaLuaChon,
                icon: const Icon(Icons.refresh),
                label: const Text('Xóa chọn'),
              ),
            ],
          ),

          bangChonLich(),

          const SizedBox(height: 12),

          Card(
            color: Colors.orange.shade50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: mauChuDao),
              title: const Text('Số ca đã chọn'),
              subtitle: Text('${demSoCa()} ca làm'),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: dangGui ? null : luuLichLam,
              icon: dangGui
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(dangGui ? 'Đang gửi...' : 'Gửi lịch làm cho admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: mauChuDao,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          const Text(
            'Lịch làm đã gửi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('staff_schedules')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Card(
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Chưa có lịch làm nào'),
                  ),
                );
              }

              return Column(
                children: docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return lichDaGuiCard(data);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}