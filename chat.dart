import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mobile_chaseapp/controller/getprofile_controller.dart';
import 'package:mobile_chaseapp/controller/logout_controller.dart';
import 'package:mobile_chaseapp/controller/update_controller.dart';
import 'package:mobile_chaseapp/getcontroller/getcontroller.dart';
import 'package:mobile_chaseapp/model/chat_model.dart';
import 'package:mobile_chaseapp/screen/chat/chat.dart';
import 'package:mobile_chaseapp/screen/login_page/login_page.dart';
import 'package:mobile_chaseapp/screen/piccode/pincode.dart';
import 'package:mobile_chaseapp/screen/profile/component/navbarprofile.dart';
import 'package:mobile_chaseapp/screen/profile/edit_profile.dart';
import 'package:mobile_chaseapp/utils/app_navigator.dart';
import 'package:mobile_chaseapp/utils/key_storage.dart';
import 'package:mobile_chaseapp/utils/my_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final LogoutController _logoutController = LogoutController();
  final ChatController chatController = Get.put(ChatController());
  final _updateController = UpdateController();
  final ProfileController profileController = ProfileController();

  Future<void> _handleLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(KeyStorage.typeCustomer);
    String? typeCustomer = prefs.getString(KeyStorage.typeCustomer);

    print(
        'TypeCustomer after removal: $typeCustomer'); // ควรเป็น null ถ้าลบสำเร็จ
  }

  @override
  void initState() {
    super.initState();
    // _handleLogout();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final query = MediaQuery.of(context);
    return MediaQuery(
      data: query.copyWith(
        // ignore: deprecated_member_use
        textScaler: TextScaler.linear(query.textScaleFactor.clamp(1.0, 1.0)),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            const Column(
              children: [
                NavbarProfile(),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(top: kToolbarHeight + 150).h,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 20.h,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey.shade200,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.edit_document,
                                      size: MyConstant.setMediaQueryWidth(
                                          context, 40),
                                      color: Color(0xFF103533),
                                    ),
                                    SizedBox(
                                      width: 30.w,
                                    ),
                                    Text(
                                      'ตั้งค่าโปรไฟล์',
                                      style: TextStyle(
                                        fontSize: MyConstant.setMediaQueryWidth(
                                            context, 28),
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF103533),
                                      ),
                                    ),
                                  ],
                                ),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 22,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfile(),
                          ),
                        );
                      },
                    ),
                  ),

                  // Container(
                  //   margin: EdgeInsets.symmetric(
                  //     horizontal: 10.w,
                  //     vertical: 10.h,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     // border: Border.all(
                  //     //   width: 1,
                  //     //   color: Colors.grey.shade100,
                  //     // ),
                  //     borderRadius: BorderRadius.circular(10),
                  //     // color: Colors.grey.shade100,
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(15),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           'ติดต่อเรา/แจ้งปัญหาการใช้งาน',
                  //           style: TextStyle(
                  //             fontSize:
                  //                 MyConstant.setMediaQueryWidth(context, 24),
                  //             // color: Color(0xFF103533),
                  //           ),
                  //         ),
                  //         SizedBox(
                  //           height: 10.h,
                  //         ),
                  //         Row(
                  //           children: [
                  //             Image.asset(
                  //               'assets/image/phonecall.png',
                  //               fit: BoxFit.fill,
                  //               height: 30.h,
                  //             ),
                  //             SizedBox(
                  //               width: 25.w,
                  //             ),
                  //             Text(
                  //               '02-855-8118',
                  //               style: TextStyle(
                  //                 fontSize: MyConstant.setMediaQueryWidth(
                  //                     context, 25),
                  //                 fontWeight: FontWeight.w600,
                  //               ),
                  //             )
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: Colors.grey.shade200,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey.shade200,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      child: Image.asset(
                                        'assets/image/call.png',
                                        width: 40.w,
                                        // height: 50.h,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 30.w,
                                    ),
                                    Container(
                                      child: Text(
                                        'แชทกับเจ้าหน้าที่',
                                        style: TextStyle(
                                          fontSize:
                                              MyConstant.setMediaQueryWidth(
                                                  context, 28),
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF103533),
                                        ),
                                      ),
                                    ),
                                    Obx(() {
                                      if (chatController.messages.isNotEmpty) {
                                        return nubStatusReadUser();
                                      }
                                      return SizedBox();
                                    })
                                  ],
                                ),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 22,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        // เรียกใช้ฟังก์ชันทั้งหมดจากแต่ละ controller
                        // ตรวจสอบสถานะและส่งข้อความต้อนรับถ้าจำเป็น
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String token = prefs.getString(KeyStorage.token) ?? '';
                        await profileController.fetchProfileData(token);

                        if (profileController.userModel.user?.starPoint == '' ||
                            profileController.userModel.user?.starPoint ==
                                null) {
                          await _updateController.fetchUpdateProfile(
                            statusStar: 'Y',
                          );
                          // print(
                          //     'tokota-> ${profileController.userModel.user?.starPoint}');
                        } else {
                          print('ให้คะแนนแล้ว');
                        }

                        await chatController.handleSendWelcomeMessage();

                        chatController
                            .connectSocket(); // เชื่อมต่อกับ Socket.io
                        chatController
                            .loadMoreMessages(); // โหลดข้อความเริ่มต้น

                        chatController.triggerTimeoutEvent();

                        // เปลี่ยนหน้าไปยัง ChatScreen เสมอ
                        chatController.isChatRoom = true;
                        await Get.to(
                          () => ChatScreen(),
                          transition: Transition.rightToLeft,
                          duration: Duration(milliseconds: 300),
                        );
                        chatController.isChatRoom = false;
                        chatController.updateStatusRead();
                        setState(() {});
                      },
                    ),
                  ),

                  const Expanded(
                    child: SizedBox(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 15.h,
                      horizontal: 20.w,
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        await _handleLogout();
                        // Get.offAll(Login());
                        AppNavigator.pushReplacementNamed(
                          PinCode.routeName,
                          arguments: const PinCodeArgs(isGotoNotif: false),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(width, 35.h),
                        backgroundColor: const Color(0xFF103533),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'ออกจากระบบ',
                        style: TextStyle(
                          fontSize: MyConstant.setMediaQueryWidth(context, 28),
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget nubStatusReadUser() {
    // final filteredMessages = chatController.messages
    //     .where((message) =>
    //         message.sender == chatController.name.value ||
    //         message.idCard == chatController.idcard.value)
    //     .toList();

    // int readuser = 0;
    // for (var element in filteredMessages) {
    //   if (element.statusRead == 'SA') {
    //     readuser = readuser + 1;
    //   }
    // }

    return chatController.readuser > 0
        ? Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "${chatController.readuser}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: MyConstant.setMediaQueryWidth(context, 22),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
