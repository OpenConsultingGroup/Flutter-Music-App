import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/database.dart';

class DeveloperScreen extends StatefulWidget{
  const DeveloperScreen({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>DeveloperScreenState();

}
class DeveloperScreenState extends State<DeveloperScreen>{
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
    );
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
        largeTitle: Text("Developer",style: TextStyle(color: Theme.of(context).textTheme.title.color),textAlign: TextAlign.center,),
        heroTag: "Developer",
        backgroundColor: Colors.transparent,

    );
  }
  Widget body()
  {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: CircleAvatar(radius: MediaQuery.of(context).size.width/4,backgroundImage: NetworkImage("https://avatars0.githubusercontent.com/u/31070108?s=460&v=4"),),
        ),
        ListTile(
          title: Text("Bhavneet Singh",style: Theme.of(context).textTheme.title,textAlign: TextAlign.center,),
          subtitle: Text("@singhbhavneet",style: Theme.of(context).textTheme.subtitle,textAlign: TextAlign.center,),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Hey there, I can be described as a commerce student who got bored of commerce and fell in love with coding.I love watching Netflix,sleeping and eating.I am done.Thank u for reading",),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Contact me",style: Theme.of(context).textTheme.headline,textAlign: TextAlign.center,),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            children: <Widget>[
              createButton("Github", "https://github.com/singhbhavneet", "https://image.flaticon.com/icons/png/128/25/25231.png"),
              createButton("Instagram", "https://www.instagram.com/bhavneet.46/", "http://pluspng.com/img-png/instagram-png-instagram-png-logo-1455.png"),
              createButton("Facebook", "https://www.facebook.com/bhavneet.singh.948011", "https://www.facebook.com/images/fb_icon_325x325.png"),
            ],
          ),
        )
      ],
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
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
