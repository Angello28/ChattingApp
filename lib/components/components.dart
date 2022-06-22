import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:chatting_app/components/const.dart';
import 'package:chatting_app/components/responsive.dart';
import 'package:chatting_app/components/theme_data.dart';
import 'package:chatting_app/function/method.dart';
import 'package:chatting_app/views/chat_screen.dart';
import 'package:chatting_app/views/photo_screen.dart';

Widget skeletonLoading(BuildContext context){
  return Material(
    color: Colors.transparent,
    child: Shimmer.fromColors(
      baseColor: Constants.myTheme.bubbleChat2,
      highlightColor: Constants.myTheme.backgroundColor,
      child: ListTile(
        leading: Container(
          width: defaultHeight(context)/16,
          height: defaultHeight(context)/16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Constants.myTheme.bubbleChat2,
          ),
        ),
        title: Container(
          height: defaultHeight(context)/40,
          color: Constants.myTheme.bubbleChat2
        ),
        subtitle: Container(
          height: defaultHeight(context)/60,
          color: Constants.myTheme.bubbleChat2
        ),
      ),
    ),
  );
}

// ignore: must_be_immutable
class ChatRoomTile extends StatefulWidget {
  final String username;
  final String chatRoomId;
  final String chatProfileImgUrl;
  final String tokenId;
  final void Function(String) getChatId;
  final void Function(String) getImgUrl;
  final void Function(String) getTokenId;
  final void Function(Stream<QuerySnapshot>) getChatStream;
  ChatRoomTile({
    required this.username, required this.chatRoomId, required this.chatProfileImgUrl,
    required this.tokenId, required this.getChatId, required this.getImgUrl, required this.getTokenId,
    required this.getChatStream
  });

