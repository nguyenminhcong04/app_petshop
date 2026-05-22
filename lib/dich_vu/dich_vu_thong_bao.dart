import 'package:cloud_firestore/cloud_firestore.dart';

class DichVuThongBao {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');

  Future<void> taoThongBao({
    required String type,
    required String title,
    required String message,
    String targetUserId = '',
    String targetEmail = '',
    List<String> targetRoles = const [],
    Map<String, dynamic> extraData = const {},
  }) async {
    await _notifications.add({
      'type': type,
      'title': title,
      'message': message,
      'targetUserId': targetUserId,
      'targetEmail': targetEmail,
      'targetRoles': targetRoles,
      'isRead': false,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
      'timestamp': DateTime.now().toIso8601String(),
      ...extraData,
    });
  }

  Future<void> taoThongBaoDonHang(
    String userId,
    String orderId,
    int totalAmount,
  ) async {
    await taoThongBao(
      type: 'ORDER_CREATED',
      title: 'Đơn hàng mới',
      message:
          'Khách hàng vừa đặt đơn hàng $orderId với tổng tiền ${_formatTien(totalAmount)}.',
      targetRoles: const ['admin'],
      extraData: {
        'userId': userId,
        'orderId': orderId,
        'totalAmount': totalAmount,
      },
    );
  }

  Future<void> taoThongBaoCapNhatDonHang({
    required String userId,
    required String orderId,
    required String status,
    String targetEmail = '',
  }) async {
    await taoThongBao(
      type: 'ORDER_STATUS',
      title: 'Cập nhật đơn hàng',
      message:
          'Đơn hàng $orderId đã được cập nhật: ${_tenTrangThaiDon(status)}.',
      targetUserId: userId,
      targetEmail: targetEmail,
      targetRoles: const ['customer'],
      extraData: {'orderId': orderId, 'orderStatus': status},
    );
  }

  Future<void> taoThongBaoLichHen(
    String userId,
    String appointmentId,
    String serviceName,
    DateTime appointmentTime,
  ) async {
    await taoThongBao(
      type: 'APPOINTMENT_CREATED',
      title: 'Lịch hẹn mới',
      message:
          'Khách hàng vừa đặt lịch $serviceName vào lúc ${_formatNgayGio(appointmentTime)}.',
      targetRoles: const ['admin', 'staff'],
      extraData: {
        'userId': userId,
        'appointmentId': appointmentId,
        'serviceName': serviceName,
        'appointmentTime': appointmentTime.toIso8601String(),
      },
    );
  }

  Future<void> taoThongBaoCapNhatLichHen({
    required String userId,
    required String appointmentId,
    required String status,
    String note = '',
    String targetEmail = '',
  }) async {
    final noiDung = note.trim().isEmpty
        ? 'Lịch hẹn $appointmentId đã được cập nhật: ${_tenTrangThaiLichHen(status)}.'
        : note.trim();

    await taoThongBao(
      type: 'APPOINTMENT_STATUS',
      title: 'Cập nhật lịch hẹn',
      message: noiDung,
      targetUserId: userId,
      targetEmail: targetEmail,
      targetRoles: const ['customer'],
      extraData: {'appointmentId': appointmentId, 'status': status},
    );
  }

  Future<void> taoThongBaoChatKhachHang({
    required String roomId,
    required String senderId,
    required String senderEmail,
    required String message,
  }) async {
    await taoThongBao(
      type: 'CHAT_CUSTOMER',
      title: 'Tin nhắn mới từ khách hàng',
      message: message,
      targetRoles: const ['admin', 'staff'],
      extraData: {
        'roomId': roomId,
        'senderId': senderId,
        'senderEmail': senderEmail,
      },
    );
  }

  Future<void> taoThongBaoChatNhanVien({
    required String roomId,
    required String targetUserId,
    required String message,
    String targetEmail = '',
  }) async {
    await taoThongBao(
      type: 'CHAT_REPLY',
      title: 'Tin nhắn mới từ cửa hàng',
      message: message,
      targetUserId: targetUserId,
      targetEmail: targetEmail,
      targetRoles: const ['customer'],
      extraData: {'roomId': roomId},
    );
  }

