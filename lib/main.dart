import 'dart:async';
import 'dart:io';
import 'package:rxdart/rxdart.dart';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:soundwave/database.dart';
import 'package:soundwave/disclaimer_screen.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/widgets/bottom_navigation.dart';
import 'package:soundwave/home_screen.dart';
import 'package:soundwave/search_screen.dart';
import 'package:soundwave/collections_screen.dart';
import 'package:soundwave/settings_screen.dart';

import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:soundwave/widgets/play_controls.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  Brightness brightness;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  brightness = (prefs.getBool("darkTheme") ?? true) ? Brightness.dark: Brightness.light;
  bool start=prefs.getBool("start") ?? false;
  prefs.setBool("start",true);
  runApp(new MyApp(brightness: brightness,startScreen: start,));
}

class MyApp extends StatefulWidget{
  final Brightness brightness;
  final bool startScreen;
  const MyApp({Key key, this.brightness=Brightness.dark, this.startScreen=false}) : super(key: key);
  @override
  State<StatefulWidget> createState()=>_MyAppState();


}
class _MyAppState extends State<MyApp> {


  final Map<String,dynamic>darkTheme={
    "titleColor":Colors.white,
    "subtitleColor":Colors.white54,
    "scaffoldColor":Color(0xff141414)
  };

  @override
  Widget build(BuildContext context) {
    Map<String,dynamic>theme=darkTheme;
    return new MaterialApp(
      title: 'Music',
      theme: new ThemeData(
          brightness:widget.brightness,
          fontFamily: "GoogleSans",
          textTheme: TextTheme(
            headline: TextStyle(fontWeight: FontWeight.w600,fontSize: 18.0),
            title: TextStyle(fontSize: 16.0,fontWeight: FontWeight.w600),
            subtitle: TextStyle(fontSize: 14.0),
            caption: TextStyle( ),
            subhead: TextStyle(fontSize: 16.0,fontFamily: "GoogleSans"),
            display1: TextStyle(fontSize: 16.0,),
            display2: TextStyle(fontSize: 14.00,),
            display3: TextStyle(fontWeight: FontWeight.w600,fontSize: 18.0,),)
      ),
      home: widget.startScreen?SoundWave():DisclaimerScreen(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',

    );
  }
}

//PlaylistScreen(Playlist(Song.randomList(), "", "",""),(check,play){})
class SoundWave extends StatefulWidget {
  SoundWave({Key key, this.title}) : super(key: key);
  final String title;
  final SoundWaveState _soundWaveState=SoundWaveState();
  @override
  SoundWaveState createState() => _soundWaveState;
}

class SoundWaveState extends State<SoundWave> with TickerProviderStateMixin<SoundWave>{

  //Stream Controller
  static final StreamController<Command> streamController=StreamController<Command>();
  static final PublishSubject<Command> publishSubject=PublishSubject<Command>();
  static final Playlist currentPlaylist=Playlist();

  String title;
  TabController tabController;
  final Album playlist=Album(songs:[]);
  static final AudioPlayer audioPlayer=AudioPlayer();
  StreamSubscription<AudioPlayerState> audioPlayerSubscription;
  int currentIndex=0;
  static bool disabled=true;
  static bool playingState=false;
  static Duration duration=Duration(seconds: 0),position=Duration(seconds: 0);
  StreamSubscription<Duration> durationSubscription;
  StreamSubscription _sub;
  SoundWaveState()
  {
    initUniLinks();
  }

  dispose()
  {
    _sub.cancel();
    audioPlayer.stop();
    publishSubject.close();
    streamController.close();
    durationSubscription.cancel();
    audioPlayerSubscription.cancel();
    subscription.cancel();
    super.dispose();
  }
  //Deep Links

