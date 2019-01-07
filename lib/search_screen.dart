import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:soundwave/database.dart';
import 'package:soundwave/item_builder.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/network.dart';
import 'package:soundwave/shuffle_screen.dart';
import 'package:http/http.dart' as http;

import 'dart:ui' show ImageFilter;


class SearchScreen extends StatefulWidget {
  SearchScreen({Key key, this.title,this.callback}) : super(key: key);
  final dynamic callback;
  final String title;

  @override
  _SearchScreenState createState() => new _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin<SearchScreen>{

  String title;
  TextEditingController _textController;
  bool start=true;
  AnimationController _animationController;
  Animation fadeAnimation;
  ItemBuilder _itemBuilder;
  int currentPage=1;
  List songs=[];
  List artists=[];
  @override
  void initState() {
    super.initState();
    title="Home";
    _itemBuilder=ItemBuilder(context);
    _textController = TextEditingController();
    focusNode=FocusNode();
    /*In no focus mode*/
    _textController.addListener((){
      searchKey=_textController.text;
    });
    _animationController=AnimationController(vsync: this,duration:Duration(seconds: 1));
    fadeAnimation=Tween(begin: 0.0,end:1.0).animate(_animationController);
    body=recentSearches();
  }
  int currentIndex=0;
  Color backgroundColor=Colors.transparent;
  TextAlign textAlign=TextAlign.center;
  Color textBackgroundColor= Color(0xfffbe2f0);
  Widget trailing=Container(width: 0.0,height: 0.0,);
  Widget leading;
  FocusNode focusNode;
  bool expanded=false;
  String searchKey="";
  List stack=[];
  Widget body;
  @override
  Widget build(BuildContext context) {
    _animationController.forward(from: 0.0);

    return Scaffold(
      appBar: createAppBar(),
      body: body,
    );
  }
  AppBar createAppBar()
  {
    return AppBar(
      automaticallyImplyLeading: true,
      iconTheme: Theme.of(context).iconTheme,
      elevation: 0.0,
      centerTitle: true,
      brightness: Brightness.dark,
      backgroundColor: Colors.transparent,
      leading: CupertinoButton(
        child: Icon(CupertinoIcons.left_chevron,color:  Theme.of(context).iconTheme.color,size: 28.0,),
        minSize: 0.0,
        padding: EdgeInsets.zero,
        onPressed: (){
          Navigator.maybePop(context);
        },),
        title: Padding(
        padding: const EdgeInsets.symmetric(vertical:8.0),
        child: CupertinoTextField(
          placeholder: "Search - Prada Jass",
          controller: _textController,
          textCapitalization: TextCapitalization.words,
          decoration: BoxDecoration(color: Theme.of(context).secondaryHeaderColor,borderRadius: BorderRadius.circular(8.0 )),
          cursorColor: Theme.of(context).accentColor,
          textAlign: TextAlign.start,
          maxLines: 1,
          prefix: Padding(
            padding: const EdgeInsets.only(left:16.0),
            child: ImageIcon(AssetImage("images/search.png"),color:  Colors.white54,size: 18.0,),
          ),
          prefixMode: OverlayVisibilityMode.always,
          suffix: CupertinoButton(child: Text("Cancel",style: Theme.of(context).textTheme.title.copyWith(color:  Theme.of(context).primaryColorLight),), onPressed: (){clearSearch();},padding: const EdgeInsets.symmetric(horizontal:8.0),minSize: 0.0,),
            suffixMode: OverlayVisibilityMode.editing,
            padding: EdgeInsets.all(12.0),
          style: Theme.of(context).textTheme.title.copyWith(decoration: TextDecoration.none),
            focusNode: focusNode,
            onSubmitted:(String key)
              {

                if(key.length>0)
                setState(() {
                  currentPage=0;
                  songs.clear();
                  artists.clear();
                  body=search(key);
                });
              },
        ),
      ),
    );
  }

  Widget notFound()
  {
     return SingleChildScrollView(
       child: Column(
         children: <Widget>[
           Text("Nothing to see here",style: Theme.of(context).textTheme.headline.copyWith(fontStyle: FontStyle.normal)),
           Padding(
             padding: const EdgeInsets.only(top:8.0),
             child: Text('404 Page Not Found',style: Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.normal),),
           ),
           Padding(
             padding: const EdgeInsets.only(top:8.0),
             child: RaisedButton(elevation:1.5,child: Text("Go Home",style: Theme.of(context).textTheme.title.copyWith(color: Colors.white,fontWeight: FontWeight.normal),),color: Colors.redAccent,onPressed: () {Navigator.of(context).maybePop();},),
           )
         ],
       ),
     );
  }
  Widget createDefaultBody()
  {
    return Center(child: Text("Search Here"),);
  }
  void clearSearch()
  {
    _textController.text='';
    setState(() {
      body=recentSearches();
    });
  }

