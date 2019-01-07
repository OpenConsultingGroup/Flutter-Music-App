import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundwave/collections_screen.dart';
import 'package:soundwave/items_screen.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/playlist_screen.dart';
import 'package:soundwave/widgets/carousel.dart';
import 'package:soundwave/widgets/chromesearchbar.dart';
import 'package:soundwave/widgets/favourite_button.dart';
import 'package:soundwave/widgets/menu_button.dart';
import 'package:soundwave/widgets/play_button.dart';
import 'package:soundwave/widgets/shadow_app_bar.dart';
import 'package:soundwave/widgets/more_button.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/music/heading.dart';
import 'package:audioplayer/audioplayer.dart';
import 'dart:ui' show ImageFilter;


class PlayScreen extends StatefulWidget {
  PlayScreen({Key key, this.title}) : super(key: key);
  final String title;
  
  @override
  _PlayScreenState createState() => new _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with SingleTickerProviderStateMixin{

  String title;
  final GlobalKey<ScaffoldState> _scaffoldKey = new
  GlobalKey<ScaffoldState>();
  bool disableButton=true;
  StreamSubscription<Command>subscription;
  @override
  void initState() {
    super.initState();
    getPrefs();
    title="Home";
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.black26));
    currentPosition=SoundWaveState.position.inSeconds.toDouble();

