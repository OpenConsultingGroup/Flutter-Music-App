import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/database.dart';

class CreditsScreen extends StatefulWidget{
  const CreditsScreen({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>CreditsScreenState();

}
class CreditsScreenState extends State<CreditsScreen>{
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
      largeTitle: Text("Credits",style: TextStyle(color: Theme.of(context).textTheme.title.color),textAlign: TextAlign.center,),
      heroTag: "Credits",
      backgroundColor: Colors.transparent,

    );
  }
  Widget body()
  {
    return ListView(
      children: <Widget>[
        createTile("Flutter", "https://flutter.io/", "https://www.codemate.com/wp-content/uploads/2017/09/flutter-logo.png","Front-end development"),
        createTile("Node js", "https://nodejs.org", "https://seeklogo.com/images/N/nodejs-logo-FBE122E377-seeklogo.com.png","Back-end development"),
        createTile("Firebase", "https://firebase.google.com/", "https://cdn-images-1.medium.com/max/1200/1*R4c8lHBHuH5qyqOtZb3h-w.png","Database Storage"),
        createTile("Erick Ghaumez ", "https://github.com/rxlabz", "https://avatars3.githubusercontent.com/u/1397248?s=88&v=4","Audio Player"),
        createTile("Google Developers", "https://www.youtube.com/user/GoogleDevelopers", "https://cdn-9789.kxcdn.com/wp-content/uploads/2012/09/faster-css-html-with-chrome-dev-tools.png","For teaching"),
      ],
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
    );
  }
  Widget createTile(String title,String url,String image,String role)
  {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(title),
          subtitle: Text(role),
          leading: CircleAvatar(backgroundImage: NetworkImage(image),),
          trailing: Icon(Icons.chevron_right),
            onTap: (){
            SoundWaveState.launchURL(url);
          },
        )
      ],
    );
  }
  @override
  void dispose() {
    super.dispose();
  }
}