  final DatabaseInterface databaseInterface=DatabaseInterface();
  List items=[];
  GlobalKey<AnimatedListState>key=GlobalKey<AnimatedListState>();
  Widget recentSearches()
  {
    return FutureBuilder(
      future: databaseInterface.getRecentSearches(),
      builder: (context,snapshot){
        if(snapshot.connectionState==ConnectionState.waiting)
          {
            return Center(child: CircularProgressIndicator());
          }

        Map<dynamic, dynamic> map = snapshot.data.value;

        if(map==null)
        {
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Recent Searches",style: Theme.of(context).textTheme.headline,textAlign: TextAlign.center,),
                ),
                ListTile(
                  title: Text("Its pretty quit in here",style: Theme.of(context).textTheme.title),
                  subtitle: Text("You haven't searched for anything yet",style: Theme.of(context).textTheme.subtitle,),
                  trailing: FlatButton(onPressed: (){Navigator.of(context).maybePop();}, child: Text("Home",style: TextStyle(color:  Theme.of(context).primaryColor,fontWeight: FontWeight.bold),),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0),),color:  Theme.of(context).primaryColorLight,padding: EdgeInsets.symmetric(vertical: 4.0,horizontal: 4.0),),
                ),
              ],
            ),
          );
        }
        items.clear();
        items.addAll(map.values.toList().map((item){
           return Details.fromJson(item);
        }).toList());

         return AnimatedList(
           key: key,
             itemBuilder: (context,index,animation){
           if(index==0)
             {
               return Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: Text("Recent Searches",style: Theme.of(context).textTheme.headline,textAlign: TextAlign.center,),
               );
             }
          return _itemBuilder.buildSearchItem(items[index-1],trailing: IconButton(icon: Icon(Icons.clear,),color:  Theme.of(context).primaryColorLight, onPressed: (){
            databaseInterface.deleteRecentSearch(items[index-1]);
            var i=items[index-1];
            items.removeAt(index-1);

            key.currentState.removeItem(index, (context,animation){
              return SizeTransition(
                  sizeFactor: animation,
                  child:_itemBuilder.buildSearchItem(i)
              );
            });
          }));
        },
          initialItemCount:items.length+1,
          shrinkWrap: true,
        );
      },
    );
  }
  Widget search(String key)
  {
     return FutureBuilder(
       future: Network.searchTag(key,),
         builder: (BuildContext context, AsyncSnapshot snapshot) {
           if(snapshot.connectionState==ConnectionState.waiting)
             {
               return Center(child: CircularProgressIndicator());
             }
           else if(snapshot.hasData)
             {
               Map<String,dynamic> items=snapshot.data;
               if(items["Songs"].length==0&&items["Artists"].length==0)
                 {
                   return Center(child: notFound(),);
                 }
              List widgets=[];
              items.forEach((type,list){
                widgets.add(createList(type, list));
              });
              return ListView.builder(itemBuilder: (context,index){
                return widgets[index];
              },
                shrinkWrap: true,
                itemCount: widgets.length,
                physics: BouncingScrollPhysics(),
              );
              }
             else if(snapshot.hasError)
               {
                 return Center(child: Text("Sorry something wrong happened."));
               }
         },
     );
  }
  Widget createList(String type,List items)
  {
    if(items.length==0)
      {
        return Container(width:0.0,height: 0.0,);
      }
    if(items.length>6)
    {
      items=items.take(6).toList();
    }
    Widget list= ListView.builder(itemBuilder: (context,index){
      return _itemBuilder.buildSearchItem(items[index]);
    },
      shrinkWrap: true,
      itemCount: items.length,
      physics: ClampingScrollPhysics(),
    );
    Widget widget=Column(

      children: <Widget>[
        createSubtitle(type),
        list,
      ],
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
    );
    return widget;

  }
  Widget createSubtitle(String title)
  {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical:4.0,horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(title,style: Theme.of(context).textTheme.headline,textAlign: TextAlign.center,),
          ),
          createMoreButton(title,_textController.text)
        ],
      ),
    );
  }
  Widget createMoreButton(String type,String key)
  {
    return CupertinoButton(
        minSize: 0.0,
        padding: const EdgeInsets.all(12.0),
        child: Text("View all",style: Theme.of(context).textTheme.subtitle,),
        onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MoreScreen(key,type)));
        },
    );
  }
  dispose()
  {
    _animationController.dispose();
    super.dispose();
  }


}
class MoreScreen extends StatefulWidget{
  final String searchKey,type;

  const MoreScreen(this.searchKey, this.type,{Key key, }) : super(key: key);
  @override
  State<StatefulWidget> createState() =>_MoreScreenState();

}
class _MoreScreenState extends State<MoreScreen> {
  List items =[];
  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false;
  int currentPage=0;
  ItemBuilder itemBuilder;
  @override
  void initState() {
    super.initState();
    itemBuilder=ItemBuilder(context);
    _getMoreData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _getMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  _getMoreData()  {
    if (!isPerformingRequest) {
      setState(() => isPerformingRequest = true);
      Network.searchTag(widget.searchKey,page: currentPage+1).then((data){
        setState(() {
          isPerformingRequest=false;
        });
        Map<String,dynamic> map=data;
        print(map);
        if(map[widget.type].length==0)
        {
          return ;
        }
        currentPage++;
        List temp=map[widget.type];

        setState(() {
         temp.forEach((data){
           if(!items.contains(data))
             {
               items.add(data);
             }
         });
        });
      });
    }
  }
  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          createAppbar(),
          SliverList(delegate:SliverChildBuilderDelegate((context,index){
            if(index==items.length)
              {
                return _buildProgressIndicator();
              }
            return itemBuilder.buildSearchItem(items[index]);
          },childCount: items.length+1), )
        ],
      ),
    );
  }
  CupertinoSliverNavigationBar createAppbar()
  {
    return CupertinoSliverNavigationBar(
        leading: CupertinoButton(
          child: Icon(CupertinoIcons.left_chevron,color:  Theme.of(context).iconTheme.color),
          minSize: 0.0,
          padding: EdgeInsets.zero,
          onPressed: (){
             Navigator.of(context).maybePop();
          },),
        largeTitle: Text(widget.type,style: TextStyle(color: Theme.of(context).textTheme.title.color),textAlign: TextAlign.center,),
        heroTag: DateTime.now().toString(),
        backgroundColor: Colors.transparent,

    );
  }


}