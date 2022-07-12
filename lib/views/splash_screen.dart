import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:chatting_app/components/theme_data.dart';
import 'package:chatting_app/function/helper.dart';
import 'package:chatting_app/components/const.dart';
import 'package:chatting_app/views/main_screen.dart';
import 'package:chatting_app/views/sign_in.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLoggedIn = false;

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  getLoggedInState() async{
    await HelperFunction.getUserLoggedInSharedPreference().then((value){
      setState(() {
        isLoggedIn = value ?? false;
      });
      pushPage();
    });
  }

  pushPage(){
    if(isLoggedIn){
      Timer(Duration(seconds: 1), (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
      });
    }
    else {
      Timer(Duration(seconds: 1), (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
      });
    }
  }

  @override
  void initState() {
    getLoggedInState();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Scaffold(
        body: Container(
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/logo.svg',
                width: defaultHeight(context)/3,
                height: defaultHeight(context)/3,
              ),
              SizedBox(height: defaultHeight(context)/10),
              Text('Nocako',
                style: TextStyle(
                    color: Constants.myTheme.text1Color,
                    fontSize: defaultHeight(context)/13
                ),
              ),
              SizedBox(height: defaultHeight(context)/50),
              Text('Mengobrol tanpa berkata kasar',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Constants.myTheme.text1Color,
                    fontSize: defaultHeight(context)/55
                ),
              ),
            ],
          ),
        )
    );
  }
}

