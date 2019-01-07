import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/widgets/menu_button.dart';
import 'package:soundwave/database.dart';
import 'package:soundwave/widgets/favourite_button.dart';
import 'dart:convert';

  class Details{
    String title="",album="",thumbnail="";
    List<String>artists=[];
    String released="",label="";
    String url="",type="artist";

    static var placeholders={"song":"images/music_placeholder.png","album":"images/album_placeholder.png","artist":"images/artist_placeholder.png",};
    String get artist =>artists!=null?artists.join(" , "):"Singer";
    static List<String>keys=["title","artists","links","duration","thumbnail","label","url"];
    static List values=["",[],[],"","","",""];

    Details({this.title="", this.album="", this.thumbnail="",this.artists,this.type, this.released, this.label, this.url});
    factory Details.fromJson(var json)
    {
      for(int i=0;i<keys.length;i++)
      {
        String key=keys[i];
        if(json[key]==null)
        {
          json[key]=values[i];
        }
      }
      Details details=Details(
          title:json['title'],
          artists: List<String>.from(json["artists"]),
          thumbnail: json["thumbnail"],
          type:json["type"],
          released:json["released"],
          label:json["label"],
          url:json["url"],
          );
      return details;
    }
    Map<String, dynamic> toMap() {
      var map = <String, dynamic>{
        "title": title,
        "artists": type!="artist"?artists:[type[0].toUpperCase()+type.substring(1)],
        "url": url,
        "thumbnail": thumbnail,
        "type":type,
        "released":released,
        "label":label
      };
      return map;
    }

    @override
    String toString() {
       return this.title+this.artist;
    }

    Widget buildWidget(BuildContext context,Function callback)
    {
      double size=175.0;
      return CupertinoButton(
        minSize: 0.0,
        padding: EdgeInsets.all(0.0),
        onPressed:callback,
        child: Container(
          padding: EdgeInsets.fromLTRB(12.0,10.0,12.0,10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(1.0),
                    child: Image(image: NetworkImage(this.thumbnail),width: size,height: size,fit: BoxFit.fill,),
                  ),
                ],
              ),
              Container(
                width: size,
                padding: const EdgeInsets.fromLTRB(4.0,12.0,0.0,0.0),
                child: Text(this.title,style:Theme.of(context).textTheme.title,maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
              ),
              Container(
                width: size,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4.0,4.0,0.0,0.0),
                  child: Text(this.artists.join(" , "),style: Theme.of(context).textTheme.subtitle,maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
                ),
              )
            ],
          ),
        ),
      );
    }

    Widget buildItemWidget(BuildContext context,Function callback,)
    {
      return CupertinoButton(
        onPressed: () {callback();},
        minSize: 0.0,
        padding: EdgeInsets.symmetric(vertical:8.0,horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius:type=="artist"?BorderRadius.circular(40.0):BorderRadius.circular(4.0),
              child: FadeInImage.assetNetwork(image: this.thumbnail,width:70.0,height: 70.0,fit: BoxFit.fill, placeholder: "images/music_placeholder.png",),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left:16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(this.title,style: Theme.of(context).textTheme.title,maxLines: 1,overflow: TextOverflow.ellipsis,),
                    Padding(
                      padding: const EdgeInsets.only(top:4.0),
                      child: Text(type=="song"?this.artist:type[0].toUpperCase()+type.substring(1),style: Theme.of(context).textTheme.subtitle,maxLines: 1,overflow: TextOverflow.ellipsis,),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                MenuButton(this,icon: Icon(Icons.more_horiz,color: Theme.of(context).iconTheme.color,),)
              ],
            ),
          ],
        ),
      );
    }
    Widget buildGridItem(BuildContext context,Function callback)
    {
      IconData logo;
      if(type == "song")
        {
          logo=Icons.play_circle_outline;
        }
      else if(type == "artist")
      {
        logo=Icons.mic_none;
      }
      else
      {
        logo=Icons.photo_library;
      }
      double size=MediaQuery.of(context).size.width/2.2;
      return CupertinoButton(
        onPressed:(){
        callback();
        },
        padding: EdgeInsets.all(0.0),
        minSize: 0.0,
        child: Container(
          margin: EdgeInsets.symmetric(vertical:12.0,horizontal: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(color:Color(0xfffeee6ff),borderRadius:type=="artist"?BorderRadius.circular(125.0):BorderRadius.circular(8.0)),
                    child: ClipRRect(
                      borderRadius:type=="artist"?BorderRadius.circular(125.0):BorderRadius.circular(8.0),
                      child: FadeInImage.assetNetwork(placeholder:"images/music_placeholder.png", image: thumbnail,width: size,height: size,fit: BoxFit.fill,),),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(logo,color: type=="artist"?Colors.transparent:Colors.white,),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top:8.0),
                child: Text(title,style:Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,),
              ),
            ],
          ),
        ),
      );
    }
    Widget buildCollectionsWidget(BuildContext context,Function callback,Function notInterested,{bool showNotInterested=true})
    {
      return CupertinoButton(
        onPressed: callback,
        padding: EdgeInsets.all(0.0),
        minSize: 0.0,
        child: Container(
          margin: EdgeInsets.symmetric(vertical:12.0,horizontal: 12.0),
          child: Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.pinkAccent.shade100,borderRadius: BorderRadius.circular(5.0)),
                child: ClipRRect(
                  borderRadius:BorderRadius.circular(5.0),
                  child: FadeInImage.assetNetwork(placeholder: "images/music_placeholder.png", image: this.thumbnail,width: 70.0,height: 70.0,fit: BoxFit.fill,),),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(this.title,style: Theme.of(context).textTheme.title,maxLines: 1,overflow: TextOverflow.ellipsis,),
                      Padding(
                        padding: const EdgeInsets.only(top:4.0),
                        child: Text(this.artists.join(" - "),style: Theme.of(context).textTheme.subtitle,maxLines: 1,overflow: TextOverflow.ellipsis,),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    IconButton(icon:Icon(Icons.delete),onPressed: (){notInterested();},color:   Theme.of(context).iconTheme.color,),
                    MenuButton(this,color: Theme.of(context).iconTheme.color,)
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget buildRecentWidget(BuildContext context,Function callback)
    {
      double size=135.0;
      return CupertinoButton(
        minSize: 0.0,
        padding: EdgeInsets.all(0.0),
        onPressed:callback,
        child: Container(
          padding: EdgeInsets.fromLTRB(8.0,8.0,8.0,8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: Image(image: NetworkImage(this.thumbnail),width: size,height: size,fit: BoxFit.fill,),
              ),
              Container(
                width: size,
                padding: const EdgeInsets.fromLTRB(0.0,12.0,0.0,0.0),
                child: Text(this.title,style:Theme.of(context).textTheme.title,maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
              ),
            ],
          ),
        ),
      );
    }
    static List<Color>colors=[Color(0xff333333),Color(0xffFDC830,),Color(0xffff7e5f),Color(0xff2657eb),Color(0xfff80759),Color(0xffef8e38),Color(0xffFF4B2B)];
    Widget buildTrendingWidget(BuildContext context,Function callback,int index)
    {
      double size=135.0;
      return CupertinoButton(
        minSize: 0.0,
        padding: EdgeInsets.all(0.0),
        onPressed:(){callback();},
        child: Container(
          padding: EdgeInsets.fromLTRB(10.0,8.0,10.0,8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(width: size*1.3,height: size*1.3,decoration: BoxDecoration(color: colors[index%colors.length],borderRadius: BorderRadius.circular(5.0)),),
                  Container(
                    decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black54)]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2.0),
                      child: Image(image: NetworkImage(this.thumbnail),width: size,height: size,fit: BoxFit.fill,),
                    ),
                  ),
                ],
              ),
              Container(
                width: size,
                padding: const EdgeInsets.fromLTRB(0.0,12.0,0.0,0.0),
                child: Text(this.title,style:Theme.of(context).textTheme.title,maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
              ),
              Container(
                width: size,
                padding: const EdgeInsets.fromLTRB(0.0,4.0,0.0,0.0),
                child: Text(this.artists.join(" , "),style: Theme.of(context).textTheme.subtitle,maxLines: 1,overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,),
              )
            ],
          ),
        ),
      );
    }
  }
  class Song extends Details{
    String title,album,thumbnail,duration;
    List<String>artists=[];
    String released,label;
    List<String>links;
    String url;
    String type="song";
    Song({this.title="", this.album="", this.thumbnail="", this.duration="", this.artists,this.type, this.released, this.label, this.links,this.url});
    String get link  =>links.length>1?links[1]:(links.length==1?links[0]:"");
    String get artist =>artists.join(" , ");
    @override
    bool operator ==(other) {
      return toString()==other.toString();
    }

    @override
    int get hashCode {
      return title.length;
    }

    @override
    String toString() {
      String key="";
      if(title!=null)
        {
          key+=title;
        }
      if(artists.length!=0)
        {
          key+=artist;
        }
      return key;
    }

    Widget buildPlaylistWidget(BuildContext context,Function callback,Function notInterested,{bool active=false,playing=false})
    {
      return CupertinoButton(
        onPressed: callback,
        padding: EdgeInsets.all(0.0),
        minSize: 0.0,
        child: Container(
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0),color: Color(0xff715458).withOpacity(0.4)),
          child: Row(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.cyanAccent.shade100,borderRadius:BorderRadius.only(topLeft: Radius.circular(8.0),bottomLeft: Radius.circular(8.0))),
                child: ClipRRect(borderRadius:BorderRadius.only(topLeft: Radius.circular(8.0),bottomLeft: Radius.circular(8.0)),
                  child: Container(foregroundDecoration:BoxDecoration(color: active?Colors.red.withOpacity(0.2):Colors.black26),child: FadeInImage.assetNetwork(placeholder: "images/music_placeholder.png", image: this.thumbnail,width: 75.0,height: 75.0,fit: BoxFit.fill,)),),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(this.title,style: TextStyle(color: active?Colors.red:Theme.of(context).textTheme.title.color,fontSize: 16.0,fontWeight: FontWeight.w600),maxLines: 1,overflow: TextOverflow.ellipsis,),
                      Padding(
                        padding: const EdgeInsets.only(top:4.0),
                        child: Text(this.artist,style: TextStyle(color: active?Colors.red.withOpacity(0.5):Theme.of(context).textTheme.subtitle.color,fontSize: 14.0),maxLines: 1,overflow: TextOverflow.ellipsis,),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  (IconButton(icon: Icon(Icons.delete,size: 24.0,color: Theme.of(context).iconTheme.color,), onPressed: notInterested)),
                  Padding(
                    padding: const EdgeInsets.only(right:8.0),
                    child: MenuButton(this,),
                  )
                ],
              ),
            ],
          ),
        ),
      );
    }



    Widget buildPlayCoverWidget(BuildContext context,Function callback) {
      double size=MediaQuery.of(context).size.width*2.5/5;
      return Hero(
        tag: this.toString(),
        child: Padding(
          padding:  EdgeInsets.symmetric(vertical:24.0,horizontal: 24.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: FadeInImage.assetNetwork(placeholder:"images/music_placeholder.png",image: this.thumbnail,fit: BoxFit.fill,),
          ),
        ),
      );
    }
    Widget buildRecentlyPlayedWidget(BuildContext context,Function callback)
    {
      double size=150.0;
      return CupertinoButton(
        onPressed: callback,
        padding: EdgeInsets.all(0.0),
        minSize: 0.0,
        child: Container(
          padding: EdgeInsets.fromLTRB(8.0,10.0,8.0,10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: FadeInImage.assetNetwork(image: this.thumbnail,width: size*1.5,height: size,fit: BoxFit.fill, placeholder: "images/music_placeholder.png",),
              ),
              Padding(
                padding: const EdgeInsets.only(top:8.0),
                child: Text(this.title,style:Theme.of(context).textTheme.display1,maxLines: 1,overflow: TextOverflow.ellipsis,),
              ),

            ],
          ),
        ),
      );
    }



    static List<Song> randomList()
    {
      return [
      ];
    }
  static List<String>keys=["title","artists","links","duration","thumbnail","label","url"];
    static List values=["",[],[],"","","",""];
  factory Song.fromMap( json) {
    for(int i=0;i<keys.length;i++)
      {
        String key=keys[i];
        if(json[key]==null)
        {
          json[key]=values[i];
        }
      }
    return Song(
    title:json['title'],
    artists: List<String>.from(json["artists"]),
    duration:json["duration"],
    thumbnail: json["thumbnail"],
    type:json["type"],
    released:json["released"],
    label:json["label"],
    url:json["url"],
    links: json['links'],
    );
  }
   Map<String, dynamic> toMap() {
     Map<String, dynamic> map = super.toMap();
      map["links"]=links;
      return map;
    }
  factory Song.fromJson(json) {
    for(int i=0;i<keys.length;i++)
    {
      String key=keys[i];
      if(json[key]==null)
      {
        json[key]=values[i];
      }
    }
      Song song=Song(
       title:json['title'],
       artists: List<String>.from(json["artists"]),
       duration:json["duration"],
       thumbnail: json["thumbnail"],
       type:json["type"],
       released:json["released"],
       label:json["label"],
       url:json["url"],
       links: List<String>.from(json['links']),
     );

      return song;
  }


  }
