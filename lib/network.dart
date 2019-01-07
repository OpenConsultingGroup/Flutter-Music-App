import 'package:soundwave/music/song.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Network{
  static final String baseUrl="http://sample-music.herokuapp.com/";
  static final String searchUrl=baseUrl+"search/";
  static Future getHome()async{
     var response=await http.get(baseUrl);
     var data= jsonParse(response.body);

     return data;
  }
  static Map<String,List> jsonParse(body)
  {
    Map<String,List>items=Map<String,List>();
    Map<dynamic,dynamic>map=json.decode(body);
    map.forEach((key,value){
      String title=key;
      print(title);
      items.putIfAbsent(title,()=>[]);
      value.forEach((jsonItem){
        String type=jsonItem["type"];
        var item;
        try{
          if(type=="song")
          {
            item=Song.fromJson(jsonItem);
          }
          else if(type=="album")
          {
            item=Album.fromJson(jsonItem);
          }
          else if(type=="genre")
          {
            item=Genre.fromJson(jsonItem);
          }
          else if(type=="artist")
          {
            item=Artist.fromJson(jsonItem);
          }
        }
        catch(e)
        {
          print(e);
        }
        if(item!=null)
        {
          items[title].add(item);
        }
      });
    });

    return items;
  }
  static List<Details> getList(value)
  {
    List<Details> items=[];
    value.forEach((jsonItem){
      print(jsonItem);
      String type=jsonItem["type"];
      var item;
      if(type=="song")
      {
        item=Song.fromJson(jsonItem);
      }
      else if(type=="artist")
      {
        item=Artist.fromJson(jsonItem);
      }
      else if(type=="album")
      {
        item=Album.fromJson(jsonItem);
        print(item.title);
      }
      else if(type=="genre")
      {
        item=Genre.fromJson(jsonItem);
      }
      if(item!=null)
      {
        items.add(item);
      }
    });
    print("${items.length}");
    return items;
  }
  static Future searchTag(String tag,{int page=1}) async{
    var response = await http.get(searchUrl+"$tag"+"/"+"$page");

    return jsonParse(response.body);
  }
  static Future getItems(String url,{int page=1}) async{
    var response = await http.get(baseUrl+"items?url=$url&page=$page");
    return getList(jsonDecode(response.body));
  }
  static String  detailsUrl=baseUrl+"details?link=";
  static Future getDetails(url) async{
    var response = await http.get("$detailsUrl$url");
    var value=json.decode(response.body);
    var item;
    Map<String,dynamic> result={};

    if(value["details"]!=null)
      {
        item=Details.fromJson(Map<String,dynamic>.from(value["details"]));
        result["details"]=(item);
      }

   if(value["songs"]!=null)
     {
       item=List<Song>.from(value["songs"].map((item)=>(Song.fromJson(item))).toList());
       result["songs"]=item;
     }
   if(value["artists"]!=null)
     {
     var list=List<Artist>.from(value["artists"].map((item)=>(Artist.fromJson(item))).toList());
     result["artists"]=list;
     }
    if(value["albums"]!=null)
    {
    var list=List<Details>.from(value["albums"].map((item)=>(Details.fromJson(item))).toList());
    result["albums"]=list;
    }
   return result;
  }

}