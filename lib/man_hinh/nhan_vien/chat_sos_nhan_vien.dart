import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatSosNhanVien extends StatelessWidget {
  const ChatSosNhanVien({super.key});

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

    if (d.millisecondsSinceEpoch == 0) return '';

    final now = DateTime.now();

    final cungNgay =
        d.year == now.year && d.month == now.month && d.day == now.day;

    final gio = d.hour.toString().padLeft(2, '0');
    final phut = d.minute.toString().padLeft(2, '0');

    if (cungNgay) {
      return '$gio:$phut';
    }

    final ngay = d.day.toString().padLeft(2, '0');
    final thang = d.month.toString().padLeft(2, '0');
    final nam = d.year.toString();

    return '$ngay/$thang/$nam';
  }

  String layTenKhach(Map<String, dynamic> data) {
    final customerName = data['customerName']?.toString() ?? '';
    final customerEmail = data['customerEmail']?.toString() ?? '';
    final userEmail = data['userEmail']?.toString() ?? '';

    if (customerName.trim().isNotEmpty) return customerName;
    if (customerEmail.trim().isNotEmpty) return customerEmail;
    if (userEmail.trim().isNotEmpty) return userEmail;

    return 'Khách hàng';
  }

  String layUserIdKhach(Map<String, dynamic> data) {
    final customerId = data['customerId']?.toString() ?? '';
    final userId = data['userId']?.toString() ?? '';
    final createdBy = data['createdBy']?.toString() ?? '';

    if (customerId.isNotEmpty) return customerId;
    if (userId.isNotEmpty) return userId;
    if (createdBy.isNotEmpty) return createdBy;

    return '';
  }

  Widget manHinhTrong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 78,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'Chưa có cuộc trò chuyện',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Khi khách hàng gửi tin nhắn, phòng chat sẽ hiển thị tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemPhongChat(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final tenKhach = layTenKhach(data);
    final lastMessage = data['lastMessage']?.toString() ?? 'Chưa có tin nhắn';
    final lastMessageAt = data['lastMessageAt'] ?? data['updatedAt'];
    final unreadStaff = data['unreadStaff'] == true;
    final unreadCountStaff = data['unreadCountStaff'];

    int unreadCount = 0;
    if (unreadCountStaff is int) {
      unreadCount = unreadCountStaff;
    } else if (unreadCountStaff is num) {
      unreadCount = unreadCountStaff.toInt();
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: unreadStaff || unreadCount > 0
              ? Colors.red
              : const Color(0xFF9A5A16),
          foregroundColor: Colors.white,
          child: const Icon(Icons.person),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                tenKhach,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: unreadStaff || unreadCount > 0
                      ? FontWeight.bold
                      : FontWeight.w600,
                ),
              ),
            ),
            Text(
              hienThiThoiGian(lastMessageAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            lastMessage,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: unreadStaff || unreadCount > 0
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ),
        trailing: unreadCount > 0
            ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(fontSize: 10),
                ),
              )
            : const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () async {
          await FirebaseFirestore.instance
              .collection('chat_rooms')
              .doc(id)
              .set({
            'unreadStaff': false,
            'unreadCountStaff': 0,
          }, SetOptions(merge: true));

          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManHinhChiTietChatSosNhanVien(
                roomId: id,
                roomData: data,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('chat_rooms').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Lỗi tải danh sách chat: ${snapshot.error}',
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
            return manHinhTrong();
          }

          docs.sort((a, b) {
            final aTime =
                layDateTime(a.data()['lastMessageAt'] ?? a.data()['updatedAt']);
            final bTime =
                layDateTime(b.data()['lastMessageAt'] ?? b.data()['updatedAt']);
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
                return itemPhongChat(context, doc.id, doc.data());
              },
            ),
          );
        },
      ),
    );
  }
}

class ManHinhChiTietChatSosNhanVien extends StatefulWidget {
  final String roomId;
  final Map<String, dynamic> roomData;

  const ManHinhChiTietChatSosNhanVien({
    super.key,
    required this.roomId,
    required this.roomData,
  });

  @override
  State<ManHinhChiTietChatSosNhanVien> createState() =>
      _ManHinhChiTietChatSosNhanVienState();
}