class Album extends Details{
    final List<Song>songs;
    int _active=0;
    String type="album";
    bool _playing=false;
    final String thumbnail;
    final String title;
    final List<String> artists;
    String url;
    Album({this.songs, this.title="", this.artists, this.thumbnail="", duration, label, type, released,this.url});
    static List<String>keys=["title","artists","duration","thumbnail","label","url"];
    static List values=["",[],"","","",""];

      String get artist {return artists.join(" , ");}
     //Interface
      operator[](int index){
        return songs[index];
      }
    factory Album.fromJson(var jsonData) {
      for(int i=0;i<keys.length;i++)
      {
        String key=keys[i];
        if(jsonData[key]==null)
        {
          jsonData[key]=values[i];
        }
      }
      List<Song>songs=[];
      try{
        Map<dynamic,dynamic> map=jsonData["songs"];
        map.forEach((key,value){
          songs.add(Song.fromJson(value));
        });
      }
      catch(e){

      }
      print(songs.length);
      return Album(
       title:jsonData['title'],
       artists: List<String>.from(jsonData["artists"]),
       duration:jsonData["duration"],
       thumbnail: jsonData["thumbnail"],
       type:jsonData["type"],
       released:jsonData["released"],
       label:jsonData["label"],
       url:jsonData["url"],
       songs:songs,
    );
  }
    Map<String,dynamic> toMap()
    {
      Map<String,dynamic>map=super.toMap();
      map["songs"]={};
      songs.forEach((item){
        map["songs"][DatabaseInterface.toPath(item.title)]=item.toMap();
      });
      return map;
    }
    factory  Album.fromMap(json) {
      for(int i=0;i<keys.length;i++)
      {
        String key=keys[i];
        if(json[key]==null)
        {
          json[key]=values[i];
        }
      }

      return Album(
          title:json['title'],
          artists: List<String>.from(json["artists"]),
          duration:json["duration"],
          thumbnail: json["thumbnail"],
          type:json["type"],
          released:json["released"],
          label:json["label"],
          url:json["url"],
          songs: json["songs"],
      );
    }

