import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatKhachHang extends StatefulWidget {
  const ChatKhachHang({super.key});

  @override
  State<ChatKhachHang> createState() => _ChatKhachHangState();
}

class _ChatKhachHangState extends State<ChatKhachHang> {
  final TextEditingController noiDung = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool dangGui = false;
  bool dangTaoPhong = false;

  User? get user => FirebaseAuth.instance.currentUser;

  String get roomId {
    final uid = user?.uid ?? '';
    return uid.isEmpty ? '' : 'room_$uid';
  }

  @override
  void initState() {
    super.initState();
    taoPhongChatNeuCan();
  }

  @override
  void dispose() {
    noiDung.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> taoPhongChatNeuCan() async {
    final currentUser = user;

    if (currentUser == null || roomId.isEmpty) return;

    setState(() {
      dangTaoPhong = true;
    });

    try {
      final roomRef = FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId);

      final doc = await roomRef.get();

      if (!doc.exists) {
        await roomRef.set({
          'roomId': roomId,
          'customerId': currentUser.uid,
          'userId': currentUser.uid,
          'createdBy': currentUser.uid,
          'customerEmail': currentUser.email ?? '',
          'userEmail': currentUser.email ?? '',
          'customerName': currentUser.displayName ?? '',
          'lastMessage': 'Khách hàng bắt đầu cuộc trò chuyện',
          'lastSenderRole': 'system',
          'unreadStaff': true,
          'unreadCustomer': false,
          'unreadCountStaff': 1,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessageAt': FieldValue.serverTimestamp(),
        });

        await roomRef.collection('messages').add({
          'roomId': roomId,
          'senderId': 'system',
          'senderRole': 'system',
          'senderName': 'Hệ thống',
          'content': 'Xin chào! VuiPet có thể hỗ trợ gì cho bạn?',
          'text': 'Xin chào! VuiPet có thể hỗ trợ gì cho bạn?',
          'type': 'text',
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        await roomRef.set({
          'customerId': currentUser.uid,
          'userId': currentUser.uid,
          'createdBy': currentUser.uid,
          'customerEmail': currentUser.email ?? '',
          'userEmail': currentUser.email ?? '',
          'customerName': currentUser.displayName ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi tạo phòng chat: $e')));
    } finally {
      if (mounted) {
        setState(() {
          dangTaoPhong = false;
        });
      }
    }
  }

  Future<void> guiTinNhan() async {
    final currentUser = user;
    final text = noiDung.text.trim();

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để chat tư vấn')),
      );
      return;
    }

    if (text.isEmpty) return;

    setState(() {
      dangGui = true;
    });

    try {
      final roomRef = FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId);

      final messageRef = roomRef.collection('messages').doc();

      await roomRef.set({
        'roomId': roomId,
        'customerId': currentUser.uid,
        'userId': currentUser.uid,
        'createdBy': currentUser.uid,
        'customerEmail': currentUser.email ?? '',
        'userEmail': currentUser.email ?? '',
        'customerName': currentUser.displayName ?? '',
        'lastMessage': text,
        'lastSenderRole': 'customer',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadStaff': true,
        'unreadCustomer': false,
        'unreadCountStaff': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await messageRef.set({
        'messageId': messageRef.id,
        'roomId': roomId,
        'senderId': currentUser.uid,
        'senderRole': 'customer',
        'senderName':
            currentUser.displayName ?? currentUser.email ?? 'Khách hàng',
        'senderEmail': currentUser.email ?? '',
        'content': text,
        'text': text,
        'type': 'text',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'timestamp': DateTime.now().toIso8601String(),
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'CHAT_CUSTOMER',
        'title': 'Tin nhắn mới từ khách hàng',
        'message': text,
        'roomId': roomId,
        'targetRoles': ['admin', 'staff'],
        'senderId': currentUser.uid,
        'senderEmail': currentUser.email ?? '',
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi gửi tin nhắn: $e')));
    } finally {
      if (mounted) {
        setState(() {
          dangGui = false;
        });
      }
    }
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

  bool laTinCuaKhach(Map<String, dynamic> data) {
    final currentUser = user;
    final senderRole = data['senderRole']?.toString() ?? '';
    final senderId = data['senderId']?.toString() ?? '';

    if (senderRole == 'customer') return true;
    if (currentUser != null && senderId == currentUser.uid) return true;

    return false;
  }

  Widget bongTinNhan(Map<String, dynamic> data) {
    final isMine = laTinCuaKhach(data);
    final role = data['senderRole']?.toString() ?? '';
    final isSystem = role == 'system';

    final text = data['content']?.toString().isNotEmpty == true
        ? data['content'].toString()
        : data['text']?.toString() ?? '';

    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9A5A16), fontSize: 13),
          ),
        ),
      );
    }

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFF9A5A16) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMine ? 14 : 3),
            bottomRight: Radius.circular(isMine ? 3 : 14),
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
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              isMine ? 'Bạn' : 'Cửa hàng',
              style: TextStyle(
                color: isMine ? Colors.white70 : Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              text,
              style: TextStyle(
                color: isMine ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hienThiThoiGian(data['createdAt'] ?? data['timestamp']),
              style: TextStyle(
                color: isMine ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget danhSachTinNhan() {
    if (roomId.isEmpty) {
      return const Center(
        child: Text(
          'Vui lòng đăng nhập để chat với cửa hàng.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(roomId)
          .collection('messages')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Lỗi tải tin nhắn: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData || dangTaoPhong) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = [...snapshot.data!.docs];

        docs.sort((a, b) {
          final aTime = layDateTime(
            a.data()['createdAt'] ?? a.data()['timestamp'],
          );
          final bTime = layDateTime(
            b.data()['createdAt'] ?? b.data()['timestamp'],
          );
          return bTime.compareTo(aTime);
        });

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'Hãy gửi tin nhắn đầu tiên để được tư vấn.',
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
                enabled: user != null && !dangGui,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: user == null
                      ? 'Vui lòng đăng nhập để chat...'
                      : 'Nhập tin nhắn...',
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
              backgroundColor: dangGui || user == null
                  ? Colors.grey
                  : const Color(0xFF9A5A16),
              foregroundColor: Colors.white,
              child: IconButton(
                onPressed: dangGui || user == null ? null : guiTinNhan,
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

  Widget thongTinHoTro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
      color: const Color(0xFFFFF3E0),
      child: const Row(
        children: [
          Icon(Icons.support_agent, size: 19, color: Color(0xFF9A5A16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bạn có thể nhắn tin để được tư vấn sản phẩm, đơn hàng hoặc dịch vụ thú cưng.',
              style: TextStyle(
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

  Widget manHinhChuaDangNhap() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Vui lòng đăng nhập để sử dụng chức năng chat tư vấn.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = user;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF4),
      appBar: AppBar(
        title: const Text('Chat tư vấn'),
        centerTitle: true,
        backgroundColor: const Color(0xFF9A5A16),
        foregroundColor: Colors.white,
      ),
      body: currentUser == null
          ? manHinhChuaDangNhap()
          : Column(
              children: [
                thongTinHoTro(),
                Expanded(child: danhSachTinNhan()),
                thanhNhapTinNhan(),
              ],
            ),
    );
  }
}