    subscription=SoundWaveState.publishSubject.listen((Command command){
      if(command.command==Command.position)
        {
          currentPosition=command.data.inSeconds.toDouble();
        }
      if(command.command==Command.index&&controller!=null&&controller.page.toInt()!=command.data)
        {
            controller.jumpToPage(command.data);
        }
      if(command.command==Command.remove&&controller!=null&&controller.page.toInt()!=SoundWaveState.currentPlaylist.active)
      {
        controller.jumpToPage(SoundWaveState.currentPlaylist.active);
      }
      if(command.command==Command.disable)
        {
          disableButton=command.data;
        }
      setState(() {

      });

    });
    controller=PageController(initialPage: SoundWaveState.currentPlaylist.active);
  }

  dispose()
  {
    subscription.cancel();
    super.dispose();
  }
  void getPrefs()async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = (prefs.getBool("playFirst") ?? true);
    prefs.setBool("playFirst",false);
    if(firstTime)
    {
      showDialog(context: context,builder: (context){
        return AlertDialog(
          title:Text( "Disclaimer"),
          content: Text("Sometimes song may take time to load may be more than 30s so be patient"),
          actions: <Widget>[
            FlatButton(onPressed: (){Navigator.of(context).pop();}, child:Text("Ok",style: Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).accentColor),))
          ],
        );
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    List<Widget>widgets=[];
    Widget playControls=createPlayControls();
    Widget cover=createCover();
    return
      Stack(
        children: <Widget>[
          FadeInImage.assetNetwork(placeholder: "images/music_placeholder.png", image: SoundWaveState.currentPlaylist.activeSong.thumbnail,width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height,fit: BoxFit.cover,),
          BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0,),
              child: new Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: new BoxDecoration(
                      color: Colors.black.withOpacity(0.5)
                  ))),
          Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.transparent,
            appBar: createAppbar(),
            body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              cover,
              playControls
            ],
          )
    ),
        ],
      );
  }
  AppBar createAppbar()
  {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.white),
      brightness: Brightness.dark,
      leading: IconButton(icon:ImageIcon(AssetImage("images/back_navigation.png"),size: 20.0,), onPressed: (){
        Navigator.of(context).pop();
      },),
      title: CupertinoButton(

        minSize: 0.0,
        padding: EdgeInsets.all(0.0),
        onPressed: (){showPlaylist();},
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical:4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom:6.0),
                child: Text(SoundWaveState.currentPlaylist.activeSong.title,style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.bold,fontSize: 14.0,color: Colors.white),),
              ),
              DotsIndicator(initialPage: SoundWaveState.currentPlaylist.active,itemCount: SoundWaveState.currentPlaylist.length>=3?3: SoundWaveState.currentPlaylist.length,controller: controller,color: Colors.white,),
            ],
          ),
        ),
      ),

      elevation: 0.0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: MenuButton(SoundWaveState.currentPlaylist.activeSong,showPlay: false,color: Colors.white,),
        )
      ],
    );
  }

  IconData playIcon=Icons.play_arrow;
  double currentPosition=0.0;
  void addToPlaylist(Song song)
  {
    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>CollectionsScreen(songs: [song],)));
  }
  Widget createPlayControls()
  {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left:8.0),
            child: ListTile(
              title: Text(SoundWaveState.currentPlaylist.activeSong.title,style: Theme.of(context).textTheme.headline.copyWith(fontSize: 18.0,color: Colors.white),maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
              subtitle: Padding(
                padding: const EdgeInsets.only(top:4.0),
                child: Text(SoundWaveState.currentPlaylist.activeSong.artist,style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 16.0,color: Colors.white),maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
              ),
              leading: FavouriteButton(SoundWaveState.currentPlaylist.activeSong,size: 20.0,padding: 0.0,color: Colors.white,),
              trailing: IconButton(icon: Icon(Icons.add), onPressed: (){
                addToPlaylist(SoundWaveState.currentPlaylist.activeSong);
              },color: Colors.white,),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:16.0),
            child: Slider(value: currentPosition, onChangeEnd: (value){setState(() {
              SoundWaveState.createPosition(Duration(seconds: value.toInt()));
            });},activeColor: CupertinoColors.white,inactiveColor: Colors.white54,min: 0.0,max: SoundWaveState.duration.inSeconds.ceilToDouble(), onChanged: (double value) {
              setState(() {
                currentPosition=value;
              });
            },),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical:0.0,horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(time(Duration(seconds: currentPosition.toInt())),style: TextStyle(color: Colors.white,fontSize: 12.0),),
              Text(time(SoundWaveState.duration),style: TextStyle(color: Colors.white,fontSize: 12.0),)],
          ),
        ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
            IconButton(icon: Icon(Icons.shuffle,size: 24.0,),onPressed: (){SoundWaveState.showBetaDialog(context);},color: Color(0xff616161),),
            IconButton(icon: Icon(Icons.skip_previous,size: 32.0,),disabledColor: Color(0xff616161),onPressed: SoundWaveState.currentPlaylist.active<=0?null:
            (){
                controller.jumpToPage(SoundWaveState.currentPlaylist.active-1);
            },
              color: Colors.white),
            PlayButton(size: 64.0,color: Colors.white,),
             IconButton(icon: Icon(Icons.skip_next,size: 32.0),disabledColor: Color(0xff616161),onPressed: SoundWaveState.currentPlaylist.active==SoundWaveState.currentPlaylist.length-1?null:
                (){
                  controller.jumpToPage(SoundWaveState.currentPlaylist.active+1);
                  },color: Colors.white),
            IconButton(icon: Icon(Icons.repeat,size: 24.0,),onPressed: (){SoundWaveState.showBetaDialog(context);},color:  Color(0xff616161),),
          ],
          ),
        ],
      ),
    );
  }

  Widget playButton()
  {
    if(SoundWaveState.disabled)
      {
        disableButton=true;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircularProgressIndicator(strokeWidth: 5.0,),
        );
      }
   else
    {
      disableButton=false;
      return  IconButton(icon: Icon(SoundWaveState.currentPlaylist.playing?Icons.pause:Icons.play_arrow),disabledColor: Colors.grey,tooltip: "Play",iconSize: 64.0,onPressed: (){
        SoundWaveState.play(playing: !SoundWaveState.currentPlaylist.playing);
      },color: Colors.white,);
    }
  }

  void showPlaylist()
  {
   Navigator.of(context).push(MaterialPageRoute(builder: (context){
     return PlaylistScreen();
   })).then((value){

   });
  }

  String time(Duration duration)
  {
    int seconds=duration.inSeconds;
    return "${(seconds/60).floor().abs()}:${(seconds%60).floor().abs()}";
  }
  PageController controller;

  Widget createCover()
  {
    return Expanded(child: PageView.builder(itemBuilder: (context,index){
      return SoundWaveState.currentPlaylist[index].buildPlayCoverWidget(context,(){});
    },
      controller: controller,
      onPageChanged: (index){
        if(index==SoundWaveState.currentPlaylist.active)
        {
          return;
        }
        setState(() {
          SoundWaveState.changeIndex(index);
        });
      },
      itemCount: SoundWaveState.currentPlaylist.length,
      physics: BouncingScrollPhysics(),
      pageSnapping: true,
    ),);
  }

  String kUrl="http://khalsaonline.net/Mp3/Nitnem/load/Nitnem/Paath/Chaupai%20Sahib/Bhai%20Jarnail%20Singh%20-%20Chaupai%20Sahib%20%20.mp3";


}
