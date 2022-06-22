import 'package:flutter/material.dart';
import 'package:chatting_app/components/theme_data.dart';

String regexSource = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
const charId = 'ABCDEF0123456789';

double defaultWidth(BuildContext context){
  return MediaQuery.of(context).size.width;
}

double defaultHeight(BuildContext context){
  return MediaQuery.of(context).size.height;
}

class Constants{
  static String myId = "";
  static String myName = "";
  static String myEmail = "";
  static String myProfileImage = "";
  static String myThemeName = "";
  static ColorTheme myTheme = getTheme('Default');
  static bool isInChatRoom = false;
  static String myOneSignalId = '3b2330e0-1ddf-44d8-8f49-006e17673cb3';
}