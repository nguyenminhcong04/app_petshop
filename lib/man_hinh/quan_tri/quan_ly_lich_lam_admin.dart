import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuanLyLichLamAdmin extends StatefulWidget {
  const QuanLyLichLamAdmin({super.key});

  @override
  State<QuanLyLichLamAdmin> createState() => _QuanLyLichLamAdminState();
}

class _QuanLyLichLamAdminState extends State<QuanLyLichLamAdmin> {
  static const int tienMoiCa = 150000;

  final List<String> thu = const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  final List<String> ca = const ['Sáng', 'Trưa', 'Tối'];

  late DateTime tuanDangXem;

  @override
  void initState() {
    super.initState();
    tuanDangXem = dauTuan(DateTime.now().add(const Duration(days: 7)));
  }

  DateTime dauTuan(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  String keyTuan(DateTime date) {
    final d = dauTuan(date);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String keyThang(DateTime date) {
    final d = dauTuan(date);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}';
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

  String tien(num value) {
    return '${value.toStringAsFixed(0)}đ';
  }

  int laySo(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  Set<String> tachLich(String text) {
    return text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  String hienTrangThai(String status) {
    if (status == 'CHO_ADMIN_XEP_LICH') return 'Chờ xếp lịch';
    if (status == 'DA_XEP_LICH') return 'Đã xếp lịch';
    if (status == 'DA_TU_CHOI') return 'Đã từ chối';
    return status;
  }

  Color mauTrangThai(String status) {
    if (status == 'DA_XEP_LICH') return Colors.green;
    if (status == 'DA_TU_CHOI') return Colors.red;
    return Colors.orange;
  }

  Future<void> chonTuan() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tuanDangXem,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        tuanDangXem = dauTuan(picked);
      });
    }
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

  Widget oTomTat({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget lichTuanToi(List<QueryDocumentSnapshot> docs) {
    final nextWeek = dauTuan(DateTime.now().add(const Duration(days: 7)));
    final weekKey = keyTuan(nextWeek);

    final ds = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['weekStart'] == weekKey && data['status'] == 'DA_XEP_LICH';
    }).toList();

    return Card(
      color: Colors.brown.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.event_available, color: Color(0xFF9A5A16)),
                SizedBox(width: 8),
                Text(
                  'Lịch làm tuần tới đã lưu',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${hienNgay(nextWeek)} - ${hienNgay(nextWeek.add(const Duration(days: 6)))}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 14),
            if (ds.isEmpty)
              const Text('Chưa có lịch tuần tới được admin lưu')
            else
              ...thu.map((t) {
                final caTrongNgay = <String>[];

                for (final doc in ds) {
                  final data = doc.data() as Map<String, dynamic>;
                  final staffName = data['staffName'] ?? 'Nhân viên';
                  final lich = tachLich(data['adminScheduleText'] ?? '');

                  for (final c in ca) {
                    if (lich.contains('$t-$c')) {
                      caTrongNgay.add('$c: $staffName');
                    }
                  }
                }

                if (caTrongNgay.isEmpty) return const SizedBox();

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          t,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(child: Text(caTrongNgay.join(' | '))),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void moXepLich(BuildContext context, String id, Map<String, dynamic> data) {
    final lichNhanVienGui = tachLich(data['scheduleText'] ?? '');
    final lichCu = (data['adminScheduleText'] ?? '').toString();

    final lichAdminChon = tachLich(
      lichCu.isEmpty ? data['scheduleText'] ?? '' : lichCu,
    );

    final thuongController = TextEditingController(text: '${data['bonus'] ?? 0}');
    final phuCapController =
        TextEditingController(text: '${data['allowance'] ?? 0}');
    final phatController = TextEditingController(text: '${data['penalty'] ?? 0}');

    final tuanXep = tuanDangXem;
    final weekKey = keyTuan(tuanXep);
    final monthKey = keyThang(tuanXep);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFAF4),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final soCaTuan = lichAdminChon.length;
            final luongCa = soCaTuan * tienMoiCa;
            final thuong = laySo(thuongController.text);
            final phuCap = laySo(phuCapController.text);
            final phat = laySo(phatController.text);
            final tongLuong = luongCa + thuong + phuCap - phat;

            String lichText() => lichAdminChon.join(', ');

            Widget oNhapTien({
              required TextEditingController controller,
              required String label,
              required IconData icon,
            }) {
              return TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                onChanged: (_) => setModalState(() {}),
                decoration: InputDecoration(
                  labelText: label,
                  prefixIcon: Icon(icon),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              );
            }

            Widget oCa(String t, String c) {
              final key = '$t-$c';
              final adminChon = lichAdminChon.contains(key);
              final nvGui = lichNhanVienGui.contains(key);

              return InkWell(
                onTap: () {
                  setModalState(() {
                    if (adminChon) {
                      lichAdminChon.remove(key);
                    } else {
                      lichAdminChon.add(key);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  width: 58,
                  height: 42,
                  decoration: BoxDecoration(
                    color: adminChon
                        ? const Color(0xFF9A5A16)
                        : nvGui
                            ? Colors.orange.shade50
                            : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: adminChon
                          ? const Color(0xFF9A5A16)
                          : nvGui
                              ? Colors.orange
                              : Colors.grey.shade300,
                    ),
                  ),
                  child: Icon(
                    adminChon
                        ? Icons.check
                        : nvGui
                            ? Icons.schedule
                            : Icons.add,
                    color: adminChon
                        ? Colors.white
                        : nvGui
                            ? Colors.orange
                            : Colors.grey,
                  ),
                ),
              );
            }

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: ListView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF9A5A16),
                          Colors.orange.shade700,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['staffName'] ?? 'Nhân viên',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Xếp lịch tuần: ${hienNgay(tuanXep)} - ${hienNgay(tuanXep.add(const Duration(days: 6)))}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.orange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.schedule,
                        color: Color(0xFF9A5A16),
                      ),
                      title: const Text('Lịch nhân viên gửi'),
                      subtitle: Text(data['scheduleText'] ?? ''),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bảng xếp ca chính thức',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Cam nhạt: ca nhân viên gửi • Nâu: ca admin xếp',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                ...thu.map(
                                  (t) => SizedBox(
                                    width: 58,
                                    child: Center(
                                      child: Text(
                                        t,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ...thu.map((t) => oCa(t, c)),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: oTomTat(
                          icon: Icons.calendar_month,
                          title: 'Số ca',
                          value: '$soCaTuan',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: oTomTat(
                          icon: Icons.payments,
                          title: 'Lương ca',
                          value: tien(luongCa),
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Thưởng / phụ cấp / phạt',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: oNhapTien(
                          controller: thuongController,
                          label: 'Thưởng',
                          icon: Icons.card_giftcard,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: oNhapTien(
                          controller: phuCapController,
                          label: 'Phụ cấp',
                          icon: Icons.add_card,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  oNhapTien(
                    controller: phatController,
                    label: 'Tiền phạt',
                    icon: Icons.remove_circle,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.green.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.calculate, color: Colors.green),
                      title: const Text(
                        'Tổng lương',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Lương ca + thưởng + phụ cấp - phạt',
                      ),
                      trailing: Text(
                        tien(tongLuong),
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final staffId = data['staffId'] ??
                            (data['staffName'] ?? '')
                                .toString()
                                .toLowerCase()
                                .replaceAll(' ', '_');

                        await FirebaseFirestore.instance
                            .collection('staff_schedules')
                            .doc(id)
                            .update({
                          'staffId': staffId,
                          'adminScheduleText': lichText(),
                          'adminNote': lichText(),
                          'adminShiftCount': soCaTuan,
                          'weekStart': weekKey,
                          'monthKey': monthKey,
                          'weekSalary': luongCa,
                          'bonus': thuong,
                          'allowance': phuCap,
                          'penalty': phat,
                          'baseSalary': luongCa,
                          'totalSalary': tongLuong,
                          'status': 'DA_XEP_LICH',
                          'updatedAt': FieldValue.serverTimestamp(),
                        });

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã lưu lịch làm')),
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Lưu lịch làm'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9A5A16),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const mauChuDao = Color(0xFF9A5A16);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: AppBar(
        title: const Text('Lịch làm nhân viên'),
        centerTitle: true,
        backgroundColor: mauChuDao,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('staff_schedules')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final allDocs = snapshot.data!.docs;

          final docs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['weekStart'] == keyTuan(tuanDangXem);
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF9A5A16),
                      Colors.orange.shade700,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quản lý lịch làm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Admin đang xếp lịch cho tuần: '
                      '${hienNgay(tuanDangXem)} - '
                      '${hienNgay(tuanDangXem.add(const Duration(days: 6)))}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              lichTuanToi(allDocs),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  leading: const Icon(Icons.date_range, color: mauChuDao),
                  title: const Text('Tuần đang xem'),
                  subtitle: Text(
                    '${hienNgay(tuanDangXem)} - ${hienNgay(tuanDangXem.add(const Duration(days: 6)))}',
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: chonTuan,
                ),
              ),
              const SizedBox(height: 14),
              if (docs.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: Text('Chưa có lịch làm tuần này')),
                )
              else
                ...docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final status = data['status'] ?? 'CHO_ADMIN_XEP_LICH';

                  final soCa = laySo(
                    data['adminShiftCount'] ?? data['selectedShiftCount'] ?? 0,
                  );

                  final luongHienTai = laySo(
                    data['totalSalary'] ?? soCa * tienMoiCa,
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.orange.shade50],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => moXepLich(context, doc.id, data),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor:
                                  mauTrangThai(status).withValues(alpha: 0.15),
                              child: Icon(
                                Icons.badge,
                                color: mauTrangThai(status),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['staffName'] ?? 'Nhân viên',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Số ca đã xếp: $soCa'),
                                  Text(
                                    'Lương hiện tại: ${tien(luongHienTai)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  chipTrangThai(status),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}