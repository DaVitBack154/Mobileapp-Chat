import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_chaseapp/controller/getdate_server.dart';
import 'package:mobile_chaseapp/model/chat_model.dart';
import 'package:mobile_chaseapp/model/respon_dateserver.dart';
import 'package:mobile_chaseapp/utils/key_storage.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  RxList<ChatMessage> messages = <ChatMessage>[].obs;

  late IO.Socket socket;
  Rx<ScrollController> scoll = ScrollController().obs;
  Rx<TextEditingController> messageController = TextEditingController().obs;
  Rx<String?> name = Rx<String?>(null);
  Rx<String?> role = Rx<String?>(null);
  Rx<String?> idcard = Rx<String?>(null);
  Rx<String?> statusRead = Rx<String?>(null);
  RxList<File> selectedImages = <File>[].obs;
  RxInt readuser = 0.obs;
  var isOutOfWorkingHours = false.obs;
  Rx<DateTime?> lastSentDate = Rx<DateTime?>(null);
  var lastStatusEnd = ''.obs;
  //ส่วนใหม่
  var page = 1.obs;
  var isLoading = false.obs;
  var hasMore = true.obs;
  //ส่วนใหม่

  final DateServerController dateController = DateServerController();
  var dateServer = ''.obs;

  bool isChatRoom = false;

  @override
  void onInit() async {
    super.onInit();
    connectSocket();
    fetchUserProfile();
    DateServer dateServer = await dateController.fetchDateServer();
    DateTime dateTime = DateTime.parse(dateServer.data ?? "");
    lastSentDate.value = DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  Future<void> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      name.value = prefs.getString(KeyStorage.name);
      idcard.value = prefs.getString(KeyStorage.idCard);
      final dateString = prefs.getString(KeyStorage.lastSentDate);
      if (dateString != null) {
        lastSentDate.value = DateTime.parse(dateString);
      } else {
        lastSentDate.value = null;
      }
    } catch (error) {
      print(error);
    }
  }

  void connectSocket() {
    socket = IO.io('http://18.140.121.108:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Connected to server');
      // socket.emit('requestMessages');
      // socket.emit('initialMessages');
    });

    socket.on('initialMessagesUser', (data) {
      if (data != null && data.isNotEmpty) {
        List<dynamic> newMessages = data;
        updateMessages(newMessages);
      } else {
        hasMore.value = false;
      }
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });

    socket.on('initialMessages', (data) {
      try {
        if (data is! List) return;
        messages.value =
            data.map((json) => ChatMessage.fromJson(json)).toList();

        if (messages.isEmpty) {
          sendWelcomeMessageNotSave();
          print('No messages available.');
        }

        // socket.emit('viewsMessageV2', json.encode({'CardID': idcard.value}));
        print('Initial messages : ${messages.length}');
      } catch (e) {
        print('Error decoding initial messages: $e');
      }
    });

    socket.on('initialUsers', (data) {
      print('initialUsers $data');
      List dataUsers = data ?? [];
      if (dataUsers.isNotEmpty) {
        String? currentIdCard = idcard.value;
        int readSU = dataUsers.first?['readSU'] ?? 0;
        int readSA = dataUsers.first?['readSA'] ?? 0;
        for (int index = 0; index != messages.length; index++) {
          Map<String, dynamic> jsonMessage = messages[index].toJson();
          if (jsonMessage['id_card'] == currentIdCard) {
            if (messages[index].role == 'user' && (readSU == 0)) {
              jsonMessage['status_read'] = 'RU';
            } else if (messages[index].role == 'admin' && (readSA == 0)) {
              jsonMessage['status_read'] = 'RA';
            }
          }

          messages[index] = ChatMessage.fromJson(jsonMessage);
        }
      }
    });

    socket.on('receiveMessage', (data) {
      print('Data received: $data'); // แสดงข้อมูลที่ได้รับ

      try {
        var message = ChatMessage.fromJson(json.decode(data));
        if (message.idCard == idcard.value) {
          messages.add(message); // เพิ่มข้อความลงใน list
          print('Message : ${messages.length}');
          print('Message received: ${message.message}');
        } // แสดงข้อความที่รับ
      } catch (e) {
        print('Error decoding message: $e');
      }
    });

    // ฟังเหตุการณ์ Timeout จากเซิร์ฟเวอร์
    socket.on('outOfWorkingHours', (data) async {
      print('Received outOfWorkingHours signal: $data');
      isOutOfWorkingHours.value = data == 'หมดเวลาทำการ';
      if (data == 'หมดเวลาทำการ') {
        await sendMessageWithTimeoutCheck();
      }
    });

    socket.onConnectError((error) {
      print('Connection Error: $error');
    });

    socket.onConnectTimeout((_) {
      print('Connection Timeout');
    });
  }

  void loadMoreMessages() {
    if (isLoading.value || !hasMore.value) return;

    isLoading.value = true;

    socket.emit('viewsMessageUser',
        {'CardID': idcard.value, 'Page': page.value, 'Limit': 10});
  }

  void updateMessages(List<dynamic> newMessages) {
    // แปลงข้อมูลจาก JSON เป็น ChatMessage Model และเพิ่มลงในลิสต์
    messages
        .addAll(newMessages.map((data) => ChatMessage.fromJson(data)).toList());
    page.value++;
    isLoading.value = false;
  }

  // void setMessageV2() {
  //   socket.emit('viewsMessageV2', json.encode({'CardID': idcard.value}));
  // }

  Future<void> sendMessage(ChatMessage message) async {
    try {
      socket.emit('read-user', json.encode({'CardID': idcard.value}));
      // ส่งข้อความผ่าน socket
      socket.emit('sendMessage', json.encode(message.toJson()));
      print('Message sent: ${message.message}');
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<List<String>> uploadImages(List<File> imageFiles) async {
    final List<String> imageUrls = [];

    try {
      final request = http.MultipartRequest(
          'POST', Uri.parse('http://18.140.121.108:4000/upload/img'));
      for (var imageFile in imageFiles) {
        request.files
            .add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final responseData = jsonDecode(responseBody);

      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (responseData['status'] == true) {
        print('Upload successful: ${responseData['message']}');
        imageUrls
            .addAll(List<String>.from(responseData['data']['selectedImages']));
      } else {
        print('Upload failed: ${responseData['message']}');
      }
    } catch (e) {
      print('Error uploading images: $e');
    }

    return imageUrls;
  }

  void updateStatusRead() {
    if (idcard.value != null) {
      try {
        // ส่งข้อมูล id_card ไปยังเซิร์ฟเวอร์
        socket.emit('read-user', json.encode({'CardID': idcard.value}));
        // setMessageV2();
        // for (int index = 0; index != messages.length; index++) {
        //   Map<String, dynamic> jsonMessage = messages[index].toJson();
        //   jsonMessage['status_read'] = 'RU';
        //   messages[index] = ChatMessage.fromJson(jsonMessage);
        // }
        readuser.value = 0;
      } catch (e) {
        print('Error updating status read: $e');
      }
    } else {
      print('No id_card available');
    }
  }

  Future<String> getCurrentStatusEnd() async {
    if (idcard.value == null) return '';

    final url =
        'http://18.140.121.108:4000/getstatusend?id_card=${idcard.value}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // ตรวจสอบว่ามีรายการใน results หรือไม่
        if (data['results'].isNotEmpty) {
          // ตรวจสอบค่าของ status_end จากข้อมูลที่ได้รับ
          return data['results'][0]['status_end'] ?? '';
        } else {
          // ไม่พบรายการ
          return '';
        }
      } else {
        print('Failed to load status end: ${response.statusCode}');
        return '';
      }
    } catch (e) {
      print('Error checking status end: $e');
      return '';
    }
  }

  Future<bool> handleSendWelcomeMessage() async {
    String currentStatusEnd = await getCurrentStatusEnd();

    if (currentStatusEnd == 'Y' && lastStatusEnd.value != 'Y') {
      sendWelcomeMessage();
      lastStatusEnd.value = 'Y'; // อัปเดตสถานะล่าสุดหลังจากส่งข้อความ
      return true; // ส่งข้อความต้อนรับแล้ว
    } else if (currentStatusEnd == 'N') {
      lastStatusEnd.value = 'N'; // อัปเดตสถานะล่าสุดหากไม่เป็น 'Y'
    } else {
      lastStatusEnd.value = currentStatusEnd;
    }
    return false; // ไม่ได้ส่งข้อความ
  }

  void sendWelcomeMessage() {
    // สร้างข้อความต้อนรับ
    var welcomeMessage = ChatMessage(
      sender: 'auto',
      receiver: name.value,
      message: 'สวัสดีคุณ ${name.value} อาม่ายินดีให้บริการค่ะ',
      type: 'text',
      statusRead: 'RU',
      statusConnect: 'Y',
      statusEnd: 'N',
      idCard: idcard.value,
      role: 'admin',
      image: [],
    );

    // ตรวจสอบว่าข้อความต้อนรับนี้ยังไม่มีอยู่ในแชท
    // ส่งข้อความต้อนรับทุกครั้ง
    messages.insert(0, welcomeMessage);
    sendMessage(welcomeMessage);
  }

  void sendWelcomeMessageNotSave() {
    var welcomeMessage01 = ChatMessage(
      sender: 'auto',
      receiver: name.value,
      message:
          'สวัสดีคุณ ${name.value} อาม่ายินดีให้บริการ ต้องการสอบถามข้อมูลด้านใด ค่ะ/ครับ',
      type: 'text',
      statusRead: 'RU',
      statusConnect: 'Y',
      statusEnd: 'N',
      idCard: idcard.value,
      role: 'admin',
      image: [],
      createdAt: DateTime.now().toIso8601String(),
    );
    messages.insert(0, welcomeMessage01);
  }

  Future<void> sendMessageWithTimeoutCheck() async {
    // print(isChatRoom);
    if (lastStatusEnd.value == 'N') return;
    try {
      print('isOutOfWorkingHours.value: ${isOutOfWorkingHours.value}');

      // if (isOutOfWorkingHours.value) {
      var today = DateTime.now();
      var todayDate =
          DateTime(today.year, today.month, today.day); // เก็บวันที่ปัจจุบัน
      // ตรวจสอบว่าต้องส่งข้อความใหม่หรือไม่
      List messagesText = messages.map((e) => e.message).toList();

      if (lastSentDate.value == null ||
          lastSentDate.value != todayDate ||
          !messagesText.contains('หมดเวลาทำการแล้ว')) {
        var outTime = ChatMessage(
          sender: name.value,
          receiver: name.value,
          message:
              'ขณะนี้อยู่นอกเวลาทำการกรุณาติดต่ออีกครั้งในเวลาทำการ 08.00-20.00 น.',
          type: 'text',
          statusRead: 'RU',
          statusConnect: 'Y',
          statusEnd: 'timeout',
          idCard: idcard.value,
          role: 'admin',
          image: [],
        );
        await sendMessage(outTime);
        print('Message sent and date updated to: $todayDate');
      }
    } catch (e) {
      print('Error in sendMessageWithTimeoutCheck: $e');
    }
  }

  void triggerTimeoutEvent() {
    print('Triggering Timeout event');
    socket.emit('Timeout');
  }
}
