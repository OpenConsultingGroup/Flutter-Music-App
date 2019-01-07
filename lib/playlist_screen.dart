import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/widgets/carousel.dart';
import 'package:soundwave/widgets/chromesearchbar.dart';
import 'package:soundwave/widgets/shadow_app_bar.dart';
import 'package:soundwave/widgets/more_button.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/music/heading.dart';

import 'dart:ui' show ImageFilter;


class PlaylistScreen extends StatefulWidget {
  PlaylistScreen({Key key, this.title, }) : super(key: key);
  final String title;
  @override
  _PlaylistScreenState createState() => new _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> with TickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  bool playing;
  String title;
  StreamSubscription<Command> subscription;
  static final _opacityTween = Tween<double>(begin: 0.0, end: 1.0);
  static final _sizeTween = Tween<double>(begin: 0.0, end: 300.0);
  @override
  void initState() {
    super.initState();
    title = "Home";
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation =
        Tween(begin: 0.0, end: 1.0).animate(controller);
    playing=SoundWaveState.currentPlaylist.playing;
    subscription=SoundWaveState.publishSubject.listen((Command command){
      if(command.command==Command.index)
        {
          setState(() {

          });
        }
    });
  }

  dispose() {
    controller.dispose();
    subscription.cancel();
    super.dispose();
  }
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  
  @override
  Widget build(BuildContext context) {
    List<Widget>widgets = [];
    controller.forward();
    return FadeTransition(
      opacity: animation,
      child: Scaffold(
        body:CustomScrollView(
          slivers: <Widget>[
            createAppbar(),
            SliverList(delegate: SliverChildBuilderDelegate((context,index){
              return AnimatedList(
                itemBuilder: (context,index,animation){
                  return SoundWaveState.currentPlaylist[index].buildPlaylistWidget(context,(){changeSong(index);}, (){
                    removeAt(index);
                  },active:index==SoundWaveState.currentPlaylist.active,playing:SoundWaveState.currentPlaylist.active==index&&playing);
                },
                initialItemCount: SoundWaveState.currentPlaylist.length,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                key: _listKey,
              );
            },childCount: 1),)
          ],
        )
      ),
    );
  }
  void changeSong(int index)
  {
    print("$index");
    if(index!=SoundWaveState.currentPlaylist.active)
      SoundWaveState.changeIndex(index);
  }
  CupertinoSliverNavigationBar createAppbar()
  {
    return CupertinoSliverNavigationBar(
        leading: CupertinoButton(
          child: Icon(CupertinoIcons.left_chevron,color: Theme.of(context).iconTheme.color,),
          minSize: 0.0,
          padding: EdgeInsets.zero,
          onPressed: (){
          Navigator.of(context).maybePop();
          },),
        largeTitle: Text("Queue",style: TextStyle(color: Theme.of(context).textTheme.title.color),textAlign: TextAlign.center,),
        heroTag: "Playlists",
        backgroundColor: Colors.transparent,
        trailing: CupertinoButton(
            minSize: 0.0,
            child: Icon(Icons.more_horiz,color: Theme.of(context).iconTheme.color,),
            padding: EdgeInsets.all(4.0),
            onPressed: (){
               showOptions();
            })
    );
  }
  void removeAt(int index)
  {
     if(index==SoundWaveState.currentPlaylist.active)
       return;
     Song song=SoundWaveState.currentPlaylist[index];

     SoundWaveState.removeItem(index);
     _listKey.currentState.removeItem(index, (context,animation){
       return SizeTransition(
           sizeFactor: animation,
           child:song.buildPlaylistWidget(context,(){},(){})
       );
     });
  }

  void showOptions() {
    showCupertinoModalPopup(context: context,builder: (context){
      return CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(onPressed: () {clearQueue();}, child: FlatButton.icon(onPressed: (){clearQueue();},materialTapTargetSize:MaterialTapTargetSize.shrinkWrap, icon: Icon(Icons.clear_all,color: Colors.black,), label: Text("Clear Queue",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black,fontWeight: FontWeight.normal),),padding: EdgeInsets.all(0.0),)),
        ],
        cancelButton:CupertinoActionSheetAction(onPressed: () {
          Navigator.of(context).maybePop();
        }, child: Text("Cancel",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black),),),

      );
    });
  }

  void clearQueue()
  {
      var count=SoundWaveState.currentPlaylist.length-1;
      while(count>=0)
      {
        removeAt(count--);
      }
      setState(() {

      });
  }


}