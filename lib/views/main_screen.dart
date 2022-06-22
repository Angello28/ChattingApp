import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatting_app/components/const.dart';
import 'package:chatting_app/components/responsive.dart';
import 'package:chatting_app/components/theme_data.dart';
import 'package:chatting_app/components/components.dart';
import 'package:chatting_app/function/auth.dart';
import 'package:chatting_app/function/helper.dart';
import 'package:chatting_app/function/method.dart';
import 'package:chatting_app/views/profile_screen.dart';
import 'package:chatting_app/views/chat_screen.dart';
import 'package:chatting_app/views/nav_drawer.dart';
import 'package:chatting_app/views/search_screen.dart';
import 'package:chatting_app/views/theme_setting.dart';
import 'package:chatting_app/views/profanity_setting.dart';
import 'package:chatting_app/views/sign_in.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver{

  String getId = '';
  String getImgUrl = '';
  String getTokenId = '';
  Stream<QuerySnapshot> getMessagesStream = Stream.empty();

  Authentication authentication = new Authentication();
  Stream<QuerySnapshot> chatRoomStream = Stream.empty();

  bool isDrawer = true;
  bool isSearchScreen = false;
  bool isThemeScreen = false;
  bool isProfileScreen = false;
  bool isProfanityScreen = false;

  getUserInfo() async{
    Constants.myId = (await HelperFunction.getUserIdSharedPreference())!;
    Constants.myName = (await HelperFunction.getUserNameSharedPreference())!;
    Constants.myEmail = (await HelperFunction.getUserEmailSharedPreference())!;
    Constants.myProfileImage = (await HelperFunction.getUserProfileImageSharedPreference())!;
    chatRoomStream = await UserMethod().getChatRooms(Constants.myId);
    setState(() {});
  }

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  getProfileImage() async{
    Constants.myProfileImage = (await HelperFunction.getUserProfileImageSharedPreference())!;
    setState(() {});
  }

  Widget sideChatScreen(){
    if(getId == ''){
      return Container(
        color: Constants.myTheme.backgroundColor,
        height: defaultHeight(context),
        child: SizedBox(
          width: defaultWidth(context),
          height: defaultHeight(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: Text('Tidak ada obrolan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.myTheme.text2Color,
                    fontSize: defaultHeight(context)/35,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              SizedBox(height: defaultHeight(context)/50),
              Material(
                color: Colors.transparent,
                child: Text('Obrolan kamu dengan orang lain akan ditampilkan disini',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.myTheme.text2Color,
                    fontSize: defaultHeight(context)/60
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    else{
      return ChatScreen(
        chatRoomId: getId,
        chatRoomStream: getMessagesStream,
        chatProfileImgUrl: getImgUrl,
        tokenId: getTokenId,
      );
    }
  }

  Widget mainListChat(){
    return Stack(
      children: [
        Container(
          width: defaultWidth(context),
          height: defaultHeight(context),
          color: Constants.myTheme.backgroundColor,
        ),
        ChatRoomList(
          chatRoomStream: chatRoomStream,
          getChatIdFromList: (id){
            setState(() {
              getId = id;
            });
          },
          getStreamFromList: (stream){
            setState(() {
              getMessagesStream = stream;
            });
          },
          getImgUrlFromList: (url){
            setState(() {
              getImgUrl = url;
            });
          },
          getTokenIdFromList: (token){
            setState(() {
              getTokenId = token;
            });
          },
        )
      ]
    );
  }

  @override
  void initState() {
    getUserInfo();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ignore: non_constant_identifier_names
  Widget SearchScreenWeb(){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Visibility(
                visible: Responsive.isDesktop(context),
                child: InkWell(
                  onTap: (){
                    setState(() {
                      isDrawer = true;
                      isSearchScreen = false;
                    });
                  },
                  child: Icon(
                    Icons.close,
                  ),
                ),
              ),
              SizedBox(width: Responsive.isDesktop(context) ? defaultWidth(context)/80 : 0),
              Text('Cari', style: TextStyle(color: Constants.myTheme.text1Color)),
            ]
        ),
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      body: SearchScreen(
        getId: (id){
          getId = id;
        },
        getImgUrl: (url){
          getImgUrl = url;
        },
        getTokenId: (token){
          getTokenId = token;
        },
        getMessagesStream: (stream){
          getMessagesStream = stream;
        },
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget ProfileScreenWeb(){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Visibility(
              visible: Responsive.isDesktop(context),
              child: InkWell(
                onTap: (){
                  setState(() {
                    isDrawer = true;
                    isProfileScreen = false;
                  });
                },
                child: Icon(
                  Icons.close,
                ),
              ),
            ),
            SizedBox(width: Responsive.isDesktop(context) ? defaultWidth(context)/80 : 0),
            Text('Profil', style: TextStyle(
                color: Constants.myTheme.text1Color
            )),
          ],
        ),
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      body: ProfileScreen()
    );
  }

  // ignore: non_constant_identifier_names
  Widget ThemeSettingWeb(){
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Visibility(
              visible: Responsive.isDesktop(context),
              child: InkWell(
                onTap: (){
                  setState(() {
                    isDrawer = true;
                    isThemeScreen = false;
                  });
                },
                child: Icon(
                  Icons.close,
                ),
              ),
            ),
            SizedBox(width: Responsive.isDesktop(context) ? defaultWidth(context)/80 : 0),
            Text(
                'Tema',
                style: TextStyle(
                    color: Constants.myTheme.text1Color
                )
            ),
          ],
        ),
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      body: ThemeScreen(),
    );
  }

  // ignore: non_constant_identifier_names
  Widget ProfanitySettingWeb(){
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Visibility(
              visible: Responsive.isDesktop(context),
              child: InkWell(
                onTap: (){
                  setState(() {
                    isDrawer = true;
                    isProfanityScreen = false;
                  });
                },
                child: Icon(
                  Icons.close,
                ),
              ),
            ),
            SizedBox(width: Responsive.isDesktop(context) ? defaultWidth(context)/80 : 0),
            Text(
              'Pengaturan',
              style: TextStyle(
                color: Constants.myTheme.text1Color
              )
            ),
          ],
        ),
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      body: ProfanitySettingScreen(),
    );
  }

  // ignore: non_constant_identifier_names
  Widget NavDrawerWeb(){
    return Container(
      padding: EdgeInsets.only(left: defaultHeight(context) / 70, right: defaultHeight(context) / 70),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Constants.myTheme.secondaryColor,
            Constants.myTheme.primaryColor,
          ],
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: defaultHeight(context)/50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: defaultHeight(context)/40),
                Container(
                  width: defaultHeight(context)/10,
                  height: defaultHeight(context)/10,
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: Constants.myProfileImage == "" ?
                      Icon(
                        Icons.account_circle,
                        color: Constants.myTheme.buttonColor == Constants.myTheme.primaryColor ?
                        Colors.white : Constants.myTheme.buttonColor,
                        size: defaultHeight(context)/10
                      )
                          :
                      CachedNetworkImage(
                        imageUrl: Constants.myProfileImage,
                        placeholder: (context, url) => Icon(
                          Icons.account_circle,
                          color: Constants.myTheme.buttonColor == Constants.myTheme.primaryColor ?
                          Colors.white : Constants.myTheme.buttonColor,
                          size: defaultHeight(context)/10
                        ),
                        fit: BoxFit.cover,
                        width: defaultHeight(context)/10,
                        height: defaultHeight(context)/10,
                      ),
                    )
                  ),
                ),
                SizedBox(height: defaultHeight(context)/45),
                Row(
                  children: [
                    SizedBox(width: defaultWidth(context)/300),
                    Material(
                      color: Colors.transparent,
                      child: Text(
                        Constants.myName,
                        style: TextStyle(
                          color: Constants.myTheme.text1Color,
                          fontSize: defaultHeight(context) / 50
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(width: defaultWidth(context)/300),
                    Material(
                      color: Colors.transparent,
                      child: Text(Constants.myEmail,
                        style: TextStyle(
                          color: Constants.myTheme.text1Color,
                          fontSize: defaultHeight(context) / 50
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
          ),
          SizedBox(
            height: defaultHeight(context) / 20,
          ),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(Icons.search, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 30),
              title: Text(
                'Cari Teman',
                style: TextStyle(
                  color: Constants.myTheme.text1Color,
                  fontSize: defaultHeight(context) / 50
                ),
              ),
              onTap: (){
                setState(() {
                  isSearchScreen = true;
                  isDrawer = false;
                });
              },
            ),
          ),
          SizedBox(
            height: defaultHeight(context) / 80,
          ),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(Icons.account_circle, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 30),
              title: Text(
                'Profil',
                style: TextStyle(
                  color: Constants.myTheme.text1Color,
                  fontSize: defaultHeight(context) / 50
                ),
              ),
              onTap: (){
                setState(() {
                  isProfileScreen = true;
                  isDrawer = false;
                });
              },
            ),
          ),
          SizedBox(
            height: defaultHeight(context) / 80,
          ),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(Icons.palette, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 30),
              title: Text('Tema',
                style: TextStyle(
                  color: Constants.myTheme.text1Color,
                  fontSize: defaultHeight(context) / 50
                ),
              ),
              onTap: (){
                setState(() {
                  isThemeScreen = true;
                  isDrawer = false;
                });
              },
            ),
          ),
          SizedBox(
            height: defaultHeight(context) / 80,
          ),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: Icon(Icons.settings, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 30),
              title: Text('Pengaturan',
                style: TextStyle(
                  color: Constants.myTheme.text1Color,
                  fontSize: defaultHeight(context) / 50
                ),
              ),
              onTap: (){
                setState(() {
                  isProfanityScreen = true;
                  isDrawer = false;
                });
              },
            ),
          ),
          SizedBox(
            height: defaultHeight(context) / 80,
          ),
          Material(
            color: Colors.transparent,
            child: ListTile(
                leading: Icon(Icons.exit_to_app, color: Constants.myTheme.text1Color, size:defaultHeight(context) / 30),
                title: Text('Keluar',
                  style: TextStyle(
                    color: Constants.myTheme.text1Color,
                    fontSize: defaultHeight(context) / 50
                  ),
                ),
                onTap: () async{
                  authentication.signOut();
                  await UserMethod().updateToken(Constants.myId, '');
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                }
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getProfileImage();
    getThemeFromPreferences();
    return Responsive(
      mobile: Scaffold(
        drawer: NavDrawer(),
        onDrawerChanged: (bool isOpened)=>{
          getThemeFromPreferences()
        },
        appBar: AppBar(
          title: Text('Nocako', style: TextStyle(
            color: Constants.myTheme.text1Color
          )),
          backgroundColor: Constants.myTheme.primaryColor,
          iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
          systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
          actions: [
            InkWell(
              onTap: () async{
                chatRoomStream = await UserMethod().getChatRooms(Constants.myId);
              },
              child: Icon(Icons.autorenew)
            ),
            SizedBox(
              width: defaultWidth(context)/55,
            )
          ],
        ),
        body: mainListChat(),
        floatingActionButton: Container(
          margin: EdgeInsets.only(right: defaultWidth(context)/30, bottom: defaultHeight(context)/60),
          width: defaultWidth(context)/5,
          height: defaultHeight(context)/11,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Search()));
            },
            child: Icon(Icons.chat, size: defaultHeight(context)/25, color: Constants.myTheme.text1Color),
            backgroundColor: Constants.myTheme.buttonColor,
          ),
        ),
      ),
      desktop: Row(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                Visibility(
                  visible: isSearchScreen,
                  child: SearchScreenWeb(),
                ),
                Visibility(
                  visible: isProfileScreen,
                  child: ProfileScreenWeb(),
                ),
                Visibility(
                  visible: isThemeScreen,
                  child: ThemeSettingWeb(),
                ),
                Visibility(
                  visible: isProfanityScreen,
                  child: ProfanitySettingWeb(),
                ),
                Visibility(
                  visible: isDrawer,
                  child: NavDrawerWeb(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Nocako', style: TextStyle(
                  color: Constants.myTheme.text1Color
                )),
                actions: [
                  InkWell(
                    onTap: () async{
                      chatRoomStream = await UserMethod().getChatRooms(Constants.myId);
                    },
                    child: Icon(Icons.autorenew)
                  ),
                  SizedBox(
                    width: defaultWidth(context)/55,
                  )
                ],
                backgroundColor: Constants.myTheme.primaryColor,
              ),
              body: mainListChat(),
            ),
          ),
          Expanded(
            flex: 5,
            child: sideChatScreen()
          ),
        ],
      )
    );
  }
}
