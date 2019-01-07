import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:async/async.dart' ;
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundwave/credits_screen.dart';
import 'package:soundwave/database.dart';
import 'package:soundwave/main.dart';


class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _SettingsScreenState createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool darkTheme=true;
  ScrollController scrollController;

  SharedPreferences prefs;
  void initState()
  {
   super.initState();
   initialiseSharedPrefrences();
  }
  @override
  Widget build(BuildContext context) {
    /*SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white
    ));*/
    List<Widget>items=[];
    scrollController=ScrollController();
    return new Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body:CustomScrollView(
        slivers: <Widget>[
          createAppbar(),
          SliverList(delegate: SliverChildBuilderDelegate((context,index){
            return createTopics();
          },childCount: 1),)
        ],
      )
    );
  }
  void initialiseSharedPrefrences() async
  {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      darkTheme=prefs.getBool("darkTheme") ?? true;
    });
  }
  CupertinoSliverNavigationBar createAppbar()
  {
    return CupertinoSliverNavigationBar(
        leading: CupertinoButton(
          child: Icon(CupertinoIcons.left_chevron,color:  Theme.of(context).iconTheme.color,size: 28.0,),
          minSize: 0.0,
          padding: EdgeInsets.zero,
          onPressed: (){
            Navigator.of(context).maybePop();
          },),
        largeTitle: Text("Settings",style: TextStyle(color: Theme.of(context).textTheme.title.color),textAlign: TextAlign.center,),
         heroTag: DateTime.now().toString(),
        backgroundColor: Colors.transparent,
        trailing: CupertinoButton(
            minSize: 0.0,
            child: Icon(Icons.more_horiz,color:  Theme.of(context).iconTheme.color,),
            padding: EdgeInsets.all(4.0),
            onPressed: (){
              showRatingDialog();
            })
    );
  }
  Widget createHeader()
  {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,8.0),
      child: ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(50.0),child: FadeInImage.assetNetwork(placeholder: "assets/loading.gif",width: 75.0,height: 75.0,fit: BoxFit.fill, image: "https://lh3.googleusercontent.com/-5I7eulRb1LU/W0S1VhhLm2I/AAAAAAAAABI/N1y2TxPgUFIU9IQA0YBnFx1o4wkhGy8egCEwYBhgL/w140-h139-p/bhavneet.jpg",)),
        title: Text("SoundWave",style: Theme.of(context).textTheme.headline,),
        subtitle: Padding(
          padding: const EdgeInsets.only(top:4.0),
          child: Text("Version 1.0",style:Theme.of(context).textTheme.subhead,),
        ),
      ),
    );
  }
  Widget createTopics()
  {
    List<Widget>widgets=[];
//    widgets.add(createHeader());
    widgets.add(ListTile(
      title: Text("Notifications",style: Theme.of(context).textTheme.title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top:4.0),
        child: Text("Allow app to give notifications",style: Theme.of(context).textTheme.subtitle,),
      ),
      trailing: CupertinoSwitch(value: false, onChanged: (value){setState(() {
        SoundWaveState.showBetaDialog(context);
      });},),
    ));
    widgets.add(ListTile(
      title: Text("Dark Theme",style: Theme.of(context).textTheme.title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top:4.0),
        child: Text("Use app in night mode",style: Theme.of(context).textTheme.subtitle,),
      ),
      trailing: CupertinoSwitch(value: darkTheme, onChanged: (value){setState(() {
        darkTheme=value;
        if(prefs!=null)
          {
            prefs.setBool("darkTheme",value);
          }
        _showDialog(title:"Save Change",content:"You will have to open app again to see change",actionCallback: (){exit(0);});
      });},),
    ));

    widgets.add(buildOption("Music Quality", musicOptions[selectedIndex],Icons.music_note, (){showMusicOptions();}));
    widgets.add(buildOption("Clear Data", "Your all data will be deleted",Icons.delete, (){
       _showDialog(title:"Attention",content: "You will not be able to recover data again",actionCallback: (){
         DatabaseInterface databaseInterface=DatabaseInterface();
         databaseInterface.clearData();
       });
    }));
    widgets.add(buildOption("Credits", "Those who made this app possible",Icons.info_outline, (){
      Navigator.of(context).push(MaterialPageRoute(builder: (context){return CreditsScreen();}));
    }));

    widgets.add(buildOption("Github", "Fork app at github",Icons.info_outline, (){
      SoundWaveState.launchURL("https://github.com/singhbhavneet/Bungee");
    },icon: "images/github.png"));
    return Center(
      child: ListView.separated(
            itemBuilder:(context,index){
            return widgets[index];
            },
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: widgets.length,
            separatorBuilder: (BuildContext context, int index) {
            return Divider();
            },
      )
    );
  }
  Widget buildMusicOption()
  {
    return ExpansionTile(
      title: Text("Music Quality",style: Theme.of(context).textTheme.title),
      children: <Widget>[
        CupertinoSegmentedControl(children: ["Low","Medium","High"].map((text)=>Text(text)).toList().asMap(), onValueChanged: (value){})
      ],
      );
  }
  void showRatingDialog()
  {
    _showDialog(title:"Rate App ",content: "Give only that ratings which you think app deserves.",actionCallback: (){SoundWaveState.launchURL("https://play.google.com/store/apps/details?id=com.blackhole.soundwave");});
  }
  void _showBetaDialog() {
    _showDialog(title:"Beta Version",content: "Sorry this feature is not available now. Would you like to visit Github Page?");
  }
  void _showDialog({String title="",String content="",String action="Ok",Function actionCallback})
  {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text(title,style: Theme.of(context).textTheme.headline,),
            content: Text(content,style: Theme.of(context).textTheme.title,),
            actions: <Widget>[
              FlatButton(
                child: new Text("Cancel",style: Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).accentColor,fontWeight: FontWeight.bold),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text(action,style: Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).accentColor,fontWeight: FontWeight.bold),),
                onPressed: () {
                  actionCallback();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
  int selectedIndex=1;
  List<String>musicOptions=["Low","Medium","High"];
  void showMusicOptions()
  {
    showModalBottomSheet(context: context, builder: (context){
      List<Widget>options=List<Widget>.generate(musicOptions.length, (index){
        return createOptionTile(index==selectedIndex,musicOptions[index]);
      });
      return Container(color:Theme.of(context).scaffoldBackgroundColor,child: ListView.builder(itemBuilder:(context,index)=>options[index],shrinkWrap: true,itemCount: musicOptions.length,));
    });
    }
  Widget createOptionTile(bool active,String quality)
  {
    return ListTile(leading: Icon(Icons.check,color: active?Colors.white:Colors.transparent,),title: Text(quality),onTap: (){
      setState(() {
        selectedIndex=musicOptions.indexOf(quality);
        Navigator.of(context).pop();
      });
    },);
  }
  bool switchOn=true;

  Widget buildOption(String title,String subtitle,IconData trailing,Function callback,{String icon})
  {
    return ListTile(
      title: Text(title,style: Theme.of(context).textTheme.title,),
      subtitle: Padding(
        padding: const EdgeInsets.only(top:4.0),
        child: Text(subtitle,style: Theme.of(context).textTheme.subtitle),
      ),
      onTap: (){callback();},
      trailing: IconButton(icon: icon==null?Icon(trailing):ImageIcon(AssetImage(icon)), onPressed: (){},color: Theme.of(context).iconTheme.color,)
    );
  }
}