    Widget buildCoverWidget(BuildContext context,) {
      double size=MediaQuery.of(context).size.width*3/5;
      double height=size;
      return Container(
        padding: EdgeInsets.fromLTRB(0.0,15.0,0.0,0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color: Colors.pinkAccent,borderRadius: type!="artist"?BorderRadius.circular(8.0):BorderRadius.circular(50.0)),
              child: ClipRRect(
                borderRadius:type!="artist"?BorderRadius.circular(8.0):BorderRadius.circular(50.0),
                child: FadeInImage.assetNetwork( placeholder: "images/music_placeholder.png",image: this.thumbnail,width: size,height: height,fit: BoxFit.fill,),
              ),
            ),
            Container(
              padding:  EdgeInsets.fromLTRB(0.0,8.0,0.0,0.0),
              child: ListTile(

                title: Text(
                  title.trimLeft(),
                  style:Theme.of(context).textTheme.headline.copyWith(fontStyle: FontStyle.normal),
                  textAlign: TextAlign.center,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top:4.0),
                  child: Text(
                    artist,
                    style:Theme.of(context).textTheme.subhead.copyWith(fontFamily: "GoogleSans",fontStyle: FontStyle.normal),
                    textAlign: TextAlign.center,
                  ),
                ),
                leading: FavouriteButton(this,size: 22.0,),
                trailing: IconButton(icon: Icon(Icons.share),color: Theme.of(context).iconTheme.color, onPressed: () {SoundWaveState.showBetaDialog(context);},),
              ),
            ),

          ],
        ),
      );
    }


    Widget buildPlaylistCover(BuildContext context,Function callback) {
    double size=MediaQuery.of(context).size.width*3/5;
    return SingleChildScrollView(
      child: CupertinoButton(
        onPressed: (){callback();},
        minSize: 0.0,
        padding: EdgeInsets.all(0.0),
        child: Container(
          padding: EdgeInsets.fromLTRB(10.0,15.0,10.0,15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Image(image: NetworkImage(this.thumbnail),width: size+10.0,height: size,fit: BoxFit.fill,),
              ),
              Container(
                width: MediaQuery.of(context).size.width*3/4,
                padding:  EdgeInsets.fromLTRB(0.0,16.0,0.0,0.0),
                child: Text(
                  artists.join(" - "),
                  style:Theme.of(context).textTheme.subhead.copyWith(fontSize:18.0 ,height: 1.2),
              textAlign: TextAlign.center),
              ),

            ],
          ),
        ),
      ),
    );
  }


}
class Artist extends Details{
     String title,thumbnail,url;
    String type="artist";

