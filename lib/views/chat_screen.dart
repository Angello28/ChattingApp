import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatting_app/components/const.dart';
import 'package:chatting_app/components/responsive.dart';
import 'package:chatting_app/components/theme_data.dart';
import 'package:chatting_app/components/components.dart';
import 'package:chatting_app/function/helper.dart';
import 'package:chatting_app/function/method.dart';
import 'package:chatting_app/views/photo_screen.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shimmer/shimmer.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final Stream<QuerySnapshot> chatRoomStream;
  final String chatProfileImgUrl;
  final String tokenId;

  ChatScreen(
      {required this.chatRoomId,
      required this.chatRoomStream,
      required this.chatProfileImgUrl,
      required this.tokenId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  UserMethod userMethod = UserMethod();
  TextEditingController messageTextController = TextEditingController();
  ScrollController scrollController = ScrollController();

  Stream<QuerySnapshot> chatMessagesStream = Stream.empty();

  getThemeFromPreferences() async {
    Constants.myThemeName =
        (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  checkMessageContext(String pesan) async {
    final response = await http.post(
      Uri.parse('http://e56b-180-241-46-141.ngrok.io/sendmessage'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Access-Control-Allow-Origin": "*",
      },
      body: jsonEncode(<String, String>{
        'isipesan': pesan,
      }),
    );
    return response.body;
  }

  // ignore: non_constant_identifier_names
  ProfanityCheck() async {
    if (messageTextController.text.isNotEmpty &&
        messageTextController.text.trim().length > 0) {
      String temp = await checkMessageContext(messageTextController.text);
      print("Temp: $temp");
      var decode = jsonDecode(temp);
      var hasil = int.parse(decode['hasil prediksi']);
      print("Decode: ${hasil}");
      if (Constants.myProfanitySetting == "Sensor") {
        //Fungsi sensor
        storeMessageData(hasil, messageTextController.text);
        if (hasil == 1) {
          messageTextController.text = decode['hasil_pesan'];
          print("Hasil Prediksi: $decode['hasil prediksi']");
        }
        SendMessage();
      } else {
        storeMessageData(hasil, messageTextController.text);
        if (hasil == 0) {
          print("Hasil Prediksi: $decode['hasil prediksi']");
          SendMessage();
        } else if (hasil == 1) {
          print("Hasil Prediksi: $decode['hasil prediksi']");
          showDialog(
              context: context,
              builder: (context) {
                return SizedBox(
                    height: defaultHeight(context) / 20,
                    child: profanityChatAlert());
              });
        }
      }
    } else {
      print('Gagal');
    }
    messageTextController.text = "";
  }

  // ignore: non_constant_identifier_names
  SendMessage() {
    Map<String, dynamic> messageMap = {
      'message': messageTextController.text,
      'sendBy': Constants.myId,
      'timestamp': DateTime.now().microsecondsSinceEpoch,
      'isRead': false
    };
    userMethod.addChatMessages(widget.chatRoomId, messageMap);
    sendNotification(
        [widget.tokenId], messageTextController.text, Constants.myName);
  }

  storeMessageData(int prediction, String message) {
    Map<String, dynamic> messageMap = {
      'correction': prediction,
      'created_at': DateTime.now().toLocal(),
      'label': prediction,
      'message': messageTextController.text,
    };
    userMethod.storeChat(messageMap);
  }

  // ignore: non_constant_identifier_names
  AutoScroll(ScrollController scrollController) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        setState(() {});
        scrollController.jumpTo(
          scrollController.position.minScrollExtent,
        );
      }
    });
  }

  sendNotification(
      List<String> tokenIdList, String contents, String heading) async {
    var notification = OSCreateNotification(
      playerIds: tokenIdList,
      content: contents,
      heading: heading,
    );

    var response = await OneSignal.shared.postNotification(notification);
    setState(() {
      print("Sent notification with response: $response");
    });
  }

  @override
  void initState() {
    HelperFunction.saveIsInChatRoomSharedPreference(true);
    AutoScroll(scrollController);
    super.initState();
  }

  Widget profanityChatAlert() {
    return AlertDialog(
      backgroundColor: Constants.myTheme.backgroundColor,
      buttonPadding: Responsive.isDesktop(context)
          ? EdgeInsets.all(defaultWidth(context) / 50)
          : EdgeInsets.only(right: defaultWidth(context) / 10),
      title: Text(
        'Peringatan',
        style: TextStyle(color: Constants.myTheme.text2Color),
      ),
      content: Text(
        'Pesan anda mengandung makna kasar',
        style: TextStyle(color: Constants.myTheme.text2Color),
      ),
      actions: [
        InkWell(
          child: Text(
            'Tutup',
            style: TextStyle(color: Constants.myTheme.buttonColor),
          ),
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget interlocutorUserName(bool isLoading, String name) {
    if (!isLoading) {
      return Shimmer.fromColors(
        baseColor: Constants.myTheme.bubbleChat2,
        highlightColor: Constants.myTheme.backgroundColor,
        child: Container(
          height: defaultHeight(context) / 40,
          width: defaultWidth(context) / 5,
          color: Constants.myTheme.bubbleChat2,
        ),
      );
    } else {
      return Text(name, style: TextStyle(color: Constants.myTheme.text1Color));
    }
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return WillPopScope(
      onWillPop: () async {
        QuerySnapshot snapshot =
            await UserMethod().getEmptyChatRoom(widget.chatRoomId);
        if (snapshot.docs.isEmpty) {
          UserMethod().deleteChatMessages(widget.chatRoomId);
        }
        HelperFunction.saveIsInChatRoomSharedPreference(false);
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading:
              Responsive.isMobile(context) ? true : false,
          backgroundColor: Constants.myTheme.primaryColor,
          iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
          title: FutureBuilder(
              future: UserMethod().getUsernameById(widget.chatRoomId
                  .replaceAll("_", "")
                  .replaceAll(Constants.myId, "")),
              builder: (context, future) {
                return InkWell(
                  onTap: () {
                    if (widget.chatProfileImgUrl != "")
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PhotoScreen(
                                    title: future.data.toString(),
                                    imageUrl: widget.chatProfileImgUrl,
                                  )));
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          width: defaultHeight(context) / 20,
                          height: defaultHeight(context) / 20,
                          child: CircleAvatar(
                            maxRadius: 50,
                            minRadius: 40,
                            backgroundColor: Colors.transparent,
                            child: ClipOval(
                              child: widget.chatProfileImgUrl == ""
                                  ? Icon(Icons.account_circle,
                                      color: Constants.myTheme.buttonColor ==
                                              Constants.myTheme.primaryColor
                                          ? Colors.white
                                          : Constants.myTheme.buttonColor,
                                      size: defaultHeight(context) / 20)
                                  : CachedNetworkImage(
                                      imageUrl: widget.chatProfileImgUrl,
                                      placeholder: (context, url) => Icon(
                                          Icons.account_circle,
                                          color: Constants
                                                      .myTheme.buttonColor ==
                                                  Constants.myTheme.primaryColor
                                              ? Colors.white
                                              : Constants.myTheme.buttonColor,
                                          size: defaultHeight(context) / 20),
                                      fit: BoxFit.cover,
                                      width: defaultHeight(context) / 20,
                                      height: defaultHeight(context) / 20,
                                    ),
                            ),
                          )),
                      SizedBox(width: defaultWidth(context) / 60),
                      interlocutorUserName(
                          future.hasData, future.data.toString()),
                    ],
                  ),
                );
              }),
        ),
        body: Stack(
          children: [
            Container(
              width: defaultWidth(context),
              height: defaultHeight(context),
              color: Constants.myTheme.backgroundColor,
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: defaultHeight(context) / 150,
                        horizontal: defaultWidth(context) / 35),
                    child: MessageList(
                      chatMessagesStream: widget.chatRoomStream,
                      scrollController: scrollController,
                      chatRoomId: widget.chatRoomId,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: defaultHeight(context) / 60,
                      horizontal: defaultWidth(context) / 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          minLines: 1,
                          maxLines: 4,
                          controller: messageTextController,
                          style: TextStyle(
                              color: Constants.myTheme.text2Color,
                              fontSize: defaultHeight(context) / 50),
                          onTap: () {
                            AutoScroll(scrollController);
                          },
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide: BorderSide(
                                      color: Constants.myTheme.borderColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30)),
                                  borderSide: BorderSide(
                                      color: Constants.myTheme.buttonColor)),
                              hintText: 'Pesan',
                              hintStyle: TextStyle(
                                  color: Constants.myTheme.text2Color)),
                          enabled: true,
                        ),
                      ),
                      SizedBox(width: defaultWidth(context) / 50),
                      Container(
                        decoration: ShapeDecoration(
                          color: Constants.myTheme.buttonColor,
                          shape: CircleBorder(),
                        ),
                        child: IconButton(
                          onPressed: () {
                            ProfanityCheck();
                            AutoScroll(scrollController);
                          },
                          icon: Icon(Icons.send,
                              color: Constants.myTheme.text1Color),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
