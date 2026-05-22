import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'lib/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final db = FirebaseFirestore.instance;

  await taoSanPhamMau(db);
  await taoTaiKhoanMau(db);
  await taoLichHenMau(db);
  await taoLichLamMau(db);
  await taoChatMau(db);

  print('Đã tạo xong dữ liệu mẫu Firestore cho VuiPet.');
}

Future<void> taoSanPhamMau(FirebaseFirestore db) async {
  final products = [
    {
      'productId': 'SP001',
      'category': 'Thức ăn',
      'breed': 'Chó',
      'brand': 'Royal Canin',
      'color': '',
      'sku': 'TA-CHO-001',
      'name': 'Thức ăn hạt cho chó Royal Canin',
      'price': 185000,
      'stock': 25,
      'imageUrl':
          'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?w=800',
      'description':
          'Thức ăn hạt dinh dưỡng dành cho chó, hỗ trợ tiêu hóa và phát triển khỏe mạnh.',
      'status': true,
    },
    {
      'productId': 'SP002',
      'category': 'Thức ăn',
      'breed': 'Mèo',
      'brand': 'Whiskas',
      'color': '',
      'sku': 'TA-MEO-001',
      'name': 'Pate mèo Whiskas vị cá ngừ',
      'price': 25000,
      'stock': 80,
      'imageUrl':
          'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=800',
      'description':
          'Pate mềm thơm ngon cho mèo, phù hợp bổ sung dinh dưỡng hằng ngày.',
      'status': true,
    },
    {
      'productId': 'SP003',
      'category': 'Phụ kiện',
      'breed': 'Chó',
      'brand': 'VuiPet',
      'color': 'Đỏ',
      'sku': 'PK-CHO-001',
      'name': 'Vòng cổ thú cưng màu đỏ',
      'price': 69000,
      'stock': 40,
      'imageUrl':
          'https://images.unsplash.com/photo-1522276498395-f4f68f7f8454?w=800',
      'description':
          'Vòng cổ mềm, dễ điều chỉnh kích thước, phù hợp cho chó nhỏ và vừa.',
      'status': true,
    },
    {
      'productId': 'SP004',
      'category': 'Đồ chơi',
      'breed': 'Mèo',
      'brand': 'VuiPet',
      'color': 'Nhiều màu',
      'sku': 'DC-MEO-001',
      'name': 'Cần câu mèo lông vũ',
      'price': 45000,
      'stock': 60,
      'imageUrl':
          'https://images.unsplash.com/photo-1574144611937-0df059b5ef3e?w=800',
      'description':
          'Đồ chơi giúp mèo vận động, giảm căng thẳng và tăng tương tác với chủ.',
      'status': true,
    },
    {
      'productId': 'SP005',
      'category': 'Phụ kiện',
      'breed': 'Mèo',
      'brand': 'VuiPet',
      'color': 'Xám',
      'sku': 'PK-MEO-002',
      'name': 'Nhà cây cho mèo mini',
      'price': 520000,
      'stock': 10,
      'imageUrl':
          'https://images.unsplash.com/photo-1545249390-6bdfa286032f?w=800',
      'description':
          'Nhà cây mini cho mèo leo trèo, cào móng và nghỉ ngơi trong nhà.',
      'status': true,
    },
    {
      'productId': 'SP006',
      'category': 'Chó',
      'breed': 'Poodle',
      'brand': 'VuiPet',
      'color': 'Nâu',
      'sku': 'PET-CHO-001',
      'name': 'Chó Poodle mini',
      'price': 3500000,
      'stock': 3,
      'imageUrl':
          'https://images.unsplash.com/photo-1583511655826-05700442b31b?w=800',
      'description':
          'Poodle mini khỏe mạnh, thân thiện, phù hợp nuôi trong căn hộ.',
      'status': true,
    },
    {
      'productId': 'SP007',
      'category': 'Mèo',
      'breed': 'Anh lông ngắn',
      'brand': 'VuiPet',
      'color': 'Xám xanh',
      'sku': 'PET-MEO-001',
      'name': 'Mèo Anh lông ngắn',
      'price': 4200000,
      'stock': 2,
      'imageUrl':
          'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800',
      'description':
          'Mèo Anh lông ngắn dễ thương, hiền, phù hợp gia đình yêu thú cưng.',
      'status': true,
    },
    {
      'productId': 'SP008',
      'category': 'Spa',
      'breed': '',
      'brand': 'VuiPet',
      'color': '',
      'sku': 'DV-SPA-001',
      'name': 'Gói spa thú cưng cơ bản',
      'price': 150000,
      'stock': 100,
      'imageUrl':
          'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?w=800',
      'description': 'Gói spa gồm tắm, sấy, vệ sinh tai và cắt móng cơ bản.',
      'status': true,
    },
  ];

  for (final product in products) {
    final id = product['productId'].toString();

    await db.collection('products').doc(id).set({
      ...product,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  print('Đã tạo ${products.length} sản phẩm mẫu.');
}

Future<void> taoTaiKhoanMau(FirebaseFirestore db) async {
  final users = [
    {
      'id': 'admin_demo',
      'uid': 'admin_demo',
      'fullName': 'Quản trị viên VuiPet',
      'loginName': 'admin01',
      'passwordDemo': '123456',
      'email': 'admin@vuipet.vn',
      'phone': '0900000001',
      'address': 'Bình Dương',
      'role': 'admin',
      'isLocked': false,
    },
    {
      'id': 'staff_nv01',
      'uid': 'staff_nv01',
      'fullName': 'Nhân viên Spa',
      'loginName': 'nv01',
      'passwordDemo': '123456',
      'email': 'nv01@vuipet.vn',
      'phone': '0900000002',
      'address': 'Bình Dương',
      'role': 'staff',
      'isLocked': false,
    },
    {
      'id': 'staff_nv02',
      'uid': 'staff_nv02',
      'fullName': 'Nhân viên bán hàng',
      'loginName': 'nv02',
      'passwordDemo': '123456',
      'email': 'nv02@vuipet.vn',
      'phone': '0900000003',
      'address': 'Bình Dương',
      'role': 'staff',
      'isLocked': false,
    },
  ];

  for (final user in users) {
    final id = user['id'].toString();

    final data = Map<String, dynamic>.from(user);
    data.remove('id');

    await db.collection('users').doc(id).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  print('Đã tạo tài khoản admin/nhân viên mẫu.');
}

Future<void> taoLichHenMau(FirebaseFirestore db) async {
  final now = DateTime.now();

  final appointments = [
    {
      'appointmentId': 'LH_MAU_001',
      'userId': 'customer_demo',
      'userEmail': 'khachhang01@gmail.com',
      'userName': 'Nguyễn Văn Khách',
      'phone': '0911111111',
      'serviceName': 'Spa thú cưng',
      'appointmentTime': now.add(const Duration(days: 1)).toIso8601String(),
      'status': 'CHO_DUYET',
      'note': 'Bé chó hơi sợ nước, cần chăm nhẹ.',
      'replyNote': '',
    },
    {
      'appointmentId': 'LH_MAU_002',
      'userId': 'customer_demo',
      'userEmail': 'khachhang02@gmail.com',
      'userName': 'Trần Thị Mèo',
      'phone': '0922222222',
      'serviceName': 'Khách sạn thú cưng',
      'appointmentTime': now.add(const Duration(days: 2)).toIso8601String(),
      'status': 'DA_DUYET',
      'note': 'Gửi mèo 2 ngày.',
      'replyNote': 'Lịch đã được duyệt, vui lòng mang theo thức ăn quen thuộc.',
    },
    {
      'appointmentId': 'LH_MAU_003',
      'userId': 'customer_demo',
      'userEmail': 'khachhang03@gmail.com',
      'userName': 'Lê Minh Pet',
      'phone': '0933333333',
      'serviceName': 'Cắt móng',
      'appointmentTime': now.add(const Duration(days: 3)).toIso8601String(),
      'status': 'HOAN_THANH',
      'note': '',
      'replyNote': 'Dịch vụ đã hoàn thành.',
    },
  ];

  for (final appointment in appointments) {
    final id = appointment['appointmentId'].toString();

    await db.collection('appointments').doc(id).set({
      ...appointment,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  print('Đã tạo lịch hẹn mẫu.');
}

Future<void> taoLichLamMau(FirebaseFirestore db) async {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  final weekStart =
      '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';

  final schedule = {
    'Thứ 2': {'Sáng': true, 'Trưa': false, 'Tối': true},
    'Thứ 3': {'Sáng': false, 'Trưa': true, 'Tối': false},
    'Thứ 4': {'Sáng': true, 'Trưa': false, 'Tối': false},
    'Thứ 5': {'Sáng': false, 'Trưa': false, 'Tối': true},
    'Thứ 6': {'Sáng': true, 'Trưa': true, 'Tối': false},
    'Thứ 7': {'Sáng': false, 'Trưa': true, 'Tối': true},
    'Chủ nhật': {'Sáng': false, 'Trưa': false, 'Tối': false},
  };

  await db.collection('work_schedules').doc('staff_nv01_$weekStart').set({
    'scheduleId': 'staff_nv01_$weekStart',
    'staffId': 'staff_nv01',
    'staffEmail': 'nv01@vuipet.vn',
    'weekStart': weekStart,
    'schedule': schedule,
    'totalShifts': 8,
    'status': 'CHO_ADMIN_DUYET',
    'adminNote': '',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  print('Đã tạo lịch làm mẫu.');
}

Future<void> taoChatMau(FirebaseFirestore db) async {
  final roomId = 'room_customer_demo';

  final roomRef = db.collection('chat_rooms').doc(roomId);

  await roomRef.set({
    'roomId': roomId,
    'customerId': 'customer_demo',
    'userId': 'customer_demo',
    'createdBy': 'customer_demo',
    'customerEmail': 'khachhang01@gmail.com',
    'userEmail': 'khachhang01@gmail.com',
    'customerName': 'Nguyễn Văn Khách',
    'lastMessage': 'Shop còn thức ăn cho chó Poodle không?',
    'lastSenderRole': 'customer',
    'unreadStaff': true,
    'unreadCustomer': false,
    'unreadCountStaff': 1,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'lastMessageAt': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

  await roomRef.collection('messages').add({
    'roomId': roomId,
    'senderId': 'customer_demo',
    'senderRole': 'customer',
    'senderName': 'Nguyễn Văn Khách',
    'senderEmail': 'khachhang01@gmail.com',
    'content': 'Shop còn thức ăn cho chó Poodle không?',
    'text': 'Shop còn thức ăn cho chó Poodle không?',
    'type': 'text',
    'isRead': false,
    'createdAt': FieldValue.serverTimestamp(),
    'timestamp': DateTime.now().toIso8601String(),
  });

  print('Đã tạo phòng chat mẫu.');
}
