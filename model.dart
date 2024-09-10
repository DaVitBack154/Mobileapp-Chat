class ChatMessage {
  final String? id; // เพิ่ม id
  final String? sender;
  final String? message;
  final String? receiver;
  final String? type;
  final String? statusRead;
  final String? statusConnect;
  final String? idCard;
  final String? statusEnd;
  final String? role;
  final String? createdAt;
  final List<String>? image;

  ChatMessage({
    this.id, // เพิ่ม id
    this.sender,
    this.message,
    this.receiver,
    this.type,
    this.statusRead,
    this.statusConnect,
    this.idCard,
    this.statusEnd,
    this.role,
    this.createdAt,
    this.image,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'], // รับค่า id จาก json
      sender: json['sender'],
      message: json['message'],
      receiver: json['reciever'],
      type: json['type'],
      statusRead: json['status_read'],
      statusConnect: json['status_connect'],
      idCard: json['id_card'],
      statusEnd: json['status_end'],
      role: json['role'],
      createdAt: json['createdAt'],
      image: json['image'] != null
          ? List<String>.from(json['image'])
          : [], // ตรวจสอบว่ามีค่าเป็น null หรือไม่
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id, // ส่งค่า id
      'sender': sender,
      'message': message,
      'reciever': receiver,
      'type': type,
      'status_read': statusRead,
      'status_connect': statusConnect,
      'id_card': idCard,
      'status_end': statusEnd,
      'role': role,
      'createdAt': createdAt,
      'image': image,
    };
  }
}
