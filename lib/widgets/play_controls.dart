import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/play_screen.dart';
import 'package:soundwave/widgets/favourite_button.dart';
import 'package:soundwave/widgets/play_button.dart';

class PlayControls extends StatefulWidget{

  const PlayControls({Key key, }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>_PlayControlsState();
}
class _PlayControlsState extends State<PlayControls>{
  StreamSubscription subscription;
  PageController pageController;
  @override
  void initState() {
    super.initState();
    pageController=PageController(initialPage: SoundWaveState.currentPlaylist.active);

    subscription=SoundWaveState.publishSubject.listen((command){
      setState(() {
        if(command.command==Command.index)
          {

          }
      });
    });

  }
  dispose(){
    subscription.cancel();
    super.dispose();
  }
  Widget createControls()
  {
    print("Index ${SoundWaveState.currentPlaylist.active}");
    pageController=PageController(initialPage: SoundWaveState.currentPlaylist.active);
    return CupertinoButton(
      onPressed: (){
        playPlaylist();
      },
      minSize: 0.0,
      padding: EdgeInsets.symmetric(horizontal: 4.0,vertical: 4.0),
      child: Row(
        children: <Widget>[
          Hero( tag: SoundWaveState.currentPlaylist.activeSong.toString(),child: Container(margin: EdgeInsets.all(4.0),decoration: BoxDecoration(color: Colors.pinkAccent,borderRadius: BorderRadius.circular(4.0)),child: ClipRRect(borderRadius: BorderRadius.circular(8.0), child: Image(image: NetworkImage(SoundWaveState.currentPlaylist.activeSong.thumbnail),width: 50.0,height: 50.0,fit: BoxFit.fill,),)),),
          Expanded(child:Container(
            height: 60.0,
            child: PageView.builder(itemBuilder: (context,index){
              return buildItem(SoundWaveState.currentPlaylist.activeSong);
            },
              itemCount: SoundWaveState.currentPlaylist.length,
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              controller: pageController,
              onPageChanged: (index){

                setState(() {
                  if(index!=SoundWaveState.currentPlaylist.active){
                      SoundWaveState.changeIndex(index);
                  }
                });
              },),
          )),
          PlayButton(progress: true,)
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    if(SoundWaveState.currentPlaylist.length==0)
      {
        return Container(width: 0.0,height: 0.0,);
      }
     else
       {
         return createControls();
       }
    }

  Widget buildItem(Song song)
  {
    return Center(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(song.title,style: Theme.of(context).textTheme.title.copyWith(fontSize: 16.0,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
            Padding(
              padding: const EdgeInsets.only(top:2.0),
              child: Text(song.artist,style:Theme.of(context).textTheme.subtitle.copyWith(fontSize: 16.0),textAlign: TextAlign.center,),
            ),
          ]
      ),
    );
  }
  void playPlaylist()
  {
   try{
     Navigator.push(context,MaterialPageRoute(builder: (context){return PlayScreen();}));
   }
   catch(e)
    {
      print("Exception $e");
    }
  }
  
}