  Future<Null> initUniLinks() async {
    // ... check initialLink

    // Attach a listener to the stream
    _sub = getLinksStream().listen((String link) {
     print("Hello");
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });

    // NOTE: Don't forget to call _sub.cancel() in dispose()
  }
  static void showBetaDialog(BuildContext context)
  {
    showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("Beta Version",style: Theme.of(context).textTheme.headline,),
            content: Text("Sorry this feature is not available now. Would you like to visit Github Page?",style: Theme.of(context).textTheme.title,),
            actions: <Widget>[
              FlatButton(
                child: new Text("Cancel",style: Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).accentColor,fontWeight: FontWeight.bold),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text("Ok",style: Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).accentColor,fontWeight: FontWeight.bold),),
                onPressed: () {
                  launchURL("https://github.com/singhbhavneet/Bungee");
                },
              ),
            ],
          );
        });

  }
  //Interface
  static void play({bool playing=true})
  {
    if(disabled)
      {
        return;
      }
    if(playing)
    {
      publishSubject.sink.add(Command(command: Command.play,data: true));
    }
    else
      {
        publishSubject.sink.add(Command(command: Command.play,data: false));
      }
  }
  static void changePlayingState({bool playing=true})
  {
    currentPlaylist.playing=playing;
    publishSubject.sink.add(Command(command: Command.playingState,data: playing));

  }
  static void removeItem(int index){
    if(index==currentPlaylist.active)
      {
        return;
      }
    currentPlaylist.remove(index);
    publishSubject.sink.add(Command(command: Command.remove,data: index));
  }
  static void changeIndex(int index){
    print("Actove $index");
    currentPlaylist.active=index;
    databaseInterface.addRecentlyPlayed(currentPlaylist.activeSong);
    publishSubject.sink.add(Command(command: Command.index,data: index));
  }
  static void playSongs(List<Details>songs,int index)
  {
    int active=index;
    List<Song>playlist=[];
    for(int i=0;i<songs.length;i++)
    {
      var item=songs[i];
      if(item is Song)
      {
        playlist.add(item);
      }
      else if(item is Album)
      {
        playlist.addAll(item.songs);
        if(index>i)
        {
          active+=item.songs.length-1;
        }
      }
    }
    SoundWaveState.addSongs(Album(songs:playlist),active: active);
  }
  static DatabaseInterface databaseInterface=DatabaseInterface();
  static void addSongs(Details data,{int active=-1})
  {
    print("Active index $active");
    int index=0;
    if(data is Song )
      {
        currentPlaylist.addAll([data]);
        index=currentPlaylist.songs.indexOf(data);
      }
    else if(data is Album)
      {
        currentPlaylist.addAll(data.songs);
        index=currentPlaylist.songs.indexOf(data[active]);
      }
    print("Active song $index");

   changeIndex(index);
  }
  static void addNext(Song song,)
  {
      currentPlaylist.addNextSong(song);
  }
  static void addToQueue(Song song)
  {
      currentPlaylist.addAll([song]);
  }
  static void disable(bool disable)
  {
    disabled=disable;
    if(disable)
      {
        changePosition(Duration(seconds: 0));
        changeDuration(Duration(seconds: 0));
      }
    currentPlaylist.playing=false;
    publishSubject.sink.add(Command(command: Command.disable,data: disabled));
  }
  static void changeDuration(Duration value)
  {

    duration=value;
    publishSubject.sink.add(Command(command: Command.duration,data:duration));
  }
  static void changePosition(Duration value) {
    position= value;
    publishSubject.sink.add(Command(command: Command.position,data: position));
  }
  static void createPosition(Duration value) {
    publishSubject.sink.add(Command(command: Command.createPosition,data: value));
  }
  StreamSubscription<Command>subscription;
  //
  List<Widget>screens=[];
  List< GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
   GlobalKey<NavigatorState>(),
   GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  @override
  void initState() {
    super.initState();
    title="SoundWave";
    List<Widget>widgets=[];
    screens.add(HomeScreen());
    screens.add(SearchScreen());
    screens.add(CollectionsScreen());
    screens.add(SettingsScreen());
    screens=screens.map((screen)=>WillPopScope(onWillPop: (){screensPop();},child: screen,)).toList();
    tabController=TabController(length: screens.length, vsync: this);
    tabController.index=currentIndex;
    //Main Subscription
    //Change Song
    subscription=publishSubject.listen((command){
      if(command.command==Command.index){
        try{
          print("Audio ${command.data}");
          disable(true);
          play(playing: false);
          changePosition(Duration(seconds:0));
          changeDuration(Duration(seconds:0));
          audioPlayer.stop().then(
                  (value){
                  audioPlayer.play(currentPlaylist.activeSong.link).whenComplete((){
                    audioPlayer.seek(0.0);
                });
              }
          );
        }
        catch(e)
          {
           print(e);
          }
      }
      if(command.command==Command.createPosition)
        {
          try{
            Duration value=command.data;
            audioPlayer.seek(value.inSeconds.toDouble());
          }
          catch(e)
            {
             print(e);
            }
        }
      if(command.command==Command.play)
        {
          if(command.data)
            {
              audioPlayer.play(currentPlaylist.activeSong.link);
            }
          else
            {
              audioPlayer.pause();
            }
        }
    });
    //Audio Player Subscriptions
    /*
     * Player state changed
    * */
    audioPlayerSubscription=audioPlayer.onPlayerStateChanged.listen((state){
      if (state == AudioPlayerState.PLAYING) {
        disable(false);
        changePlayingState(playing: true);
      }
      else if(state==AudioPlayerState.PAUSED){
        if(currentPlaylist.playing)
          {
            changePlayingState(playing:false);
          }
      }
      else if (state == AudioPlayerState.STOPPED) {
        if(!disabled)
          {
            changePlayingState(playing: false);
            disable(true);
          }
      }
    },
        onError: (msg) {

      }
    );
    /*
    * Positions changed in audio player
    * */
    durationSubscription=audioPlayer.onAudioPositionChanged.listen((p){
          position = p;
          duration=audioPlayer.duration;
          if(!disabled)
            {
              changePosition(p);
              changeDuration(duration);
            }
          if(position.inSeconds==duration.inSeconds&&duration.inSeconds>0)
            {
              if(currentPlaylist.active<currentPlaylist.length-1)
                {
                  changeIndex(currentPlaylist.active+1);
                }
              else
                {
                  changeIndex(0);
                }
            }
        }
    );
  }
