import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chatting_app/components/components.dart';
import 'package:chatting_app/components/theme_data.dart';
import 'package:chatting_app/components/const.dart';
import 'package:chatting_app/components/responsive.dart';
import 'package:chatting_app/function/auth.dart';
import 'package:chatting_app/function/helper.dart';
import 'package:chatting_app/function/method.dart';
import 'package:chatting_app/views/sign_up.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'main_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin{
  bool isLoading = false;

  Authentication authentication = new Authentication();
  UserMethod userMethod = new UserMethod();

  final formKey = GlobalKey<FormState>();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  signInValidator() async{
    if(formKey.currentState!.validate()){
      setState(() {
        isLoading = true;
      });
      await authentication.signInWithEmailAndPassword(emailTextController.text, passwordTextController.text).then((value) async{
        if(value!=null){
          String? tokenId = "";
          if(!kIsWeb){
            var status = await OneSignal.shared.getDeviceState();
            tokenId = status!.userId;
          }

          QuerySnapshot userInfo = await userMethod.getUserByUserEmail(emailTextController.text);
          await userMethod.updateToken(userInfo.docs[0]['id'], tokenId!);
          HelperFunction.saveUserIdSharedPreference(userInfo.docs[0]['id']);
          HelperFunction.saveUserLoggedInSharedPreference(true);
          HelperFunction.saveUserNameSharedPreference(userInfo.docs[0]['name']);
          HelperFunction.saveUserEmailSharedPreference(emailTextController.text);
          HelperFunction.saveUserProfileImageSharedPreference(userInfo.docs[0]['profileImg']);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));

          print("Token Id: $tokenId");
        }
        else{
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text('Pengguna tidak ditemukan', textAlign: TextAlign.center),
                    InkWell(
                      onTap: ()=> ScaffoldMessenger.of(context).clearSnackBars(),
                      child: const Icon(
                        Icons.cancel,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)
                ),
                width: defaultWidth(context)/2,
                animation: CurvedAnimation(
                  parent: AnimationController(duration: const Duration(seconds: 1), vsync: this),
                  curve: Curves.linear
                ),
              ),
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Scaffold(
      body: isLoading ?
      LoadingScreen()
          :
      Responsive(
        mobile: Container(
          width: defaultWidth(context),
          height: defaultHeight(context),
          color: Constants.myTheme.backgroundColor,
          child: SingleChildScrollView(
            child: Container(
              width: defaultWidth(context),
              height: defaultHeight(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipPath(
                    clipper: HorizontalWaveClipper(),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: defaultHeight(context)/50),
                      height: defaultHeight(context)/2,
                      width: defaultWidth(context),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(Constants.myTheme.signWallpaper),
                          fit: BoxFit.cover
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Selamat datang,', style: TextStyle(
                            color: Constants.myTheme.text1Color,
                            fontSize: defaultHeight(context)/25
                          )),
                          Text('Masuk', style: TextStyle(
                            color: Constants.myTheme.text1Color,
                            fontSize: defaultHeight(context)/13
                          )),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: defaultHeight(context)/50),
                    child: Column(
                      children: [
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                                validator: (val){
                                  return RegExp(regexSource).hasMatch(val!) ? null : "Email tidak valid";
                                },
                                controller: emailTextController,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.borderColor)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                                  ),
                                  hintText: 'Email', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
                                ),
                              ),
                              TextFormField(
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                                validator: (val){
                                  return val!.isEmpty || val.length<6 ? "Kata sandi terlalu pendek (minimal 6 karakter)" : null;
                                },
                                controller: passwordTextController,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.borderColor)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                                  ),
                                  hintText: 'Kata Sandi', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
                                ),
                                obscureText: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        ElevatedButton(
                          onPressed: () => signInValidator(),
                          style: ElevatedButton.styleFrom(
                            primary: Constants.myTheme.buttonColor,
                            textStyle: TextStyle(fontSize: defaultHeight(context)/40),
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0),),
                            minimumSize: Size(
                              defaultWidth(context)>=650 && defaultWidth(context)<1024 ?
                              defaultWidth(context)/3 : defaultWidth(context)/2.5,
                              defaultHeight(context)/15
                            ),
                          ),
                          child: Text('Masuk', style: TextStyle(color: Constants.myTheme.text1Color))
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Belum punya akun?', style: TextStyle(color: Constants.myTheme.text2Color)),
                            InkWell(
                              onTap: (){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUp()));
                              },
                              child: Text(' Daftar sekarang',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Constants.myTheme.buttonColor
                                ),
                              )
                            ),
                          ],
                        ),
                        SizedBox(height: defaultHeight(context)/10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        desktop: Container(
          width: defaultWidth(context),
          height: defaultHeight(context),
          color: Constants.myTheme.backgroundColor,
          child: Row(
            children: [
              ClipPath(
                clipper: VerticalWaveClipper(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: defaultHeight(context)/50),
                  height: defaultHeight(context),
                  width: defaultWidth(context)/2,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(Constants.myTheme.signWallpaper),
                      fit: BoxFit.cover
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/logo.svg',
                        width: defaultHeight(context)/3,
                        height: defaultHeight(context)/3,
                      ),
                      SizedBox(height: defaultHeight(context)/20),
                      Text('Nocako', style: TextStyle(
                        color: Constants.myTheme.text1Color,
                        fontSize: defaultHeight(context)/15
                      )),
                      Text('Chat App', style: TextStyle(
                        color: Constants.myTheme.text1Color,
                        fontSize: defaultHeight(context)/20
                      )),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: defaultHeight(context)/10),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Selamat datang,', style: TextStyle(
                          color: Constants.myTheme.text2Color,
                          fontSize: defaultHeight(context)/15
                        )),
                        Text('Masuk', style: TextStyle(
                          color: Constants.myTheme.text2Color,
                          fontSize: defaultHeight(context)/10
                        )),
                        SizedBox(height: defaultHeight(context)/3.5),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                                validator: (val){
                                  return RegExp(regexSource).hasMatch(val!) ? null : "Email tidak valid";
                                },
                                controller: emailTextController,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.borderColor)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                                  ),
                                  hintText: 'Email', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
                                ),
                              ),
                              TextFormField(
                                style: TextStyle(
                                  color: Constants.myTheme.text2Color
                                ),
                                validator: (val){
                                  return val!.isEmpty || val.length<6 ? "Kata sandi terlalu pendek (minimal 6 karakter)" : null;
                                },
                                controller: passwordTextController,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.borderColor)
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                                  ),
                                  hintText: 'Kata Sandi', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
                                ),
                                obscureText: true,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        ElevatedButton(
                          onPressed: () => signInValidator(),
                          style: ElevatedButton.styleFrom(
                            primary: Constants.myTheme.buttonColor,
                            textStyle: TextStyle(fontSize: defaultHeight(context)/40),
                            shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0),),
                            fixedSize: Size(defaultWidth(context)/6, defaultHeight(context)/15),
                          ),
                          child: Text('Masuk', style: TextStyle(color: Constants.myTheme.text1Color))
                        ),
                        SizedBox(height: defaultHeight(context)/30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Belum punya akun?', style: TextStyle(color: Constants.myTheme.text2Color)),
                            InkWell(
                              onTap: (){
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUp()));
                              },
                              child: Text(' Daftar Sekarang',
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Constants.myTheme.buttonColor
                                ),
                              )
                            ),
                          ],
                        ),
                        SizedBox(height: defaultHeight(context)/10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}