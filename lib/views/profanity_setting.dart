import 'package:chatting_app/components/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatting_app/components/const.dart';
import 'package:chatting_app/components/theme_data.dart';

class ProfanitySettingScreen extends StatefulWidget {
  const ProfanitySettingScreen({Key? key}) : super(key: key);

  @override
  State<ProfanitySettingScreen> createState() => _ProfanitySettingScreenState();
}

class _ProfanitySettingScreenState extends State<ProfanitySettingScreen> {
  List<List<String>> profanitySettingList = [
    ["Pencegahan", "Pesan yang mengandung kata kasar akan dicegah untuk dikirim"],
    ["Sensor", "Kata kasar akan disensor saat ditampilkan di bagian obrolan"]
  ];

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: defaultHeight(context),
      width: defaultWidth(context),
      color: Constants.myTheme.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: defaultHeight(context)/60,
              horizontal: Responsive.isDesktop(context) ? defaultWidth(context)/100 : defaultWidth(context)/30),
            child: Text(
              "Pengaturan kata kasar pada pesan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Constants.myTheme.text2Color
              ),
            ),
          ),
          ListView.builder(
              itemCount: profanitySettingList.length,
              shrinkWrap: true,
              itemBuilder: (context, index){
                return ListTile(
                  onTap: () async{
                    setState((){
                      _index = index;
                      print(_index);
                    });
                  },
                  trailing: Radio(
                    value: profanitySettingList[index][0],
                    groupValue: profanitySettingList[_index][0],
                    onChanged: (val) async{
                      setState((){
                        _index = index;
                        print(_index);
                      });
                    },
                    activeColor: Constants.myTheme.buttonColor,
                  ),
                  title: Text(profanitySettingList[index][0],
                    style: TextStyle(
                      color: Constants.myTheme.text2Color,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  subtitle: Text(profanitySettingList[index][1],
                    style: TextStyle(
                      color: Constants.myTheme.text2Color
                    ),
                  ),
                );
              }
          ),
        ],
      ),
    );
  }
}


class ProfanitySetting extends StatefulWidget {
  const ProfanitySetting({Key? key}) : super(key: key);

  @override
  State<ProfanitySetting> createState() => _ProfanitySettingState();
}

class _ProfanitySettingState extends State<ProfanitySetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: TextStyle(
              color: Constants.myTheme.text1Color
          )),
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      body: ProfanitySettingScreen(),
    );
  }
}
