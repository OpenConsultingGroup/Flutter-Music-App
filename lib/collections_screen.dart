import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundwave/createplaylist_screen.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/music/song.dart';
import "package:http/http.dart" as http;
import 'package:soundwave/database.dart';
import 'dart:ui' show ImageFilter;

import 'package:soundwave/shuffle_screen.dart';
import 'package:soundwave/widgets/social_button.dart';


class CollectionsScreen extends StatefulWidget {
  CollectionsScreen({Key key, this.title, this.songs}) : super(key: key);
  final String title;
  final List<Details> songs;
  @override
  _CollectionsScreenState createState() => new _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> with TickerProviderStateMixin{

  String title;
  List<Widget>tabs=[],tabBody=[];
  TabController tabController;
  DatabaseInterface databaseInterface;
  GlobalKey<ScaffoldState>key=GlobalKey<ScaffoldState>();
  TextEditingController controller;
  FocusNode focusNode;
  _CollectionsScreenState(){
    databaseInterface=DatabaseInterface();
    databaseInterface.open();
  }
  bool addToPlaylist=false;
  @override
  void initState() {
    super.initState();
    title="Collections";
    controller=TextEditingController();
    focusNode=FocusNode();
  }
  int currentIndex=0;
  List<Widget>screens=[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      body: CustomScrollView(
        slivers: <Widget>[
          createAppbar(),
          SliverList(delegate:SliverChildBuilderDelegate((context,index){
            return getPlaylists();
          },childCount: 1), )
        ],
      ),
    );
  }
  String playlistName="";
  CupertinoSliverNavigationBar createAppbar()
  {
    return CupertinoSliverNavigationBar(
      leading: CupertinoButton(
        child: Icon(CupertinoIcons.left_chevron,color:   Theme.of(context).iconTheme.color,size: 28.0,),
        minSize: 0.0,
        padding: EdgeInsets.zero,
          onPressed: (){
             Navigator.maybePop(context);
          },),
      largeTitle: Text(title,style: TextStyle(color:  Theme.of(context).textTheme.title.color),textAlign: TextAlign.center,),
      heroTag: DateTime.now().toString(),
      backgroundColor: Colors.transparent,
      trailing: CupertinoButton(
          minSize: 0.0,
          child: Icon(Icons.more_horiz,color:   Theme.of(context).iconTheme.color,),
          padding: EdgeInsets.all(4.0),
          onPressed: (){
            createPlaylist();
          })
    );
  }

  Widget getPlaylists()
  {
    return FutureBuilder(
      future:databaseInterface.getPlaylists(),
      builder: (context,snapshot){
        if(!snapshot.hasData)
        {
          return Center(child: CircularProgressIndicator(),);
        }
        else if(snapshot.hasData)
        {
          List<Details> playlists = snapshot.data;
          if(playlists==null)
          {
            return Container();
          }
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,childAspectRatio: 0.8,),
            itemBuilder:(context,index){
              return buildPlaylistWidget(playlists[index]);
            },
            padding: EdgeInsets.all(8.0),
            shrinkWrap: true,
            itemCount: playlists.length,
            physics: BouncingScrollPhysics(),
          );
        }
        else if(snapshot.hasError)
        {
          return Text(snapshot.error.toString()) ;
        }
      },
    );
  }

  Widget buildPlaylistWidget(Details data)
  {
    double size=MediaQuery.of(context).size.width/2.2;
    return CupertinoButton(
      onPressed:(){
        if(widget.songs!=null)
          {
            databaseInterface.addToPlaylist(widget.songs, data.title);
            key.currentState.showSnackBar(SnackBar(content: Text("Song added to Playlist")));
          }
         else
           {
             Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SongsScreen(data)));
           }
      },
      padding: EdgeInsets.all(0.0),
      minSize: 0.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical:12.0,horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              foregroundDecoration: BoxDecoration(color:Colors.black26),
              decoration: BoxDecoration(color:Color(0xfffeee6ff),borderRadius:BorderRadius.circular(8.0)),
              child: ClipRRect(
                borderRadius:BorderRadius.circular(8.0),
                child: FadeInImage.assetNetwork(placeholder:"images/music_placeholder.png", image: data.thumbnail,width: size,height: size,fit: BoxFit.fill,),),
            ),
            Padding(
              padding: const EdgeInsets.only(top:8.0),
              child: Text(data.title,style:Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
  void createPlaylist()
  {
    showCupertinoModalPopup(context: context,builder: (context){
      return CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(onPressed: () {_showDialog();}, child: FlatButton.icon(onPressed: (){_showDialog();},materialTapTargetSize:MaterialTapTargetSize.shrinkWrap, icon: Icon(Icons.add_circle), label: Text("Create Playlist",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black),),padding: EdgeInsets.all(0.0),)),
        ],
        cancelButton:CupertinoActionSheetAction(onPressed: () {
          Navigator.of(context).maybePop();
        }, child: Text("Cancel",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black),),),

      );
    });
  }
  void _showDialog()
  {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        title: Text("Create Playlist",style: Theme.of(context).textTheme.title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor,style: BorderStyle.solid,width: 2.0))),
          textCapitalization: TextCapitalization.words,
          style: Theme.of(context).textTheme.headline,
        ),
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
              if(controller.text.length>0)
                databaseInterface.createPlaylist(controller.text).then((value){
                  Navigator.of(context).maybePop();
                });
            },
          ),
        ],
      ),
    );
  }
}

