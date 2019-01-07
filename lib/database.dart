import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:io';

import 'package:soundwave/music/song.dart';
import 'package:device_info/device_info.dart';

class DatabaseInterface{
  static String favourites="favourites",link="link",title="title",subtitle="artist",thumbnail="thumbnail",recentSearches="recentSearches";
  static FirebaseApp firebaseApp;
  static String uniqueId="unknown";
  static String url="url";
  static DatabaseReference reference;
   DatabaseInterface()
   {
     reference=FirebaseDatabase.instance.reference().child("userData").child(toPath(uniqueId));
     if(uniqueId=="unknown")
     getUniqueId().then((id){
       uniqueId=id;
       reference=FirebaseDatabase.instance.reference().child("userData").child(toPath(uniqueId));
     });

   }
  Future<void>open() async {
/*

    firebaseApp = await FirebaseApp.configure(
      name: favourites,
      options:  const FirebaseOptions(
        clientID: "784157732504-upears5ba27c7r3qbmq7qhc6hkdm2jjl.apps.googleusercontent.com",
        projectID: "funkmusic-4387d",
        storageBucket: "funkmusic-4387d.appspot.com",
        googleAppID: '1:784157732504:android:4a02b034b542eb23',
        apiKey: 'AIzaSyD-UXbBbmxC89KDXHmg7LGfiQUooHv2bgE',
        databaseURL: 'https://funkmusic-4387d.firebaseio.com',
      ),
    );
    FirebaseDatabase firebaseDatabase=FirebaseDatabase(app:firebaseApp);

    firebaseDatabase.setPersistenceEnabled(true);
*/

  }
  static String toPath(String name)
  {
  [".","\$","[","]","#","/"].forEach((pattern){
  name=name.replaceAllMapped(pattern, (match)=>"");
  });
  return name.split(" ").join("").toLowerCase();
  }
  static Future<String> getUniqueId() async {
      String deviceName;
      String deviceVersion;
      String identifier;
      final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
      try {
          if (Platform.isAndroid) {
          var build = await deviceInfoPlugin.androidInfo;
          deviceName = build.model;
          identifier=build.androidId;
          } else if (Platform.isIOS) {
          var data = await deviceInfoPlugin.iosInfo;
          deviceName = data.name;
          identifier = data.identifierForVendor;//UUID for iOS
          }
      }
      catch(e){
            print('Failed to get platform version');
      }

    return [deviceName,  identifier].join("");
  }
  Future<List<Details>> getPlaylists()async{
    var result= await reference.child("collections").once();
    List<Details> body=[];
    try{
        result.value.forEach((key,val){
        var item=Details.fromJson(val);
        body.add(item);
    });
    }
    catch(e){
      print(e);
  }
    return body;
  }
  Future<List> getSongs(String playlistName)async{
      var result= await reference.child(toPath(playlistName)).orderByPriority().once();
      List<Details> body=[];
      try{
      result.value.forEach((key,val){
      var item;
      if(val["links"]!=null)
        item=Song.fromJson(val);
      else if(val["songs"]!=null)
        item=Album.fromJson(val);
      if(item!=null)
      body.add(item);
      });
      }
      catch(e){
      print(e);
      }
      return body;
  }

  Future addFavourite(Details song)
  {
    return addToPlaylist([song],favourites);
  }
  String createUrl(String playlist)
  {
    return ["userData",toPath(uniqueId),toPath(playlist)].join("/");
  }
  Future createPlaylist(String playlist)
  {
    Details details=Details(title: playlist,thumbnail: "https://a10.gaanacdn.com/images/artists/63/1248963/crop_175x175_1248963.jpg",artists: ["0 Songs"],type: "album",url:createUrl(playlist));
    return reference.child("collections").child(toPath(playlist)).set(details.toMap());
  }
  Future<DataSnapshot> isFavourite(Details song){
    return reference.child(favourites).child(toPath(song.title)).once();
  }


  Future removeFavourite(Details song)
  {
    return removeFromPlaylist(song,favourites);
  }
  Future addRecentlyPlayed(Details songs)
  {
    return addToPlaylist([songs],"Recently Played");
  }
  Future addToPlaylist(List<Details> songs,String playlistName)
  {
    Map<String,String>map=Map();
    map.putIfAbsent("title", ()=>playlistName[0].toUpperCase()+playlistName.substring(1));
    map.putIfAbsent("thumbnail", ()=>songs.length==0?"":songs[0].thumbnail);
    map.putIfAbsent("type", ()=>"album");
    map.putIfAbsent("url", ()=>createUrl(playlistName));
    songs.forEach((song){

    reference.child(toPath(playlistName)).child(toPath(song.title)).set(song.toMap(),priority: -DateTime.now().millisecond);
    });
   return reference.child("collections").child(toPath(playlistName)).set(map);
  }
  Future<DataSnapshot> isPublic(Details details) {
       return FirebaseDatabase.instance.reference().child("public").child(toPath(uniqueId+details.title)).once();
  }
  Future makePublicPlaylist(Details details,bool public)
  {
    if(public)
    return FirebaseDatabase.instance.reference().child("public").child(toPath(uniqueId+details.title)).set(details.toMap());
    else
    {
    return FirebaseDatabase.instance.reference().child("public").child(toPath(uniqueId+details.title)).set(null);
    }
  }

  Future removeFromPlaylist(Details song,String playlistName)
  {
  return reference.child(toPath(playlistName)).child(toPath(song.title)).set(null);
  }

  Future deletePlaylist(playlistName) {
    makePublicPlaylist(Details(title:playlistName), false);
    reference.child(toPath(playlistName)).set(null);
    return reference.child("collections").child(toPath(playlistName)).set(null);

  }
  //Search
  Future addRecentSearch(dynamic data)
  {
    return reference.child(recentSearches).child(toPath(data.title)).set(data.toMap(),priority: -DateTime.now().millisecond);
  }
  Future getRecentSearches(){
    var result=  reference.child(recentSearches).orderByPriority().once();
    return result;
  }

  Future deleteRecentSearch(data) {
    return reference.child(recentSearches).child(toPath(data.title)).set(null);
  }

  Future clearRecentSearches() {
      return reference.child(recentSearches).set(null);
  }

  void clearData() {
    reference.set(null);
  }


}