  @override
  _ChatRoomTileState createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {
  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    if(mounted) {setState(() {});}
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return StreamBuilder<QuerySnapshot>(
        stream: UserMethod().getRecentChatMessages(widget.chatRoomId),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return FutureBuilder(
              future: UserMethod().getUsernameById(widget.username),
              builder: (context, future){
                if (future.hasData){
                  return FutureBuilder(
                    future: UserMethod().getUsernameById(snapshot.data!.docs[0]['sendBy']),
                    builder: (context, future2) => ListTile (
                      contentPadding: EdgeInsets.symmetric(
                        vertical: Responsive.isMobile(context) ? defaultHeight(context)/80 : defaultWidth(context)/100,
                        horizontal: Responsive.isMobile(context) ? defaultWidth(context)/20 : defaultHeight(context)/80
                      ),
                      leading: InkWell(
                        onTap: (){
                          if(widget.chatProfileImgUrl != "") {
                            String url = widget.chatProfileImgUrl;
                            showGeneralDialog(
                              transitionBuilder: (context, a1, a2, widget) {
                                return Transform.scale(
                                  scale: a1.value,
                                  alignment: Alignment.centerLeft,
                                  child: Opacity(
                                    opacity: a1.value,
                                    child: Dialog(
                                      backgroundColor: Colors.transparent,
                                      elevation: 0,
                                      insetPadding: EdgeInsets.symmetric(vertical: defaultWidth(context)/10, horizontal: defaultWidth(context)/10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            color: Constants.myTheme.buttonColor,
                                            width: Responsive.isDesktop(context) ? defaultWidth(context)/5 : defaultWidth(context)/1.25,
                                            padding: EdgeInsets.symmetric(
                                              vertical: defaultHeight(context)/80,
                                              horizontal: Responsive.isDesktop(context) ? defaultWidth(context)/60 : defaultWidth(context)/30
                                            ),
                                            child: Text(
                                              future.data.toString(),
                                              style: TextStyle(
                                                color: Constants.myTheme.text1Color,
                                                fontSize: defaultHeight(context)/40
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoScreen(
                                                title: future.data.toString(),
                                                imageUrl: url,
                                              )));
                                            },
                                            child: Container(
                                              width: Responsive.isDesktop(context) ? defaultWidth(context)/5 : defaultWidth(context)/1.25,
                                              height: Responsive.isDesktop(context) ? defaultWidth(context)/5 : defaultWidth(context)/1.25,
                                              child: SingleChildScrollView(
                                                child: CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  imageUrl: url,
                                                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                                                  CircularProgressIndicator(
                                                    backgroundColor: Colors.transparent,
                                                    color: Constants.myTheme.buttonColor,
                                                    value: downloadProgress.progress,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ),
                                );
                              },
                              transitionDuration: Duration(milliseconds: 200),
                              barrierDismissible: true,
                              barrierLabel: '',
                              context: context,
                              pageBuilder: (context, animation1, animation2) {throw false;}
                            );
                          }
                        },
                        child: Container(
                          width: defaultHeight(context)/16,
                          height: defaultHeight(context)/16,
                          child: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            maxRadius: 50,
                            minRadius: 40,
                            child: ClipOval(
                              child: widget.chatProfileImgUrl == "" ?
                              Icon(
                                Icons.account_circle,
                                color: Constants.myTheme.buttonColor,
                                size: defaultHeight(context)/16,
                              )
                                  :
                              CachedNetworkImage(
                                imageUrl: widget.chatProfileImgUrl,
                                placeholder: (context, url) => Container(
                                  width: defaultHeight(context)/16,
                                  height: defaultHeight(context)/16,
                                  child: Icon(
                                    Icons.account_circle,
                                    color: Constants.myTheme.buttonColor,
                                    size: defaultHeight(context)/16
                                  )
                                ),
                                fit: BoxFit.cover,
                                width: defaultHeight(context)/16,
                                height: defaultHeight(context)/16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      trailing: Text(
                        FormattingMethod().recentDateMessageFormat(
                          DateTime.fromMicrosecondsSinceEpoch(snapshot.data!.docs[0]['timestamp'])
                        ),
                        style: TextStyle(
                          fontSize: defaultHeight(context)/70,
                          color: Constants.myTheme.text2Color
                        )
                      ),
                      title: Text(
                        future.data.toString(),
                        style: TextStyle(
                          fontSize: defaultHeight(context)/40,
                          color: Constants.myTheme.text2Color,
                        )
                      ),
                      subtitle: FutureBuilder(
                        future: UserMethod().getStatusUnreadMessage(
                          widget.chatRoomId.replaceAll("_", "").replaceAll(Constants.myId, ""),
                          widget.chatRoomId
                        ),
                        builder: (context, future3){
                          if(future3.hasData){
                            return Text(
                              FormattingMethod().recentMessageFormat(snapshot.data!.docs[0]['message'], future2.data.toString()),
                              style: TextStyle(
                                fontSize: defaultHeight(context)/60,
                                color: Constants.myTheme.text2Color,
                                fontWeight: future3.data == false ? FontWeight.bold : FontWeight.normal
                              )
                            );
                          }
                          else{
                            return Shimmer.fromColors(
                              baseColor: Constants.myTheme.bubbleChat2,
                              highlightColor: Constants.myTheme.backgroundColor,
                              child: Container(
                                height: defaultHeight(context)/60,
                                color: Constants.myTheme.bubbleChat2
                              ),
                            );
                          }
                        }
                      ),
                      onTap: (){
                        if(Responsive.isMobile(context)){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                            chatRoomId: widget.chatRoomId,
                            chatRoomStream: UserMethod().getChatMessages(widget.chatRoomId),
                            chatProfileImgUrl: widget.chatProfileImgUrl,
                            tokenId: widget.tokenId,
                          )));
                        }
                        else{
                          setState(() {
                            widget.getChatId(widget.chatRoomId);
                            widget.getChatStream(UserMethod().getChatMessages(widget.chatRoomId));
                            widget.getImgUrl(widget.chatProfileImgUrl);
                            widget.getTokenId(widget.tokenId);
                          });
                        }
                      },
                      onLongPress: (){
                        showDialog(
                          context: context,
                          builder: (context){
                            return AlertDialog(
                              backgroundColor: Constants.myTheme.backgroundColor,
                              buttonPadding: Responsive.isDesktop(context) ? EdgeInsets.all(defaultWidth(context)/50) : EdgeInsets.only(right: defaultWidth(context)/10),
                              title: Text(
                                'Hapus Obrolan (${future.data.toString()})',
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                              ),
                              content: Text(
                                'Peringatan: Anda tidak bisa mengembalikan percakapan ini ketika sudah dihapus. Apakah anda yakin ingin menghapus percakapan?',
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                              ),
                              actions: [
                                InkWell(
                                  child: Text(
                                    'Batal',
                                    style: TextStyle(
                                      color: Constants.myTheme.text2Color
                                    ),
                                  ),
                                  onTap: () => Navigator.pop(context),
                                ),
                                InkWell(
                                  child: Text(
                                    'Hapus',
                                    style: TextStyle(
                                        color: Constants.myTheme.buttonColor
                                    ),
                                  ),
                                  onTap: () {
                                    UserMethod().deleteChatMessages(widget.chatRoomId);
                                    widget.getChatId("");
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          }
                        );
                      },
                    )
                  );
                }
                else{
                  return skeletonLoading(context);
                }
              }
            );
          }
          else{
            return skeletonLoading(context);
          }
        }
    );
  }
}

class ChatRoomList extends StatefulWidget {
  final Stream<QuerySnapshot> chatRoomStream;
  final void Function(String) getChatIdFromList;
  final void Function(String) getImgUrlFromList;
  final void Function(String) getTokenIdFromList;
  final void Function(Stream<QuerySnapshot>) getStreamFromList;
  ChatRoomList({
    required this.chatRoomStream, required this.getChatIdFromList, required this.getImgUrlFromList,
    required this.getTokenIdFromList, required this.getStreamFromList
  });

  @override
  _ChatRoomListState createState() => _ChatRoomListState();
}

class _ChatRoomListState extends State<ChatRoomList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.chatRoomStream,
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return SizedBox(
            width: defaultWidth(context),
            height: defaultHeight(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: defaultHeight(context)/50),
                Text('Belum ada percakapan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.myTheme.text2Color,
                    fontSize: defaultHeight(context)/35,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: defaultHeight(context)/50),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Mohon tunggu atau tekan ',
                        style: TextStyle(
                          color: Constants.myTheme.text2Color,
                          fontSize: defaultHeight(context)/60,
                        ),
                      ),
                      WidgetSpan(
                        child: Icon(
                          Icons.autorenew,
                          color: Constants.myTheme.text2Color,
                          size: defaultHeight(context)/55,
                        ),
                      ),
                      TextSpan(
                        text: ' untuk memuat ulang percakapan',
                        style: TextStyle(
                          color: Constants.myTheme.text2Color,
                          fontSize: defaultHeight(context)/60,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        if(snapshot.data!.docs.isNotEmpty) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: defaultWidth(context)/100),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index){
                return FutureBuilder(
                  future: UserMethod().getProfileImageById(
                    snapshot.data!.docs[index]['chatroomid'].toString().replaceAll("_", "").replaceAll(Constants.myId, ""),
                  ),
                  builder: (context, future){
                    return FutureBuilder(
                      future: UserMethod().getTokenById(
                        snapshot.data!.docs[index]['chatroomid'].toString().replaceAll("_", "").replaceAll(Constants.myId, ""),
                      ),
                      builder: (context, future2){
                        return ChatRoomTile(
                          username: snapshot.data!.docs[index]['chatroomid'].toString().replaceAll("_", "").replaceAll(Constants.myId, ""),
                          chatRoomId: snapshot.data!.docs[index]['chatroomid'],
                          chatProfileImgUrl: future.data.toString(),
                          tokenId: future2.data.toString(),
                          getChatId: widget.getChatIdFromList,
                          getChatStream: widget.getStreamFromList,
                          getImgUrl: widget.getImgUrlFromList,
                          getTokenId: widget.getTokenIdFromList,
                        );
                      },
                    );
                  }
                );
              }
            ),
          );
        }
        else {
          return SizedBox(
            width: defaultWidth(context),
            height: defaultHeight(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat,
                  color: Constants.myTheme.text2Color,
                  size: defaultHeight(context)/10,
                ),
                SizedBox(height: defaultHeight(context)/50),
                Text('Tidak ada percakapan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.myTheme.text2Color,
                    fontSize: defaultHeight(context)/35,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: defaultHeight(context)/50),
                Text('Cari teman dan mulai mengobrol',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.myTheme.text2Color,
                    fontSize: defaultHeight(context)/60
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class ChatBubble extends StatefulWidget {
  final String message;
  final int dateTime;
  final bool isItMe;
  final bool isRead;
  final TickerProvider tickerProvider;
  ChatBubble({required this.message, required this.dateTime, required this.isItMe,
    required this.isRead, required this.tickerProvider
  });

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>{

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Container(
      margin: EdgeInsets.symmetric(vertical: defaultHeight(context)/300),
      padding: widget.isItMe ? EdgeInsets.only(left: defaultWidth(context)/8) : EdgeInsets.only(right: defaultWidth(context)/8),
      width: defaultWidth(context),
      alignment: widget.isItMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: widget.isItMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: (){
              Clipboard.setData(ClipboardData(text: widget.message));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.black,
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Pesan disalin', textAlign: TextAlign.center),
                      InkWell(
                        onTap: ()=> ScaffoldMessenger.of(context).clearSnackBars(),
                        child: Icon(
                          Icons.cancel,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  elevation: 0,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)
                  ),
                  width: defaultWidth(context)/2,
                  animation: CurvedAnimation(
                      parent: AnimationController(duration: const Duration(seconds: 1), vsync: widget.tickerProvider),
                      curve: Curves.linear
                  ),
                ),
              );
            },
            child: Container(
                decoration: BoxDecoration(
                    color: widget.isItMe ? Constants.myTheme.bubbleChat1 : Constants.myTheme.bubbleChat2,
                    borderRadius: widget.isItMe ?
                    BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)
                    ) :
                    BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)
                    )
                ),
                padding: EdgeInsets.symmetric(
                    vertical: defaultHeight(context)/100,
                    horizontal: defaultWidth(context)/(defaultHeight(context)>defaultWidth(context)?20:50)
                ),
                constraints: BoxConstraints(
                  maxWidth: defaultWidth(context)/1.5,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        widget.message,
                        //textAlign: widget.isItMe ? TextAlign.end : TextAlign.start,
                        style: TextStyle(
                          color: widget.isItMe? Constants.myTheme.text1Color : Constants.myTheme.text2Color,
                          fontSize: defaultHeight(context)/50),
                      ),
                    ),
                    SizedBox(width: defaultHeight(context)/100),
                    Text(
                      DateFormat('HH:mm').format(DateTime.fromMicrosecondsSinceEpoch(widget.dateTime)).toString(),
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: widget.isItMe ? Constants.myTheme.text1Color : Constants.myTheme.text2Color,
                        fontSize: defaultHeight(context)/90,
                      ),
                    ),
                    SizedBox(width: defaultHeight(context)/150),
                    Visibility(
                      visible: widget.isItMe,
                      child: Icon(
                        widget.isRead ? Icons.done_all : Icons.done,
                        size: defaultHeight(context)/60,
                        color: Constants.myTheme.text1Color,
                      ),
                    )
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }
}

class MessageList extends StatefulWidget {
  final Stream<QuerySnapshot> chatMessagesStream;
  final ScrollController scrollController;
  final String chatRoomId;
  MessageList({required this.chatMessagesStream, required this.scrollController, required this.chatRoomId});

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> with TickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: widget.chatMessagesStream,
        builder: (context, snapshot){
          if (snapshot.hasData) {
            return GroupedListView<QueryDocumentSnapshot, DateTime>(
              elements: snapshot.data!.docs,
              groupBy: (element) =>
                DateTime(
                  DateTime.fromMicrosecondsSinceEpoch(element['timestamp']).year,
                  DateTime.fromMicrosecondsSinceEpoch(element['timestamp']).month,
                  DateTime.fromMicrosecondsSinceEpoch(element['timestamp']).day,
                ),
              itemComparator: (item1, item2) => item1['timestamp'].compareTo(item2['timestamp']),
              order: GroupedListOrder.DESC,
              floatingHeader: true,
              groupSeparatorBuilder: (DateTime value) => Container(
                padding: EdgeInsets.symmetric(vertical: defaultHeight(context)/100),
                margin: EdgeInsets.symmetric(
                  vertical: defaultHeight(context)/60,
                  horizontal: Responsive.isDesktop(context) ? defaultWidth(context)/6  : defaultWidth(context)/3.5
                ),
                width: defaultWidth(context)/2.5,
                decoration: BoxDecoration(
                  color: Constants.myTheme.buttonColor.withOpacity(0.5),
                  borderRadius: BorderRadius.all(Radius.circular(50))
                ),
                child: Text(
                  FormattingMethod().separatorDateFormat(value),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: defaultHeight(context)/65, color: Constants.myTheme.text1Color),
                ),
              ),
              itemBuilder: (context, element) {
                return FutureBuilder(
                  future: UserMethod().updateReadMessage(
                      widget.chatRoomId.replaceAll("_", "").replaceAll(Constants.myId, ""),
                      widget.chatRoomId
                  ),
                  builder: (context, future){
                    return ChatBubble(
                      message: element['message'],
                      isItMe: element['sendBy'] == Constants.myId,
                      dateTime: element['timestamp'],
                      isRead: element['isRead'],
                      tickerProvider: this,
                    );
                  },
                );
              },
              shrinkWrap: true,
              controller: widget.scrollController,
              reverse: true,
            );
          }
          else {
            return Center(
              child: SpinKitSpinningLines(
                color: Constants.myTheme.text1Color,
                size: defaultHeight(context)/5,
              ),
            );
          }
        }
    );
  }
}

