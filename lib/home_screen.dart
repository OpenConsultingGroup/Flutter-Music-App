import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:soundwave/about_developer.dart';
import 'package:soundwave/item_builder.dart';
import 'package:soundwave/items_screen.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/widgets/carousel.dart';
import 'network.dart';
import 'dart:ui' show ImageFilter;
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';


class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin{
  Animation<double> animation;
  AnimationController controller;
   ItemBuilder _itemBuilder;
  String title;
  Future future;
  @override
  void initState() {
    super.initState();
    title="Home";
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation =
        Tween(begin: 0.0, end: 1.0).animate(controller);
    _itemBuilder=ItemBuilder(context);
   future= Network.getHome();
  }
  dispose() {
    controller.dispose();
    super.dispose();
  }
  List<Widget>widgets=[];
  @override
  Widget build(BuildContext context) {
    controller.forward();
    return WillPopScope(
      child: FadeTransition(
        opacity: animation,
        child: CustomScrollView(
          slivers: <Widget>[
            createAppbar(),
            SliverList(delegate:SliverChildBuilderDelegate((context,index){
              return body();
            },childCount: 1), )
          ],
        ),
      ), onWillPop: () {
        Navigator.maybePop(context);
    },
    );

  }
   Widget body()
   {
     return  FutureBuilder(
         future: future,
         builder: (context,snapshot){
           if(!snapshot.hasData||snapshot.connectionState==ConnectionState.waiting)
           {
             return Center(child: CircularProgressIndicator());
           }
           widgets.clear();
           Map<String,List>map=snapshot.data;
           if(map.containsKey("Top 20 Songs"))
           {
             List<Song>songs=List<Song>.from(map["Top 20 Songs"]).toList();
           widgets.add(createChoices());
           }
           if(map.containsKey("Top Punjabi Albums"))
           {
            widgets.add(_itemBuilder.buildTopAlbums(List<Details>.from(map["Top Punjabi Albums"])));
           }
           if(map.containsKey("Top 20 Songs"))
           {
           List<Song>songs=List<Song>.from(map["Top 20 Songs"]).take(4).toList();
           widgets.add(_itemBuilder.buildTrendingPlaylist("Editorial Picks", songs));
           }
           if(map.containsKey("categories"))
           {
           List<Genre>genres=List<Genre>.from(map["categories"]);
           widgets.add(_itemBuilder.buildCategoryGrid(genres));
           }
           if(map.containsKey("Top Artists"))
           {
           List<Artist>artists=List<Artist>.from(map["Top Artists"]).toList();
           widgets.add(_itemBuilder.buildArtistList(artists));
           }

           return ListView.builder(itemBuilder: (context,index){
           return widgets[index];
           },
           physics: BouncingScrollPhysics(),
           shrinkWrap: true,
           itemCount: widgets.length,);
         },
     );
   }
  CupertinoSliverNavigationBar createAppbar()
  {
    return CupertinoSliverNavigationBar(
        leading: CupertinoButton(
          child: ImageIcon(AssetImage("images/logo.png"),color: Theme.of(context).iconTheme.color,),
          minSize: 0.0,
          padding: EdgeInsets.zero,
          onPressed: (){
            Navigator.of(context).maybePop();
          },),
        largeTitle: Text("Browse",style: TextStyle(color: Theme.of(context).textTheme.title.color),textAlign: TextAlign.center,),
        heroTag: "Browse",
        transitionBetweenRoutes: false,
        backgroundColor: Colors.transparent,
        trailing: CupertinoButton(
            minSize: 0.0,
            child: Icon(Icons.more_horiz,color:  Theme.of(context).iconTheme.color,),
            padding: EdgeInsets.all(4.0),
            onPressed: (){
                _showDialog()  ;
            })
    );
  }
  void _showDialog()
  {
    showCupertinoModalPopup(context: context,builder: (context){
      return CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(onPressed: () {SoundWaveState.launchURL("https://github.com/singhbhavneet/Bungee/issues");}, child: Text("Report...",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black,fontWeight: FontWeight.normal),),),
          CupertinoActionSheetAction(onPressed: () {SoundWaveState.share("https://play.google.com/store/apps/details?id=com.blackhole.soundwave");}, child: Text("Share",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black,fontWeight: FontWeight.normal),),),
          CupertinoActionSheetAction(onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder:(context)=>DeveloperScreen()));}, child: Text("About Developer",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black,fontWeight: FontWeight.normal),),),
        ],
        cancelButton:CupertinoActionSheetAction(onPressed: () {
          Navigator.of(context).maybePop();
        }, child: Text("Cancel",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black),),),

      );
    });
  }

   Widget createChoices()
   {
     List<Choice>choices=[];
     choices.add(Choice("New Releases",Icon(Icons.music_note,color:  Theme.of(context).iconTheme.color,),"library/new releases"));
     choices.add(Choice("Playlists",Icon(Icons.playlist_play,color:  Theme.of(context).iconTheme.color,),"public"));
     choices.add(Choice("Charts",Icon(Icons.trending_up,color:  Theme.of(context).iconTheme.color,),"library/top 20 songs"));
     choices.add(Choice("Albums",Icon(Icons.album,color:  Theme.of(context).iconTheme.color,),"library/punjabi albums"));
     choices.add(Choice("Surprise",null,"library/bollywood mix"));
     return ListView.builder(itemBuilder: (context,index)=>choices[index].buildWidget(context),itemCount: choices.length,shrinkWrap: true,physics: ClampingScrollPhysics(),);
   }
}
class Choice{
  final String title;
  final Icon icon;
  final String url;
  Choice(this.title, this.icon, this.url);

  Widget  buildWidget(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(title,style:icon!=null? Theme.of(context).textTheme.headline:Theme.of(context).textTheme.headline.copyWith(color: Colors.lightGreen,fontStyle: FontStyle.italic),),
      trailing: Icon(Icons.chevron_right,color:  Theme.of(context).textTheme.subtitle.color,),
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return ItemsScreen(Details(url: url,title: title),);
        }));
      },
    );
  }

}
