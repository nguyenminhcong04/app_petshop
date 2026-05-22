import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../dich_vu/dich_vu_du_lieu.dart';
import '../../dich_vu/dich_vu_thong_bao.dart';
import '../../mo_hinh/lich_hen.dart';

class DatLichDichVu extends StatefulWidget {
  const DatLichDichVu({super.key});

  @override
  State<DatLichDichVu> createState() => _DatLichDichVuState();
}

class _DatLichDichVuState extends State<DatLichDichVu> {
  final TextEditingController ghiChu = TextEditingController();

  String dichVu = 'Spa thú cưng';
  DateTime ngayHen = DateTime.now().add(const Duration(days: 1));
  TimeOfDay gioHen = const TimeOfDay(hour: 8, minute: 30);

  bool dangDatLich = false;

  final List<String> dichVuList = const [
    'Spa thú cưng',
    'Tắm thú cưng',
    'Tỉa lông',
    'Cắt móng',
    'Khách sạn thú cưng',
    'Tư vấn chăm sóc thú cưng',
  ];

  @override
  void dispose() {
    ghiChu.dispose();
    super.dispose();
  }

  DateTime get thoiGianHen {
    return DateTime(
      ngayHen.year,
      ngayHen.month,
      ngayHen.day,
      gioHen.hour,
      gioHen.minute,
    );
  }

