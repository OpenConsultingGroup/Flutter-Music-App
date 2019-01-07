import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/music/song.dart';
import "package:http/http.dart" as http;
import 'package:soundwave/database.dart';
import 'dart:ui' show ImageFilter;


class CreatePlaylistScreen extends StatefulWidget {
  CreatePlaylistScreen({Key key, this.title, this.song}) : super(key: key);
  final String title;
  final Song song;
  @override
  _CreatePlaylistScreenState createState() => new _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> with TickerProviderStateMixin{

  String title;
  DatabaseInterface databaseInterface;
  TextEditingController controller;
  final GlobalKey<ScaffoldState> key=GlobalKey();
  _CreatePlaylistScreenState(){
    databaseInterface=DatabaseInterface();
    databaseInterface.open();
    controller=TextEditingController();
  }
  @override
  void initState() {
    super.initState();
    title="Collections";
   }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      body: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(gradient: LinearGradient(
            colors: [Color(0xffEB5757),Color(0xff000000)],
            begin: Alignment.topCenter,
          end: Alignment.bottomRight
        )),
        child: createPlaylist(),
      ),
    );
  }
  String defaultThumbnail="https://sheet.host/assets/img/score-placeholder.png";
  Widget createPlaylist()
  {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Give your playlist a name",style: Theme.of(context).textTheme.headline,),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical:12.0,horizontal: 8.0),
          child: TextField(
              controller: controller,
            decoration: InputDecoration(
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white,width: 1.0,style: BorderStyle.solid))
            ),
            style: TextStyle(color: Theme.of(context).textTheme.title.color,fontWeight: FontWeight.bold,fontSize: 28.0,),
            textAlign: TextAlign.center,
            cursorColor: Colors.white,
          ),
        ),
        ButtonBar(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CupertinoButton(
              color: Colors.transparent,
              child: Text("Cancel",style: Theme.of(context).textTheme.subhead,),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            CupertinoButton(
              color: Colors.transparent,
              child: Text("Ok",style: Theme.of(context).textTheme.subhead.copyWith(color: Colors.green),),
              onPressed: (){
                if(controller.text.length>0)
                  {
                        databaseInterface.createPlaylist("").then(
                              (snapshot){
                                 Navigator.pop(context);
                              });
                      if(widget.song!=null)
                        {
                          databaseInterface.addToPlaylist([widget.song],controller.text);
                        }

                  }
              },
            )
          ],
        )
      ],
      ),
    );
  }
}