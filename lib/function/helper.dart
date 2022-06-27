import 'package:shared_preferences/shared_preferences.dart';

class HelperFunction{
  static String sharedPreferenceUserIdKey = "USERIDKEY";
  static String sharedPreferenceUserLogInKey = "ISLOGGEDIN";
  static String sharedPreferenceUserNameKey = "USERNAMEKEY";
  static String sharedPreferenceUserEmailKey = "USEREMAILKEY";
  static String sharedPreferenceUserProfileImageKey = "USERPROFILEIMAGEKEY";
  static String sharedPreferenceUserIsInChatRoomKey = "ISINCHATROOM";
  static String sharedPreferenceProfanitySettingKey = "USERPROFANITYKEY";

  static Future<bool> saveUserIdSharedPreference(String userId) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserIdKey, userId);
  }

  static Future<bool> saveUserLoggedInSharedPreference(bool isUserLoggedIn) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(sharedPreferenceUserLogInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserNameSharedPreference(String userName) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserNameKey, userName);
  }

  static Future<bool> saveUserEmailSharedPreference(String userEmail) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserEmailKey, userEmail);
  }

  static Future<bool> saveUserProfileImageSharedPreference(String userProfileImgUrl) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceUserProfileImageKey, userProfileImgUrl);
  }

  static Future<bool> saveIsInChatRoomSharedPreference(bool isInChatRoom) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(sharedPreferenceUserIsInChatRoomKey, isInChatRoom);
  }

  static Future<bool> saveProfanitySettingSharedPreference(String profanitySetting) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(sharedPreferenceProfanitySettingKey, profanitySetting);
  }

  static Future<String?> getUserIdSharedPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceUserIdKey);
  }

  static Future<bool?> getUserLoggedInSharedPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(sharedPreferenceUserLogInKey);
  }

  static Future<String?> getUserNameSharedPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceUserNameKey);
  }

  static Future<String?> getUserEmailSharedPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceUserEmailKey);
  }

  static Future<String?> getUserProfileImageSharedPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceUserProfileImageKey);
  }

  static Future<bool?> getIsInChatRoomSharedPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(sharedPreferenceUserIsInChatRoomKey);
  }

  static Future<String?> getProfanitySettingSharedPreference() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(sharedPreferenceProfanitySettingKey);
  }
}