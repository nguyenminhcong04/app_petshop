import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NutThongBao extends StatelessWidget {
  final String role;
  final String? userId;
  final String? email;

  const NutThongBao({super.key, required this.role, this.userId, this.email});

  bool thongBaoPhuHop(Map<String, dynamic> data) {
    final targetUserId = data['targetUserId']?.toString() ?? '';
    final targetEmail = data['targetEmail']?.toString() ?? '';

    final targetRolesRaw = data['targetRoles'];
    final targetRoleRaw = data['targetRole'];

    final List<String> targetRoles = [];

    if (targetRolesRaw is List) {
      targetRoles.addAll(targetRolesRaw.map((e) => e.toString()));
    }

    if (targetRoleRaw is List) {
      targetRoles.addAll(targetRoleRaw.map((e) => e.toString()));
    } else if (targetRoleRaw != null) {
      targetRoles.add(targetRoleRaw.toString());
    }

    if (targetRoles.contains(role)) return true;

    if (userId != null && userId!.isNotEmpty && targetUserId == userId) {
      return true;
    }

    if (email != null && email!.isNotEmpty && targetEmail == email) {
      return true;
    }

    return false;
  }

  bool chuaDoc(Map<String, dynamic> data) {
    if (data['isRead'] == false) return true;
    if (data['read'] == false) return true;
    return false;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamThongBao() {
    return FirebaseFirestore.instance.collection('notifications').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: streamThongBao(),
      builder: (context, snapshot) {
        int soThongBaoChuaDoc = 0;

        if (snapshot.hasData) {
          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data();
            return thongBaoPhuHop(data) && chuaDoc(data);
          }).toList();

          soThongBaoChuaDoc = docs.length;
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Thông báo',
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManHinhThongBao(
                      role: role,
                      userId: userId,
                      email: email,
                    ),
                  ),
                );
              },
            ),
            if (soThongBaoChuaDoc > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    soThongBaoChuaDoc > 99 ? '99+' : '$soThongBaoChuaDoc',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class ManHinhThongBao extends StatelessWidget {
  final String role;
  final String? userId;
  final String? email;

  const ManHinhThongBao({
    super.key,
    required this.role,
    this.userId,
    this.email,
  });

  DateTime layDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();

    if (value is DateTime) return value;

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  String hienThiThoiGian(dynamic value) {
    final d = layDateTime(value);

    if (d.millisecondsSinceEpoch == 0) return 'Chưa có';

    final now = DateTime.now();

    final cungNgay =
        d.day == now.day && d.month == now.month && d.year == now.year;

    final gio = d.hour.toString().padLeft(2, '0');
    final phut = d.minute.toString().padLeft(2, '0');

    if (cungNgay) {
      return 'Hôm nay $gio:$phut';
    }

    final ngay = d.day.toString().padLeft(2, '0');
    final thang = d.month.toString().padLeft(2, '0');
    final nam = d.year.toString();

    return '$ngay/$thang/$nam $gio:$phut';
  }

  bool thongBaoPhuHop(Map<String, dynamic> data) {
    final targetUserId = data['targetUserId']?.toString() ?? '';
    final targetEmail = data['targetEmail']?.toString() ?? '';

    final targetRolesRaw = data['targetRoles'];
    final targetRoleRaw = data['targetRole'];

    final List<String> targetRoles = [];

    if (targetRolesRaw is List) {
      targetRoles.addAll(targetRolesRaw.map((e) => e.toString()));
    }

    if (targetRoleRaw is List) {
      targetRoles.addAll(targetRoleRaw.map((e) => e.toString()));
    } else if (targetRoleRaw != null) {
      targetRoles.add(targetRoleRaw.toString());
    }

    if (targetRoles.contains(role)) return true;

    if (userId != null && userId!.isNotEmpty && targetUserId == userId) {
      return true;
    }

    if (email != null && email!.isNotEmpty && targetEmail == email) {
      return true;
    }

    return false;
  }

  bool chuaDoc(Map<String, dynamic> data) {
    if (data['isRead'] == false) return true;
    if (data['read'] == false) return true;
    return false;
  }

  IconData iconTheoLoai(String type) {
    switch (type) {
      case 'ORDER_CREATED':
      case 'ORDER_STATUS':
        return Icons.receipt_long;
      case 'APPOINTMENT_CREATED':
      case 'APPOINTMENT_STATUS':
        return Icons.calendar_month;
      case 'CHAT_CUSTOMER':
      case 'CHAT_REPLY':
        return Icons.chat;
      case 'WORK_SCHEDULE_CREATED':
      case 'WORK_SCHEDULE_STATUS':
        return Icons.work_history;
      default:
        return Icons.notifications;
    }
  }

  Color mauTheoLoai(String type) {
    switch (type) {
      case 'ORDER_CREATED':
      case 'ORDER_STATUS':
        return Colors.blue;
      case 'APPOINTMENT_CREATED':
      case 'APPOINTMENT_STATUS':
        return Colors.green;
      case 'CHAT_CUSTOMER':
      case 'CHAT_REPLY':
        return Colors.deepPurple;
      case 'WORK_SCHEDULE_CREATED':
      case 'WORK_SCHEDULE_STATUS':
        return Colors.orange;
      default:
        return const Color(0xFF9A5A16);
    }
  }

  Future<void> danhDauDaDoc(String id) async {
    await FirebaseFirestore.instance.collection('notifications').doc(id).set({
      'isRead': true,
      'read': true,
      'readAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> danhDauTatCaDaDoc(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in docs) {
      final ref = FirebaseFirestore.instance
          .collection('notifications')
          .doc(doc.id);

      batch.set(ref, {
        'isRead': true,
        'read': true,
        'readAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    await batch.commit();
  }

  Widget manHinhTrong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 82,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'Chưa có thông báo',
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Các cập nhật về đơn hàng, lịch hẹn, chat và lịch làm sẽ hiển thị tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemThongBao(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final type = data['type']?.toString() ?? 'SYSTEM';
    final title = data['title']?.toString() ?? 'Thông báo';
    final message = data['message']?.toString() ?? '';
    final unread = chuaDoc(data);
    final color = mauTheoLoai(type);

    return Card(
      elevation: unread ? 3 : 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: unread ? color : Colors.grey.shade300,
          foregroundColor: Colors.white,
          child: Icon(iconTheoLoai(type)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: unread ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '$message\n${hienThiThoiGian(data['createdAt'] ?? data['timestamp'])}',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unread ? Colors.black87 : Colors.grey.shade700,
            ),
          ),
        ),
        isThreeLine: true,
        trailing: unread
            ? IconButton(
                tooltip: 'Đánh dấu đã đọc',
                icon: const Icon(Icons.done_all),
                color: const Color(0xFF9A5A16),
                onPressed: () async {
                  await danhDauDaDoc(id);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đánh dấu đã đọc')),
                  );
                },
              )
            : const Icon(Icons.check_circle, color: Colors.green),
        onTap: () async {
          if (unread) {
            await danhDauDaDoc(id);
          }

          if (!context.mounted) return;

          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: Text(message.isEmpty ? 'Không có nội dung' : message),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9A5A16),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: AppBar(
        title: const Text('Thông báo'),
        backgroundColor: const Color(0xFF9A5A16),
        foregroundColor: Colors.white,
        actions: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data();
                return thongBaoPhuHop(data) && chuaDoc(data);
              }).toList();

              if (docs.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Đánh dấu tất cả đã đọc',
                icon: const Icon(Icons.done_all),
                onPressed: () async {
                  await danhDauTatCaDaDoc(docs);

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã đánh dấu tất cả thông báo là đã đọc'),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Lỗi tải thông báo: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs.where((doc) {
            return thongBaoPhuHop(doc.data());
          }).toList();

          if (docs.isEmpty) {
            return manHinhTrong();
          }

          docs.sort((a, b) {
            final aTime = layDateTime(
              a.data()['createdAt'] ?? a.data()['timestamp'],
            );
            final bTime = layDateTime(
              b.data()['createdAt'] ?? b.data()['timestamp'],
            );
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

                return itemThongBao(context, doc.id, doc.data());
              },
            ),
          );
        },
      ),
    );
  }
}