class UserTile extends StatefulWidget {
  final String userId;
  final String username;
  final String email;
  final String profileImg;
  final String tokenId;
  final SearchMethod searchMethod;
  final void Function(String)? getChatId;
  final void Function(String)? getImgUrl;
  final void Function(String)? getTokenId;
  final void Function(Stream<QuerySnapshot>)? getChatStream;

  UserTile({
    required this.userId, required this.username, required this.email, required this.profileImg,
    required this.tokenId, required this.searchMethod, this.getChatId, this.getImgUrl,
    this.getTokenId, this.getChatStream
  });

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> with TickerProviderStateMixin{

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  Widget selfChatAlert(){
    return AlertDialog(
      backgroundColor: Constants.myTheme.backgroundColor,
      buttonPadding: Responsive.isDesktop(context) ? EdgeInsets.all(defaultWidth(context)/50) : EdgeInsets.only(right: defaultWidth(context)/10),
      title: Text(
        'Peringatan',
        style: TextStyle(
          color: Constants.myTheme.text2Color
        ),
      ),
      content: Text(
        'Anda tidak bisa mengobrol dengan diri anda sendiri',
        style: TextStyle(
          color: Constants.myTheme.text2Color
        ),
      ),
      actions: [
        InkWell(
          child: Text(
            'Tutup',
            style: TextStyle(
              color: Constants.myTheme.buttonColor
            ),
          ),
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return ListTile(
      leading: Container(
        width: defaultHeight(context)/16,
        height: defaultHeight(context)/16,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          maxRadius: 50,
          minRadius: 40,
          child: ClipOval(
            child: widget.profileImg == "" ?
            Icon(
              Icons.account_circle,
              color: Constants.myTheme.buttonColor,
              size: defaultHeight(context)/16
            )
                :
            CachedNetworkImage(
              imageUrl: widget.profileImg,
              placeholder: (context, url) => Container(
                width: defaultHeight(context)/16,
                height: defaultHeight(context)/16,
                child: Icon(
                  Icons.account_circle,
                  color: Constants.myTheme.buttonColor,
                  size: defaultHeight(context)/16
                )
              ),
              fit: BoxFit.cover,
              width: defaultHeight(context)/16,
              height: defaultHeight(context)/16,
            ),
          ),
        ),
      ),
      title: Text(
        widget.username,
        style: TextStyle(
          color: Constants.myTheme.text2Color,
          fontSize: defaultHeight(context)/55
        )
      ),
      subtitle: Text(
        widget.email,
        style: TextStyle(
          color: Constants.myTheme.text2Color,
          fontSize: defaultHeight(context)/55
        )
      ),
      onTap: () async {
        if(Responsive.isMobile(context)){
          if(widget.userId == Constants.myId){
            showDialog(
              context: context,
              builder: (context){
                return selfChatAlert();
              }
            );
          }
          else{
            widget.searchMethod.StartChatting(
              userId: widget.userId,
              profileImg: widget.profileImg,
              context: context,
              tokenId: widget.tokenId,
              tickerProvider: this
            );
          }
        }
        else{
          if(widget.userId == Constants.myId){
            showDialog(
              context: context,
              builder: (context){
                return SizedBox(
                  height: defaultHeight(context)/20,
                  child: selfChatAlert()
                );
              }
            );
          }
          else{
            List<String> users = [widget.userId, Constants.myId];
            String chatroomid = SearchMethod().returnChatId(widget.userId, Constants.myId);
            Map<String, dynamic> chatRoomMap = {
              "users": users,
              "chatroomid": chatroomid
            };
            await UserMethod().createChatRoom(chatroomid, chatRoomMap);
            setState(() {
              widget.getChatId!(chatroomid);
              widget.getChatStream!(UserMethod().getChatMessages(chatroomid));
              widget.getImgUrl!(widget.profileImg);
              widget.getTokenId!(widget.tokenId);
            });
          }
        }
      },
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Container(
        width: defaultWidth(context),
        height: defaultHeight(context),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Constants.myTheme.primaryColor,
              Constants.myTheme.secondaryColor,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitSpinningLines(
                color: Constants.myTheme.text1Color,
                size: defaultHeight(context)/5,
              ),
              SizedBox(height: defaultHeight(context)/15),
              Text('Loading', style: TextStyle(
                color: Constants.myTheme.text1Color,
                fontSize: defaultHeight(context)/20
              )),
            ],
          )
        )
    );
  }
}

class HorizontalWaveClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size){
    var path = new Path();
    path.lineTo(0, size.height-10);
    var firstStart = Offset(size.width/5, size.height);
    var firstEnd = Offset(size.width/2.25, size.height-50);
    path.quadraticBezierTo(firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);

    var secondStart = Offset(size.width - (size.width/3.24), size.height-105);
    var secondEnd = Offset(size.width, size.height-10);
    path.quadraticBezierTo(secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class VerticalWaveClipper extends CustomClipper<Path>{
  @override
  Path getClip(Size size){
    var path = new Path();
    path.lineTo(size.width-20, 0);
    var firstStart = Offset(size.width/1.3, size.height/4);
    var firstEnd = Offset(size.width-50, size.height/1.8);
    path.quadraticBezierTo(firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);

    var secondStart = Offset(size.width+50, size.height/1.2);
    var secondEnd = Offset(size.width-70, size.height);
    path.quadraticBezierTo(secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}