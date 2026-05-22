import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuanLyLichHenAdmin extends StatelessWidget {
  const QuanLyLichHenAdmin({super.key});

  String hienThiThoiGian(dynamic value) {
    DateTime? dateTime;

    if (value is Timestamp) {
      dateTime = value.toDate();
    } else if (value is DateTime) {
      dateTime = value;
    } else if (value is String) {
      dateTime = DateTime.tryParse(value);
    }

    if (dateTime == null) return 'Chưa có thời gian';

    final ngay = dateTime.day.toString().padLeft(2, '0');
    final thang = dateTime.month.toString().padLeft(2, '0');
    final nam = dateTime.year;
    final gio = dateTime.hour.toString().padLeft(2, '0');
    final phut = dateTime.minute.toString().padLeft(2, '0');

    return '$ngay/$thang/$nam $gio:$phut';
  }

  DateTime thoiGianTuData(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Color mauTrangThai(String status) {
    switch (status) {
      case 'DA_DUYET':
        return Colors.green;
      case 'FULL_LICH':
        return Colors.orange;
      case 'DA_HUY':
        return Colors.red;
      case 'HOAN_THANH':
        return Colors.blueGrey;
      case 'DA_DAT':
      case 'CHO_DUYET':
      default:
        return Colors.deepOrange;
    }
  }

  String tenTrangThai(String status) {
    switch (status) {
      case 'CHO_DUYET':
        return 'Chờ duyệt';
      case 'DA_DAT':
        return 'Đã đặt';
      case 'DA_DUYET':
        return 'Đã duyệt';
      case 'FULL_LICH':
        return 'Full lịch / đổi giờ';
      case 'DA_HUY':
        return 'Đã hủy';
      case 'HOAN_THANH':
        return 'Hoàn thành';
      default:
        return status.isEmpty ? 'Chờ duyệt' : status;
    }
  }

  IconData iconTrangThai(String status) {
    switch (status) {
      case 'DA_DUYET':
        return Icons.check_circle;
      case 'FULL_LICH':
        return Icons.schedule;
      case 'DA_HUY':
        return Icons.cancel;
      case 'HOAN_THANH':
        return Icons.task_alt;
      case 'DA_DAT':
      case 'CHO_DUYET':
      default:
        return Icons.pending_actions;
    }
  }

  Future<void> capNhatLichHen({
    required BuildContext context,
    required String id,
    required Map<String, dynamic> data,
    required String status,
  }) async {
    final TextEditingController ghiChuController = TextEditingController(
      text: (data['replyNote'] ?? data['storeNote'] ?? '').toString(),
    );

    final String title = status == 'DA_DUYET'
        ? 'Duyệt lịch hẹn'
        : status == 'FULL_LICH'
        ? 'Báo full lịch / đổi giờ'
        : status == 'HOAN_THANH'
        ? 'Hoàn thành lịch hẹn'
        : 'Hủy lịch hẹn';

    await showDialog(
      context: context,
      builder: (_) {
        bool dangLuu = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> luu() async {
              final String ghiChu = ghiChuController.text.trim();

              setDialogState(() {
                dangLuu = true;
              });

              try {
                await FirebaseFirestore.instance
                    .collection('appointments')
                    .doc(id)
                    .update({
                      'status': status,
                      'replyNote': ghiChu,
                      'storeNote': ghiChu,
                      'approvedBy': 'admin',
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                await FirebaseFirestore.instance.collection('notifications').add({
                  'type': 'APPOINTMENT_STATUS',
                  'title': 'Cập nhật lịch hẹn',
                  'message': ghiChu.isEmpty
                      ? 'Lịch hẹn của bạn đã được cập nhật: ${tenTrangThai(status)}'
                      : ghiChu,
                  'appointmentId': data['appointmentId'] ?? id,
                  'targetUserId': data['userId'] ?? '',
                  'targetEmail': data['userEmail'] ?? '',
                  'targetRoles': ['customer'],
                  'isRead': false,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (!context.mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã cập nhật: ${tenTrangThai(status)}'),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi cập nhật lịch hẹn: $e')),
                );
              } finally {
                if (context.mounted) {
                  setDialogState(() {
                    dangLuu = false;
                  });
                }
              }
            }

            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: ghiChuController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Ghi chú phản hồi cho khách hàng',
                  hintText: status == 'DA_DUYET'
                      ? 'Ví dụ: Lịch của bạn đã được duyệt, vui lòng đến đúng giờ.'
                      : status == 'FULL_LICH'
                      ? 'Ví dụ: Khung giờ này đã full, vui lòng chọn giờ khác.'
                      : status == 'HOAN_THANH'
                      ? 'Ví dụ: Dịch vụ đã hoàn thành, cảm ơn quý khách.'
                      : 'Ví dụ: Lịch hẹn bị hủy do không đủ thông tin.',
                  border: const OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: dangLuu ? null : () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9A5A16),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: dangLuu ? null : luu,
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

  Widget dongChiTiet(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
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

  Widget hopGhiChu({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 6, bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value.trim().isEmpty ? 'Không có ghi chú' : value),
        ),
      ],
    );
  }

  void moChiTietLichHen(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final String status = (data['status'] ?? 'CHO_DUYET').toString();
    final String userEmail = (data['userEmail'] ?? '').toString();
    final String userName = (data['userName'] ?? '').toString();
    final String phone = (data['phone'] ?? '').toString();
    final String userId = (data['userId'] ?? '').toString();
    final String serviceName = (data['serviceName'] ?? 'Dịch vụ').toString();
    final String customerNote = (data['note'] ?? data['customerNote'] ?? '')
        .toString();
    final String replyNote = (data['replyNote'] ?? data['storeNote'] ?? '')
        .toString();

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
                  const Text(
                    'Chi tiết lịch hẹn',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF9A5A16),
                        foregroundColor: Colors.white,
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        userName.isEmpty
                            ? (userEmail.isEmpty ? 'Khách hàng' : userEmail)
                            : userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Email: ${userEmail.isEmpty ? 'Chưa có' : userEmail}\n'
                        'SĐT: ${phone.isEmpty ? 'Chưa có' : phone}\n'
                        'User ID: ${userId.isEmpty ? 'Chưa có' : userId}',
                      ),
                      isThreeLine: true,
                    ),
                  ),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF9A5A16),
                        foregroundColor: Colors.white,
                        child: Icon(Icons.spa),
                      ),
                      title: Text(
                        serviceName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Thời gian: ${hienThiThoiGian(data['appointmentTime'])}',
                      ),
                    ),
                  ),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: mauTrangThai(status),
                        foregroundColor: Colors.white,
                        child: Icon(iconTrangThai(status)),
                      ),
                      title: Text(
                        tenTrangThai(status),
                        style: TextStyle(
                          color: mauTrangThai(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Mã lịch: ${(data['appointmentId'] ?? id).toString()}',
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  dongChiTiet('Ngày tạo', hienThiThoiGian(data['createdAt'])),
                  dongChiTiet('Cập nhật', hienThiThoiGian(data['updatedAt'])),

                  const SizedBox(height: 8),

                  hopGhiChu(
                    title: 'Ghi chú của khách hàng',
                    value: customerNote,
                    color: Colors.grey.shade100,
                  ),

                  hopGhiChu(
                    title: 'Ghi chú cửa hàng phản hồi',
                    value: replyNote,
                    color: Colors.orange.shade50,
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: status == 'DA_DUYET'
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  capNhatLichHen(
                                    context: context,
                                    id: id,
                                    data: data,
                                    status: 'DA_DUYET',
                                  );
                                },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Duyệt'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: status == 'FULL_LICH'
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  capNhatLichHen(
                                    context: context,
                                    id: id,
                                    data: data,
                                    status: 'FULL_LICH',
                                  );
                                },
                          icon: const Icon(Icons.schedule),
                          label: const Text('Full lịch'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: status == 'HOAN_THANH'
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  capNhatLichHen(
                                    context: context,
                                    id: id,
                                    data: data,
                                    status: 'HOAN_THANH',
                                  );
                                },
                          icon: const Icon(Icons.task_alt),
                          label: const Text('Hoàn thành'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          onPressed: status == 'DA_HUY'
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  capNhatLichHen(
                                    context: context,
                                    id: id,
                                    data: data,
                                    status: 'DA_HUY',
                                  );
                                },
                          icon: const Icon(Icons.cancel),
                          label: const Text('Hủy lịch'),
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

  Widget manHinhTrong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 76, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            const Text(
              'Chưa có lịch hẹn nào',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemLichHen(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final String status = (data['status'] ?? 'CHO_DUYET').toString();
    final String serviceName = (data['serviceName'] ?? 'Dịch vụ').toString();
    final String userEmail = (data['userEmail'] ?? '').toString();
    final String userName = (data['userName'] ?? '').toString();
    final String customerNote = (data['note'] ?? data['customerNote'] ?? '')
        .toString();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: mauTrangThai(status),
          foregroundColor: Colors.white,
          child: Icon(iconTrangThai(status)),
        ),
        title: Text(
          serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Khách: ${userName.isNotEmpty ? userName : (userEmail.isEmpty ? 'Chưa có email' : userEmail)}\n'
          'Thời gian: ${hienThiThoiGian(data['appointmentTime'])}\n'
          'Ghi chú: ${customerNote.isEmpty ? 'Không có' : customerNote}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            chipTrangThai(status),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () => moChiTietLichHen(context, id, data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: AppBar(
        title: const Text('Quản lý lịch hẹn'),
        centerTitle: true,
        backgroundColor: const Color(0xFF9A5A16),
        foregroundColor: Colors.white,
        actions: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, snapshot) {
              final int count = snapshot.data?.docs.length ?? 0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.notifications),
                  ),
                  if (count > 0)
                    Positioned(
                      top: 10,
                      right: 6,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải lịch hẹn: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = [...snapshot.data!.docs];

          if (docs.isEmpty) {
            return manHinhTrong();
          }

          docs.sort((a, b) {
            final aTime = thoiGianTuData(a.data()['appointmentTime']);
            final bTime = thoiGianTuData(b.data()['appointmentTime']);
            return bTime.compareTo(aTime);
          });

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 400));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                return itemLichHen(context, doc.id, doc.data());
              },
            ),
          );
        },
      ),
    );
  }
}
