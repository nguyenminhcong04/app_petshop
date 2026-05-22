import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuanLyLichHenNhanVien extends StatelessWidget {
  const QuanLyLichHenNhanVien({super.key});

  DateTime _layDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();

    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String _formatTime(dynamic value) {
    final d = _layDateTime(value);

    if (d.millisecondsSinceEpoch == 0) {
      return 'Không có thời gian';
    }

    final ngay = d.day.toString().padLeft(2, '0');
    final thang = d.month.toString().padLeft(2, '0');
    final nam = d.year.toString();
    final gio = d.hour.toString().padLeft(2, '0');
    final phut = d.minute.toString().padLeft(2, '0');

    return '$ngay/$thang/$nam $gio:$phut';
  }

  String _tenTrangThai(String status) {
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

  Color _mauTrangThai(String status) {
    switch (status) {
      case 'DA_DUYET':
        return Colors.green;
      case 'FULL_LICH':
        return Colors.orange;
      case 'DA_HUY':
        return Colors.red;
      case 'HOAN_THANH':
        return Colors.blueGrey;
      case 'CHO_DUYET':
      case 'DA_DAT':
      default:
        return Colors.deepOrange;
    }
  }

  IconData _iconTrangThai(String status) {
    switch (status) {
      case 'DA_DUYET':
        return Icons.check_circle;
      case 'FULL_LICH':
        return Icons.schedule;
      case 'DA_HUY':
        return Icons.cancel;
      case 'HOAN_THANH':
        return Icons.task_alt;
      case 'CHO_DUYET':
      case 'DA_DAT':
      default:
        return Icons.pending_actions;
    }
  }

  Widget _chipTrangThai(String status) {
    final color = _mauTrangThai(status);

    return Chip(
      label: Text(
        _tenTrangThai(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
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
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.trim().isEmpty ? 'Chưa có' : value)),
        ],
      ),
    );
  }

  Widget _hopGhiChu({
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

  Future<void> _xuLyLich({
    required BuildContext context,
    required String id,
    required Map<String, dynamic> data,
    required String status,
  }) async {
    final note = TextEditingController(
      text: (data['replyNote'] ?? data['storeNote'] ?? '').toString(),
    );

    final title = status == 'DA_DUYET'
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
              final ghiChu = note.text.trim();

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
                      'approvedBy': 'staff',
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                await FirebaseFirestore.instance.collection('notifications').add({
                  'type': 'APPOINTMENT_STATUS',
                  'title': 'Lịch hẹn được cập nhật',
                  'message': ghiChu.isEmpty
                      ? 'Lịch hẹn của bạn đã được cập nhật: ${_tenTrangThai(status)}'
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
                    content: Text('Đã cập nhật: ${_tenTrangThai(status)}'),
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
                controller: note,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Ghi chú cho khách',
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

  void _moChiTietLichHen(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final status = (data['status'] ?? 'CHO_DUYET').toString();
    final serviceName = (data['serviceName'] ?? 'Dịch vụ').toString();
    final userEmail = (data['userEmail'] ?? '').toString();
    final userName = (data['userName'] ?? '').toString();
    final phone = (data['phone'] ?? '').toString();
    final customerNote = (data['note'] ?? data['customerNote'] ?? '')
        .toString();
    final replyNote = (data['replyNote'] ?? data['storeNote'] ?? '').toString();

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
                        userName.isNotEmpty
                            ? userName
                            : (userEmail.isNotEmpty ? userEmail : 'Khách hàng'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Email: ${userEmail.isEmpty ? 'Chưa có' : userEmail}\n'
                        'SĐT: ${phone.isEmpty ? 'Chưa có' : phone}',
                      ),
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
                        'Thời gian: ${_formatTime(data['appointmentTime'])}',
                      ),
                    ),
                  ),

                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _mauTrangThai(status),
                        foregroundColor: Colors.white,
                        child: Icon(_iconTrangThai(status)),
                      ),
                      title: Text(
                        _tenTrangThai(status),
                        style: TextStyle(
                          color: _mauTrangThai(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Mã lịch: ${(data['appointmentId'] ?? id).toString()}',
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  _dongChiTiet('Ngày tạo', _formatTime(data['createdAt'])),
                  _dongChiTiet('Cập nhật', _formatTime(data['updatedAt'])),

                  const SizedBox(height: 8),

                  _hopGhiChu(
                    title: 'Ghi chú khách hàng',
                    value: customerNote,
                    color: Colors.grey.shade100,
                  ),

                  _hopGhiChu(
                    title: 'Ghi chú phản hồi',
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
                                  _xuLyLich(
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
                                  _xuLyLich(
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
                                  _xuLyLich(
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
                                  _xuLyLich(
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

  Widget _manHinhTrong() {
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

  Widget _itemLichHen(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final status = (data['status'] ?? 'CHO_DUYET').toString();
    final serviceName = (data['serviceName'] ?? 'Dịch vụ').toString();
    final userEmail = (data['userEmail'] ?? '').toString();
    final userName = (data['userName'] ?? '').toString();
    final customerNote = (data['note'] ?? data['customerNote'] ?? '')
        .toString();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: _mauTrangThai(status),
          foregroundColor: Colors.white,
          child: Icon(_iconTrangThai(status)),
        ),
        title: Text(
          serviceName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Khách: ${userName.isNotEmpty ? userName : (userEmail.isEmpty ? 'Chưa có email' : userEmail)}\n'
          'Thời gian: ${_formatTime(data['appointmentTime'])}\n'
          'Ghi chú: ${customerNote.isEmpty ? 'Không có' : customerNote}',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _chipTrangThai(status),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
        onTap: () => _moChiTietLichHen(context, id, data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Lỗi tải lịch hẹn: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = [...snapshot.data!.docs];

          if (docs.isEmpty) {
            return _manHinhTrong();
          }

          docs.sort((a, b) {
            final aTime = _layDateTime(a.data()['appointmentTime']);
            final bTime = _layDateTime(b.data()['appointmentTime']);
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
                return _itemLichHen(context, doc.id, doc.data());
              },
            ),
          );
        },
      ),
    );
  }
}
