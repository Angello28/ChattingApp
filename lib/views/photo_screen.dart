import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:chatting_app/components/const.dart';
import 'package:chatting_app/components/theme_data.dart';

class PhotoScreen extends StatefulWidget {
  final String title;
  final String imageUrl;
  PhotoScreen({required this.title, required this.imageUrl});

  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {

  getThemeFromPreferences() async{
    Constants.myThemeName = (await ThemeGetterAndSetter.getThemeSharedPreferences())!;
    Constants.myTheme = getTheme(Constants.myThemeName);
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
              color: Constants.myTheme.text1Color
          ),
        ),
        backgroundColor: Constants.myTheme.primaryColor,
        iconTheme: IconThemeData(color: Constants.myTheme.text1Color),
      ),
      body: Container(
        width: defaultWidth(context),
        height: defaultHeight(context),
        //padding: EdgeInsets.symmetric(vertical: defaultWidth(context)/2),
        color: Constants.myTheme.backgroundColor,
        child: InteractiveViewer(
          minScale: 0.1,
          maxScale: 2.0,
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
              CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Constants.myTheme.buttonColor,
                value: downloadProgress.progress,
              ),
          ),
        ),
      ),
    );
  }
}