//
  Navigator createScreen(int index,Widget screen)
  {

    return Navigator(
      key: navigatorKeys[index],
      initialRoute: "/",

      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/':
            print("2");
            // Assume CollectPersonalInfoPage collects personal info and then
          // navigates to 'siComgnup/choose_credentials'.
            builder = (BuildContext _) => screen;
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute(builder: builder, settings: settings,);
      },
    );
  }
  void screensPop()
  {
    if(currentIndex==0)
    {
        showDialog(context: context,builder: (context){
          return AlertDialog(
            title: Text("Do you want to exit?"),
            actions: <Widget>[
              FlatButton(
                child: new Text("Cancel",style: Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).accentColor,fontWeight: FontWeight.bold),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: new Text("Ok",style: Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).accentColor,fontWeight: FontWeight.bold),),
                onPressed: () {
                  exit(0);
                },
              ),
            ],
          );
        } );
    }
    else
    {
      setState(() {
        currentIndex=0;
      });
      navigatorKeys[0].currentState.pushReplacement(MaterialPageRoute(builder: (context)=>screens[currentIndex]));
    }

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: WillPopScope(
          onWillPop: () {
            if(navigatorKeys[0].currentState.canPop())
            navigatorKeys[0].currentState.maybePop();
            else
              {
                screensPop();
               }
          },
        child: createScreen(0, screens[0]),
        ),
     bottomNavigationBar:createBottom()
    );
  }
  int length=0;
  Widget createBottom()
  {
    List<Widget>widgets=[];
    widgets.add(PlayControls());
    widgets.add(
      BottomNavigationBar(items: createBottomNavigation(),onTap: (index){
        if(index!=currentIndex)
        setState(() {
          currentIndex=index;
          navigatorKeys[0].currentState.pushReplacement(MaterialPageRoute(builder: (context)=>screens[index]));
        });
      },type: BottomNavigationBarType.fixed,fixedColor:Theme.of(context).textTheme.title.color,iconSize: 24.0,currentIndex: currentIndex,)
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widgets
    );
  }

  List<Widget> createBottomItems()
  {
    List<String>items=["Home","Search","Collections","Settings"];
    return items.map((item)=>ImageIcon(AssetImage("images/${item.toLowerCase()}.png"))).toList();
  }
  List<BottomNavigationBarItem> createBottomNavigation()
  {
    List<String>items=["Home","Search","Collections","Settings"];
    List<Choice>choices=[
      Choice("Home",Icons.home),
      Choice("Search",Icons.search),
      Choice("Collections",Icons.queue_music),
      Choice("Settings",Icons.settings),
    ];
    int i=0;
    return items.map((item){
      double size=20.0;
      if(i==0&&i==3)
        {
          size=20.0;
        }
       i++;
      return BottomNavigationBarItem(icon: ImageIcon(AssetImage("images/${item.toLowerCase()}.png"),size: size,),title: Padding(
        padding: const EdgeInsets.only(top:4.0),
        child: Text(item,style: TextStyle(fontSize: 10.0),),
      ));
    }).toList();
  }

  //static function
  static launchURL(String url) async {
    url=Uri.encodeFull(url);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Sorray can not launch url");
    }
  }
  static share(String url)
  {
    Share.share(url,);
  }

}
class Choice{
  String title;
  dynamic icon;

  Choice(this.title, this.icon);

}
class Command
{
  static final String play="play",pause="pause",change="change",index="index",duration="duration",position="position",disable="disable",remove="remove",playingState="playlingState";
  final String command;
  final dynamic data;

  static final String createPosition="changePosition";

  Command({this.command, this.data});
}
class Playlist{
  List<Song>songs=[];
  int _active=-1;
  bool _playing=false;
  set active(int index)=>_active=(index>=0&&index<songs.length?index:0);
  int get active =>_active;
  Song get activeSong =>songs.length!=0?songs[_active]:Song(links: [],thumbnail: "",title: "",artists: [],);
  int get length=>songs.length;
  bool get playing =>_playing;
  set playing (check)=>_playing=check;
  int set (check)=>_playing=check;
  Song operator [] (index)=>songs[index];
  int addNextSong(Song song)
  {
    if(songs.contains(song))
    {
      songs.remove(song);
    }
    songs.insert(active+1, song);
    if(songs.length==1)
      {
        SoundWaveState.changeIndex(0);
      }
    return songs.indexOf(song);
  }
  //Interface
  void remove(int index)
  {
    if(index==_active)
      {
        return;
      }
    songs.removeAt(index);
    if(index<_active)
      {
        _active--;
      }
  }
  void addAll(List<Song> songs) {
    for(int i=0;i<songs.length;i++)
    {
      Song song=songs[i];
      int index=this.songs.indexOf(song);
      if(index!=-1)
      {
        if(index<active)
        {
          active--;
        }
        this.songs.removeAt(index);
      }
    }
    this.songs.addAll(songs);
    if(this.songs.length==1)
      {
        SoundWaveState.changeIndex(0);
      }
  }

}