    Artist({this.title, this.url, this.thumbnail});
    Widget buildWidget(BuildContext context,Function callback)
    {
      double size=110.0;
      return CupertinoButton(
        minSize: 0.0,
        padding: EdgeInsets.all(0.0),
        onPressed:callback,
        child: Container(
          padding: EdgeInsets.fromLTRB(12.0,10.0,12.0,10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(size),
                child: Image(image: NetworkImage(this.thumbnail),width: size,height: size,fit: BoxFit.fill,),
              ),
              Padding(
                padding: const EdgeInsets.only(top:12.0),
                child: Text(this.title,style:Theme.of(context).textTheme.title,maxLines: 1,overflow: TextOverflow.ellipsis,),
              ),
            ],
          ),
        ),
      );
    }

   static Artist fromMap(map) {
    return Artist(title:map[DatabaseInterface.title],
     url:map[DatabaseInterface.subtitle],
     thumbnail:map[DatabaseInterface.thumbnail]) ;
  }

  factory Artist.fromJson(jsonData) {
    for(int i=0;i<Details.keys.length;i++)
    {
      String key=Details.keys[i];
      if(jsonData[key]==null)
      {
        jsonData[key]=Details.values[i];
      }
    }
    return Artist(
        title:jsonData['title'],
        thumbnail: jsonData["thumbnail"],
       url:jsonData["url"],
    );
  }

}
class Genre extends Details{
     String title;
     String thumbnail;
     String type="genre";
     String url;
     String label="",released="";
    Genre({this.title, this.thumbnail,this.url,  this.type});
    Widget buildWidget(BuildContext context,Function callback)
    {
      return CupertinoButton(
        onPressed: (){callback();},
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5.0),
          child: Stack(
              children:[
                FadeInImage.assetNetwork(placeholder: "images/music_placeholder.png", image: thumbnail,fit: BoxFit.fill,height: 100.0,)
              ],
            alignment: Alignment.center,
          ),
        ),
      );
    }
     factory Genre.fromJson(Map<String, dynamic> jsonData) {
       for(int i=0;i<Details.keys.length;i++)
       {
         String key=Details.keys[i];
         if(jsonData[key]==null)
         {
           jsonData[key]=Details.values[i];
         }
       }

       return Genre(
           title:jsonData["title"],
           thumbnail: jsonData["thumbnail"],
           url: jsonData["url"],
           type:"genre",

       );
    }


}