class _ManHinhChiTietChatSosNhanVienState
    extends State<ManHinhChiTietChatSosNhanVien> {
  final TextEditingController noiDung = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool dangGui = false;

  @override
  void dispose() {
    noiDung.dispose();
    scrollController.dispose();
    super.dispose();
  }

  String layTenKhach() {
    final customerName = widget.roomData['customerName']?.toString() ?? '';
    final customerEmail = widget.roomData['customerEmail']?.toString() ?? '';
    final userEmail = widget.roomData['userEmail']?.toString() ?? '';

    if (customerName.trim().isNotEmpty) return customerName;
    if (customerEmail.trim().isNotEmpty) return customerEmail;
    if (userEmail.trim().isNotEmpty) return userEmail;

    return 'Khách hàng';
  }

  String layUserIdKhach() {
    final customerId = widget.roomData['customerId']?.toString() ?? '';
    final userId = widget.roomData['userId']?.toString() ?? '';
    final createdBy = widget.roomData['createdBy']?.toString() ?? '';

    if (customerId.isNotEmpty) return customerId;
    if (userId.isNotEmpty) return userId;
    if (createdBy.isNotEmpty) return createdBy;

    return '';
  }

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

    if (d.millisecondsSinceEpoch == 0) return '';

    final ngay = d.day.toString().padLeft(2, '0');
    final thang = d.month.toString().padLeft(2, '0');
    final gio = d.hour.toString().padLeft(2, '0');
    final phut = d.minute.toString().padLeft(2, '0');

    return '$ngay/$thang $gio:$phut';
  }

  Future<void> guiTinNhan() async {
    final text = noiDung.text.trim();

    if (text.isEmpty) return;

    setState(() {
      dangGui = true;
    });

    try {
      final roomRef = FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.roomId);

      final messageRef = roomRef.collection('messages').doc();

      await messageRef.set({
        'messageId': messageRef.id,
        'roomId': widget.roomId,
        'senderId': 'staff',
        'senderRole': 'staff',
        'senderName': 'Nhân viên',
        'content': text,
        'text': text,
        'type': 'text',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await roomRef.set({
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastSenderRole': 'staff',
        'unreadCustomer': true,
        'unreadStaff': false,
        'unreadCountStaff': 0,
        'customerId': layUserIdKhach(),
      }, SetOptions(merge: true));

      final targetUserId = layUserIdKhach();

      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'CHAT_REPLY',
        'title': 'Tin nhắn mới từ cửa hàng',
        'message': text,
        'roomId': widget.roomId,
        'targetUserId': targetUserId,
        'targetRoles': ['customer'],
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      noiDung.clear();

      await Future.delayed(const Duration(milliseconds: 250));

      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi tin nhắn: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          dangGui = false;
        });
      }
    }
  }

  bool laTinCuaNhanVien(Map<String, dynamic> data) {
    final role = data['senderRole']?.toString() ?? '';
    final senderId = data['senderId']?.toString() ?? '';

    return role == 'staff' ||
        role == 'admin' ||
        senderId == 'staff' ||
        senderId == 'admin';
  }

  Widget bongTinNhan(Map<String, dynamic> data) {
    final isStaff = laTinCuaNhanVien(data);
    final text = data['content']?.toString().isNotEmpty == true
        ? data['content'].toString()
        : data['text']?.toString() ?? '';

    return Align(
      alignment: isStaff ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isStaff ? const Color(0xFF9A5A16) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isStaff ? 14 : 3),
            bottomRight: Radius.circular(isStaff ? 3 : 14),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isStaff ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              isStaff ? 'Nhân viên' : layTenKhach(),
              style: TextStyle(
                color: isStaff ? Colors.white70 : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              text,
              style: TextStyle(
                color: isStaff ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hienThiThoiGian(data['createdAt'] ?? data['timestamp']),
              style: TextStyle(
                color: isStaff ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget danhSachTinNhan() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.roomId)
          .collection('messages')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Lỗi tải tin nhắn: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = [...snapshot.data!.docs];

        docs.sort((a, b) {
          final aTime =
              layDateTime(a.data()['createdAt'] ?? a.data()['timestamp']);
          final bTime =
              layDateTime(b.data()['createdAt'] ?? b.data()['timestamp']);
          return bTime.compareTo(aTime);
        });

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có tin nhắn trong phòng chat này.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return bongTinNhan(docs[index].data());
          },
        );
      },
    );
  }

  Widget thanhNhapTinNhan() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: noiDung,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn trả lời khách...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: dangGui ? Colors.grey : const Color(0xFF9A5A16),
              foregroundColor: Colors.white,
              child: IconButton(
                onPressed: dangGui ? null : guiTinNhan,
                icon: dangGui
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget thongTinKhach() {
    final email = widget.roomData['customerEmail']?.toString() ??
        widget.roomData['userEmail']?.toString() ??
        '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: const Color(0xFFFFF3E0),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Color(0xFF9A5A16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              email.isEmpty ? 'Đang hỗ trợ khách hàng' : 'Đang hỗ trợ: $email',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9A5A16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tenKhach = layTenKhach();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: AppBar(
        title: Text(
          tenKhach,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF9A5A16),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          thongTinKhach(),
          Expanded(child: danhSachTinNhan()),
          thanhNhapTinNhan(),
        ],
      ),
    );
  }
}