  Future<void> taoThongBaoLichLamNhanVien({
    required String staffId,
    required String staffEmail,
    required String scheduleId,
    required String weekStart,
  }) async {
    await taoThongBao(
      type: 'WORK_SCHEDULE_CREATED',
      title: 'Nhân viên đăng ký lịch làm',
      message:
          '${staffEmail.isEmpty ? 'Nhân viên' : staffEmail} đã gửi lịch làm tuần $weekStart.',
      targetRoles: const ['admin'],
      extraData: {
        'staffId': staffId,
        'staffEmail': staffEmail,
        'scheduleId': scheduleId,
        'weekStart': weekStart,
      },
    );
  }

  Future<void> taoThongBaoCapNhatLichLam({
    required String staffId,
    required String staffEmail,
    required String scheduleId,
    required String status,
    String note = '',
  }) async {
    final noiDung = note.trim().isEmpty
        ? 'Lịch làm $scheduleId đã được cập nhật: ${_tenTrangThaiLichLam(status)}.'
        : note.trim();

    await taoThongBao(
      type: 'WORK_SCHEDULE_STATUS',
      title: 'Cập nhật lịch làm',
      message: noiDung,
      targetUserId: staffId,
      targetEmail: staffEmail,
      targetRoles: const ['staff'],
      extraData: {'scheduleId': scheduleId, 'status': status},
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> layTatCaThongBao() {
    return _notifications.snapshots();
  }

  Future<void> danhDauDaDoc(String notificationId) async {
    await _notifications.doc(notificationId).set({
      'isRead': true,
      'read': true,
      'readAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> xoaThongBao(String notificationId) async {
    await _notifications.doc(notificationId).delete();
  }

  Future<void> guiEmailDonHang(
    String email,
    String orderId,
    int totalAmount,
    String productNames,
  ) async {
    // Giả lập gửi email.
    // Nếu sau này tích hợp Cloud Functions hoặc EmailJS thì thay logic tại đây.
    await _db.collection('email_logs').add({
      'type': 'ORDER_CONFIRMATION',
      'to': email,
      'subject': 'Xác nhận đơn hàng $orderId',
      'message':
          'Đơn hàng $orderId gồm $productNames, tổng tiền ${_formatTien(totalAmount)} đã được ghi nhận.',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> guiEmailDatLich(
    String email,
    String appointmentId,
    String serviceName,
    DateTime appointmentTime,
  ) async {
    // Giả lập gửi email.
    // Nếu sau này tích hợp Cloud Functions hoặc EmailJS thì thay logic tại đây.
    await _db.collection('email_logs').add({
      'type': 'APPOINTMENT_CONFIRMATION',
      'to': email,
      'subject': 'Xác nhận lịch hẹn $appointmentId',
      'message':
          'Lịch hẹn $serviceName vào lúc ${_formatNgayGio(appointmentTime)} đã được ghi nhận.',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  String _formatTien(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    int count = 0;

    for (int i = text.length - 1; i >= 0; i--) {
      buffer.write(text[i]);
      count++;

      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }

    return '${buffer.toString().split('').reversed.join()}đ';
  }

  String _formatNgayGio(DateTime dateTime) {
    final ngay = dateTime.day.toString().padLeft(2, '0');
    final thang = dateTime.month.toString().padLeft(2, '0');
    final nam = dateTime.year.toString();
    final gio = dateTime.hour.toString().padLeft(2, '0');
    final phut = dateTime.minute.toString().padLeft(2, '0');

    return '$ngay/$thang/$nam $gio:$phut';
  }

  String _tenTrangThaiDon(String status) {
    switch (status) {
      case 'CHO_XAC_NHAN':
        return 'Chờ xác nhận';
      case 'CHO_DUYET':
        return 'Chờ duyệt';
      case 'DA_DUYET':
        return 'Đã duyệt';
      case 'DANG_GIAO':
        return 'Đang giao';
      case 'DA_HOAN_THANH':
      case 'HOAN_THANH':
      case 'COMPLETED':
        return 'Đã hoàn thành';
      case 'DA_HUY':
      case 'HUY':
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  String _tenTrangThaiLichHen(String status) {
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
        return status;
    }
  }

  String _tenTrangThaiLichLam(String status) {
    switch (status) {
      case 'CHO_ADMIN_DUYET':
        return 'Chờ Admin duyệt';
      case 'DA_DUYET':
        return 'Đã duyệt';
      case 'TU_CHOI':
        return 'Từ chối';
      default:
        return status;
    }
  }
}