  Future<void> chonNgay() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: ngayHen.isBefore(now)
          ? now.add(const Duration(days: 1))
          : ngayHen,
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
      helpText: 'Chọn ngày đặt lịch',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (picked != null) {
      setState(() {
        ngayHen = picked;
      });
    }
  }

  Future<void> chonGio() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: gioHen,
      helpText: 'Chọn giờ đặt lịch',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (picked != null) {
      setState(() {
        gioHen = picked;
      });
    }
  }

  Future<void> xacNhanDatLich() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đặt lịch')),
      );
      return;
    }

    final thoiGian = thoiGianHen;

    if (thoiGian.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thời gian đặt lịch phải lớn hơn hiện tại'),
        ),
      );
      return;
    }

    final dongY = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận đặt lịch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dongXacNhan('Dịch vụ', dichVu),
              _dongXacNhan('Thời gian', dinhDangNgayGio(thoiGian)),
              _dongXacNhan(
                'Ghi chú',
                ghiChu.text.trim().isEmpty ? 'Không có' : ghiChu.text.trim(),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lịch hẹn sẽ ở trạng thái chờ duyệt. Nhân viên hoặc Admin sẽ xác nhận sau.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
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
              child: const Text('Đặt lịch'),
            ),
          ],
        );
      },
    );

    if (dongY == true) {
      await datLich();
    }
  }

  Widget _dongXacNhan(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> datLich() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    setState(() {
      dangDatLich = true;
    });

    try {
      final maLich = 'LH${DateTime.now().millisecondsSinceEpoch}';
      final thoiGian = thoiGianHen;

      final lichHen = LichHen(
        maLichHen: maLich,
        maNguoiDung: user.uid,
        tenDichVu: dichVu,
        thoiGianHen: thoiGian,
        ghiChu: ghiChu.text.trim(),
        trangThai: 'CHO_DUYET',
      );

      await DichVuDuLieu().datLichHen(lichHen);

      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'APPOINTMENT_CREATED',
        'title': 'Lịch hẹn mới',
        'message': '${user.email ?? 'Khách hàng'} đã đặt lịch $dichVu',
        'userId': user.uid,
        'appointmentId': maLich,
        'serviceName': dichVu,
        'appointmentTime': thoiGian.toIso8601String(),
        'targetRoles': ['admin', 'staff'],
        'targetRole': ['admin', 'staff'],
        'isRead': false,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await DichVuThongBao().taoThongBaoLichHen(
        user.uid,
        maLich,
        dichVu,
        thoiGian,
      );

      if ((user.email ?? '').isNotEmpty) {
        await DichVuThongBao().guiEmailDatLich(
          user.email!,
          maLich,
          dichVu,
          thoiGian,
        );
      }

      if (!mounted) return;

      ghiChu.clear();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Đặt lịch thành công'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 52),
                const SizedBox(height: 12),
                _dongXacNhan('Mã lịch', maLich),
                _dongXacNhan('Dịch vụ', dichVu),
                _dongXacNhan('Thời gian', dinhDangNgayGio(thoiGian)),
                const SizedBox(height: 8),
                const Text(
                  'Lịch hẹn của bạn đã được gửi. Vui lòng theo dõi trạng thái ở danh sách bên dưới.',
                ),
              ],
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
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi đặt lịch: $e')));
    } finally {
      if (mounted) {
        setState(() {
          dangDatLich = false;
        });
      }
    }
  }

  String dinhDangNgayGio(dynamic value) {
    DateTime? dateTime;

    if (value is DateTime) {
      dateTime = value;
    } else if (value is Timestamp) {
      dateTime = value.toDate();
    } else if (value is String) {
      dateTime = DateTime.tryParse(value);
    }

    if (dateTime == null) return value?.toString() ?? 'Chưa có';

    final ngay = dateTime.day.toString().padLeft(2, '0');
    final thang = dateTime.month.toString().padLeft(2, '0');
    final nam = dateTime.year;
    final gio = dateTime.hour.toString().padLeft(2, '0');
    final phut = dateTime.minute.toString().padLeft(2, '0');

    return '$ngay/$thang/$nam $gio:$phut';
  }

  String tenTrangThai(String status) {
    switch (status) {
      case 'CHO_DUYET':
        return 'Chờ duyệt';
      case 'DA_DUYET':
        return 'Đã duyệt';
      case 'DA_HUY':
        return 'Đã hủy';
      case 'DA_DAT':
        return 'Đã đặt';
      case 'HOAN_THANH':
        return 'Hoàn thành';
      default:
        return status.isEmpty ? 'Chờ duyệt' : status;
    }
  }

  Color mauTrangThai(String status) {
    switch (status) {
      case 'DA_DUYET':
        return Colors.green;
      case 'DA_HUY':
        return Colors.red;
      case 'HOAN_THANH':
        return Colors.blueGrey;
      case 'DA_DAT':
      case 'CHO_DUYET':
      default:
        return Colors.orange;
    }
  }

  Widget chipTrangThai(String status) {
    final color = mauTrangThai(status);

    return Chip(
      label: Text(
        tenTrangThai(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget formDatLich() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đặt lịch dịch vụ',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              value: dichVu,
              decoration: const InputDecoration(
                labelText: 'Chọn dịch vụ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets),
              ),
              items: dichVuList.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    dichVu = value;
                  });
                }
              },
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: chonNgay,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(
                      '${ngayHen.day.toString().padLeft(2, '0')}/'
                      '${ngayHen.month.toString().padLeft(2, '0')}/'
                      '${ngayHen.year}',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: chonGio,
                    icon: const Icon(Icons.access_time),
                    label: Text(gioHen.format(context)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextField(
              controller: ghiChu,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                hintText: 'Ví dụ: Bé mèo hơi sợ nước, cần chăm sóc nhẹ...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9A5A16),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: dangDatLich ? null : xacNhanDatLich,
                icon: dangDatLich
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  dangDatLich ? 'Đang gửi lịch...' : 'Gửi yêu cầu đặt lịch',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget danhSachLichHen() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (uid.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Vui lòng đăng nhập để xem lịch đã đặt.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: DichVuDuLieu().layLichHenCuaNguoiDung(uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Lỗi tải lịch hẹn: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                const Text(
                  'Bạn chưa có lịch hẹn nào',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        final sortedDocs = [...docs];
        sortedDocs.sort((a, b) {
          final aTime = thoiGianTuData(a.data()['appointmentTime']);
          final bTime = thoiGianTuData(b.data()['appointmentTime']);
          return bTime.compareTo(aTime);
        });

        return ListView.builder(
          itemCount: sortedDocs.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          itemBuilder: (context, index) {
            final doc = sortedDocs[index];
            final data = doc.data();

            return itemLichHen(doc.id, data);
          },
        );
      },
    );
  }

  DateTime thoiGianTuData(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (value is DateTime) return value;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Widget itemLichHen(String id, Map<String, dynamic> data) {
    final tenDichVu = data['serviceName']?.toString() ?? 'Dịch vụ';
    final thoiGian = data['appointmentTime'];
    final trangThai = data['status']?.toString() ?? 'CHO_DUYET';
    final note = data['note']?.toString() ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: mauTrangThai(trangThai),
          foregroundColor: Colors.white,
          child: const Icon(Icons.event_available),
        ),
        title: Text(
          tenDichVu,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            'Thời gian: ${dinhDangNgayGio(thoiGian)}'
            '${note.isEmpty ? '' : '\nGhi chú: $note'}',
          ),
        ),
        isThreeLine: note.isNotEmpty,
        trailing: chipTrangThai(trangThai),
        onTap: () => xemChiTietLichHen(id, data),
      ),
    );
  }

  void xemChiTietLichHen(String id, Map<String, dynamic> data) {
    final tenDichVu = data['serviceName']?.toString() ?? 'Dịch vụ';
    final thoiGian = data['appointmentTime'];
    final trangThai = data['status']?.toString() ?? 'CHO_DUYET';
    final note = data['note']?.toString() ?? '';

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chi tiết lịch hẹn',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                _dongChiTiet(
                  'Mã lịch',
                  data['appointmentId']?.toString() ?? id,
                ),
                _dongChiTiet('Dịch vụ', tenDichVu),
                _dongChiTiet('Thời gian', dinhDangNgayGio(thoiGian)),
                _dongChiTiet('Trạng thái', tenTrangThai(trangThai)),
                _dongChiTiet('Ghi chú', note),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9A5A16),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
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
            width: 92,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? 'Chưa có' : value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lịch'),
        backgroundColor: const Color(0xFF9A5A16),
        foregroundColor: Colors.white,
      ),
      body: user == null
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Vui lòng đăng nhập để đặt lịch dịch vụ.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 400));
              },
              child: ListView(
                children: [
                  formDatLich(),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: Text(
                      'Lịch đã đặt',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  danhSachLichHen(),
                ],
              ),
            ),
    );
  }
}
