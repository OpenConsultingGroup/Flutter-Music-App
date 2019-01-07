import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/database.dart';

class DisclaimerScreen extends StatefulWidget{
  const DisclaimerScreen({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>DisclaimerScreenState();

}
class DisclaimerScreenState extends State<DisclaimerScreen>{
  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          createAppbar(),
          SliverList(delegate:SliverChildBuilderDelegate((context,index){
            return body();
          },childCount: 1), )
        ],
      ),
      bottomNavigationBar: BottomAppBar(child: CupertinoButton(child: Text("Continue",style: TextStyle(color: Colors.white),),color: Colors.redAccent, onPressed: (){Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>SoundWave()));}),),
    );
  }
  CupertinoSliverNavigationBar createAppbar()
  {
    return CupertinoSliverNavigationBar(

      largeTitle: Text("Disclaimer",style: TextStyle(color: Theme.of(context).textTheme.title.color),textAlign: TextAlign.center,),
      heroTag: "Disclaimer",
      backgroundColor: Colors.transparent,

    );
  }
  Widget body()
  {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical: 16.0),
      child: Text("Hey there. Bungee is an app that is created just for developer's purpose.I do not own any music resource.If you are owner of song you can email me at singhbhavneetdeveloper@gmail.com, just dont report app on play store please!! 😊."
          "Do not misuse it.Bungee do not support any illegal downloads or sharing.If you find any issue or think that an important feature is missing then you can go to Github page.Bungee will never share your playlist or any important data with others."
          "Thank You",
                  style: Theme.of(context).textTheme.headline.copyWith(fontWeight: FontWeight.normal),
                  ),
    );
  }
  Widget createButton(String title,String url,String image)
  {
    return Column(
      children: <Widget>[
        RaisedButton(color: Colors.white,onPressed: () {SoundWaveState.launchURL(url);},child: CircleAvatar(backgroundImage: NetworkImage(image),radius: 28.0,backgroundColor: Colors.white,),shape: CircleBorder(),),
        Padding(
          padding: const EdgeInsets.only(top:8.0),
          child: Text(title,style: Theme.of(context).textTheme.title.copyWith(fontSize: 14.0),),
        )
      ],
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}
