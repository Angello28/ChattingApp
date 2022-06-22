import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatting_app/components/const.dart';
import 'package:chatting_app/components/theme_data.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({Key? key}) : super(key: key);

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  List<String> themeList = ["Normal", "Gelap", "Pastel", "Neon"];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: defaultHeight(context),
      width: defaultWidth(context),
      color: Constants.myTheme.backgroundColor,
      child: ListView.builder(
        itemCount: themeList.length,
        shrinkWrap: true,
        itemBuilder: (context, index){
          return ListTile(
            onTap: () async{
              setState((){
                ThemeGetterAndSetter.setThemeSharedPreferences(themeList[index]);
              });
              Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
              Constants.myTheme = getTheme(Constants.myThemeName);
            },
            trailing: Radio(
              value: themeList[index],
              groupValue: Constants.myThemeName == "" ? 'Normal' : Constants.myThemeName,
              onChanged: (val) async{
                setState((){
                  ThemeGetterAndSetter.setThemeSharedPreferences(themeList[index]);
                });
                Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
                Constants.myTheme = getTheme(Constants.myThemeName);
              },
              activeColor: Constants.myTheme.buttonColor,
            ),
            title: Text(themeList[index],
              style: TextStyle(
                color: Constants.myTheme.text2Color
              ),
            ),
          );
        }
      ),
    );
  }
}


// ignore: must_be_immutable
class ThemeSetting extends StatefulWidget {
  @override
  _ThemeSettingState createState() => _ThemeSettingState();
}

class _ThemeSettingState extends State<ThemeSetting> {
  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tema',
          style: TextStyle(
            color: Constants.myTheme.text1Color
          )),
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      body: ThemeScreen(),
    );
  }
}