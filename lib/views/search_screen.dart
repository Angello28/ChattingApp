import 'package:chatting_app/components/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chatting_app/components/components.dart';
import 'package:chatting_app/components/theme_data.dart';
import 'package:chatting_app/components/const.dart';
import 'package:chatting_app/function/helper.dart';
import 'package:chatting_app/function/method.dart';

class SearchScreen extends StatefulWidget {
  ValueChanged<String>? getId;
  ValueChanged<String>? getImgUrl;
  ValueChanged<String>? getTokenId;
  ValueChanged<Stream<QuerySnapshot>>? getMessagesStream;
  SearchScreen({Key? key, this.getId, this.getImgUrl, this.getTokenId, this.getMessagesStream}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  var queryResultSet = [];
  var tempSearchStore =[];

  UserMethod userMethod = new UserMethod();
  SearchMethod searchMethod = new SearchMethod();

  Searching(String value){
    if(value.length == 0){
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var keyword = value.substring(0,1) + value.substring(1);

    if(queryResultSet.length == 0 && value.length == 1){
      userMethod.getUserByUsername(value).then((QuerySnapshot snapshot){
        for (var message in snapshot.docs) {
          setState(() {
            queryResultSet.add(message.data());
          });
        }
      });
    }
    else{
      tempSearchStore =[];
      queryResultSet.forEach((element) {
        if(element['name'].startsWith(keyword)){
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Constants.myTheme.backgroundColor,
      padding: EdgeInsets.symmetric(
        vertical: Responsive.isMobile(context) ? defaultHeight(context)/50 : defaultHeight(context)/40,
        horizontal: Responsive.isMobile(context) ? defaultWidth(context)/25 : defaultWidth(context)/80
      ),
      child: Column(
        children: [
          Container(
            child: TextField(
              style: TextStyle(color: Constants.myTheme.text2Color),
              onChanged: (val){
                Searching(val);
              },
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Constants.myTheme.borderColor)
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Constants.myTheme.buttonColor)
                ),
                hintText: 'Cari nama pengguna', hintStyle: TextStyle(color: Constants.myTheme.text2Color)
              ),
              enabled: true,
            ),
          ),
          SizedBox(height: defaultHeight(context)/30),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    tempSearchStore.length == 0 && queryResultSet.length == 0 ?
                    Container(
                        height: defaultHeight(context)/1.5,
                        child: Center(
                          child: Text('Cari teman untuk memulai percakapan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Constants.myTheme.text2Color
                            )
                          )
                        )
                    )
                        :
                    tempSearchStore.length == 0 && queryResultSet.length != 0 ?
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: queryResultSet.length,
                        itemBuilder: (context, index){
                          if(Responsive.isMobile(context)){
                            return UserTile(
                              userId: queryResultSet[index]['id'],
                              username: queryResultSet[index]['name'],
                              email: queryResultSet[index]['email'],
                              profileImg: queryResultSet[index]['profileImg'],
                              tokenId: queryResultSet[index]['tokenId'],
                              searchMethod: searchMethod
                            );
                          }
                          else{
                            return UserTile(
                              userId: queryResultSet[index]['id'],
                              username: queryResultSet[index]['name'],
                              email: queryResultSet[index]['email'],
                              profileImg: queryResultSet[index]['profileImg'],
                              tokenId: queryResultSet[index]['tokenId'],
                              searchMethod: searchMethod,
                              getChatId: (id){
                                setState(() {
                                  widget.getId!(id);
                                });
                              },
                              getChatStream: (stream){
                                setState(() {
                                  widget.getMessagesStream!(stream);
                                });
                              },
                              getImgUrl: (url){
                                setState(() {
                                  widget.getImgUrl!(url);
                                });
                              },
                              getTokenId: (token){
                                setState(() {
                                  widget.getTokenId!(token);
                                });
                              },
                            );
                          }
                        }
                      ),
                    )
                        :
                    Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: tempSearchStore.length,
                        itemBuilder: (context, index){
                          if(Responsive.isMobile(context)){
                            return UserTile(
                              userId: tempSearchStore[index]['id'],
                              username: tempSearchStore[index]['name'],
                              email: tempSearchStore[index]['email'],
                              profileImg: tempSearchStore[index]['profileImg'],
                              tokenId: tempSearchStore[index]['tokenId'],
                              searchMethod: searchMethod
                            );
                          }
                          else{
                            return UserTile(
                              userId: tempSearchStore[index]['id'],
                              username: tempSearchStore[index]['name'],
                              email: tempSearchStore[index]['email'],
                              profileImg: tempSearchStore[index]['profileImg'],
                              tokenId: tempSearchStore[index]['tokenId'],
                              searchMethod: searchMethod,
                              getChatId: (id){
                                setState(() {
                                  widget.getId!(id);
                                });
                              },
                              getChatStream: (stream){
                                setState(() {
                                  widget.getMessagesStream!(stream);
                                });
                              },
                              getImgUrl: (url){
                                setState(() {
                                  widget.getImgUrl!(url);
                                });
                              },
                              getTokenId: (token){
                                setState(() {
                                  widget.getTokenId!(token);
                                });
                              },
                            );
                          }
                        }
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>{

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async{
    Constants.myName = (await HelperFunction.getUserNameSharedPreference())!;
  }

  @override
  Widget build(BuildContext context) {
    getThemeFromPreferences();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
        title: Text('Cari', style: TextStyle(color: Constants.myTheme.text1Color)),
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      body: SearchScreen(),
    );
  }
}