class SongsScreen extends StatefulWidget{
  final Details playlistDetails;
  const SongsScreen(this.playlistDetails,{Key key, }) : super(key: key);
  @override
  State<StatefulWidget> createState() =>SongsScreenState();

}
class SongsScreenState extends State<SongsScreen> with TickerProviderStateMixin
{
  DatabaseInterface databaseInterface;
  Animation<double>animation;
  AnimationController animationController;
  GlobalKey<AnimatedListState>key=GlobalKey();
  @override
  void initState() {
    super.initState();
    getPrefs();
    databaseInterface=DatabaseInterface();
    animationController=AnimationController(vsync: this,duration: Duration(seconds: 1));
    animation=Tween<double>(begin: 0.0,end: 1.0).animate(animationController);
  }
  @override
  Widget build(BuildContext context) {
    animationController.forward(from: 0.0);
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          createAppbar(),
          SliverList(delegate:SliverChildBuilderDelegate((context,index){
            return getSongs();
          },childCount: 1), )
        ],
      ),
    );
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
        largeTitle: Text(widget.playlistDetails.title,style: TextStyle(color:   Theme.of(context).textTheme.title.color),textAlign: TextAlign.center,),
        heroTag: DateTime.now().toString(),
        backgroundColor: Colors.transparent,
        trailing: CupertinoButton(
            minSize: 0.0,
            child: Icon(Icons.more_horiz,color:   Theme.of(context).iconTheme.color,),
            padding: EdgeInsets.all(4.0),
            onPressed: (){
              showOptions();
            })
    );
  }
  void getPrefs()async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = (prefs.getBool("shareList") ?? true);
    prefs.setBool("shareList",false);
    if(firstTime)
      {
        showOptions();
      }
  }
  List songs=[];
  Widget getSongs()
  {
    return StreamBuilder(
      stream:databaseInterface.getSongs(widget.playlistDetails.title).asStream() ,
      builder: (context,snapshot){
        if(!snapshot.hasData)
        {
          return Center(child: CircularProgressIndicator(),);
        }
        else if(snapshot.hasData)
        {
          List data = snapshot.data;
          if(data==null)
            {
              return Container(width: 0.00,height: 0.0,);
            }
          songs.clear();
          songs.addAll(data);
          return AnimatedList(
            key: key,
              itemBuilder: (context,index,animation){
            return songs[index].buildCollectionsWidget(context, (){
              playSongs(index);
            }, (){removeSong(index);});
          },
            initialItemCount: songs.length,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
          );
        }
        else if(snapshot.hasError)
        {
          return Text(snapshot.error.toString()) ;
        }
      },
    );
  }
  void playSongs(int index)
  {
    SoundWaveState.playSongs(List<Details>.from(songs), index);
  }
  void removeSong(int index) {
    Details song=songs[index];
    songs.removeAt(index);
    key.currentState.removeItem(index, (context,animation){
      return SizeTransition(
          sizeFactor: animation,
          child:song.buildCollectionsWidget(context,(){},(){})
      );
    });
    databaseInterface.removeFromPlaylist(song, widget.playlistDetails.title);
  }
  void _showDialog()
  {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Do you want to delete playlist?",style: Theme.of(context).textTheme.headline),
        content: Text("By deleting playlist you will not be able recover it again.",style: Theme.of(context).textTheme.title),
        actions: <Widget>[
          FlatButton(
            child: new Text("Cancel",style: Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).accentColor,fontWeight: FontWeight.bold),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: new Text("Yes",style: Theme.of(context).textTheme.title.copyWith(color: Theme.of(context).accentColor,fontWeight: FontWeight.bold),),
            onPressed: () {
              databaseInterface.deletePlaylist(widget.playlistDetails.title);
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }
  void showOptions()
  {
    showCupertinoModalPopup(context: context,builder: (context){
      return CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(onPressed: () {playSongs(0);Navigator.of(context).pop();}, child: FlatButton.icon(onPressed: (){},materialTapTargetSize:MaterialTapTargetSize.shrinkWrap, icon: Icon(Icons.play_circle_filled,color: Colors.black,), label: Text("Play  ",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black),),padding: EdgeInsets.all(0.0),)),
          CupertinoActionSheetAction(onPressed: () {_showDialog();}, child: FlatButton.icon(onPressed: (){},materialTapTargetSize:MaterialTapTargetSize.shrinkWrap, icon: Icon(Icons.delete,color: Colors.black,), label: Text("Delete",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black),),padding: EdgeInsets.all(0.0),)),
          CupertinoActionSheetAction(onPressed: () {}, child: SocialButton(widget.playlistDetails)),
        ],
        cancelButton:CupertinoActionSheetAction(onPressed: () {
          Navigator.of(context).maybePop();
        }, child: Text("Cancel",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black),),),

      );
    });
  }
}