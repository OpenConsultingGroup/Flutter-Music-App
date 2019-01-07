import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/network.dart';
import 'package:soundwave/shuffle_screen.dart';
import 'package:soundwave/widgets/carousel.dart';
import 'package:soundwave/widgets/chromesearchbar.dart';
import 'package:soundwave/widgets/shadow_app_bar.dart';
import 'package:soundwave/widgets/more_button.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/music/heading.dart';

import 'dart:ui' show ImageFilter;


class ItemsScreen extends StatefulWidget {
  ItemsScreen(this.data,{Key key,this.callback}) : super(key: key);
  final dynamic callback;

  final Details data;
  @override
  _ItemsScreenState createState() => new _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> with TickerProviderStateMixin {
  Animation<double> animation;
  AnimationController animationController;
  ScrollController _scrollController = new ScrollController();
  bool isPerformingRequest = false;
  int currentPage=0;
  bool gridView=true;
  String title;
  static final _opacityTween = Tween<double>(begin: 0.0, end: 1.0);
  static final _sizeTween = Tween<double>(begin: 0.0, end: 300.0);
  List<Details> items=[];
  GlobalKey<AnimatedListState>key=GlobalKey();
  GlobalKey<ScaffoldState>scaffoldKey=GlobalKey();
  @override
  void initState() {
    super.initState();
    title = "Home";
    animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    animation =
        Tween(begin: 0.0, end: 1.0).animate(animationController);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        {
          print("Hello");
          _getMoreData();
        }
      }
    });
    _getMoreData();
    initialisePrefs();
  }

  SharedPreferences prefs;
  void initialisePrefs()async
  {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      gridView= (prefs.getBool("gridView") ?? true) ;
    });
  }
  @override
  Widget build(BuildContext context) {
    animationController.forward(from: 0.0);
    return Scaffold(
      key: scaffoldKey,
        body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          createAppbar(),
          SliverList(delegate:SliverChildBuilderDelegate((context,index){
            return getSongs();
          },childCount: 1), )
        ],
      ),
    );
  }
  CupertinoSliverNavigationBar createAppbar()
  {
    return CupertinoSliverNavigationBar(
        heroTag: "Items",
        leading: CupertinoButton(
          child: Icon(CupertinoIcons.left_chevron,color: Theme.of(context).iconTheme.color,),
          minSize: 0.0,
          padding: EdgeInsets.zero,
          onPressed: (){
            Navigator.of(context).maybePop();
          },),
        largeTitle: Text(widget.data.title,style: TextStyle(color: Theme.of(context).textTheme.title.color),textAlign: TextAlign.center,),
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
  Widget getSongs()
  {
    double ratio=(MediaQuery.of(context).size.width/2)/(MediaQuery.of(context).size.width/2.2);
    double listRatio=(MediaQuery.of(context).size.width)/(90.0);
    if(items.length==0)
      {
        return Center(child: CircularProgressIndicator(),);
      }
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridView? 2:1,
          childAspectRatio: gridView?0.8:listRatio,),
      itemBuilder:(context,index){
        if(gridView)
          {
            return items[index].buildGridItem(context,(){callback(index);});
          }
        else
          {
            return items[index].buildItemWidget(context,(){callback(index);});
          }
      },
      padding: EdgeInsets.all(8.0),
      shrinkWrap: true,
      itemCount: items.length,
      physics: BouncingScrollPhysics(),
    );
  }
    void callback(index)
    {
      if(items[index] is Song)
      {
        playSong(index);
      }
      else if(items[index] is Genre)
      {
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return ItemsScreen(items[index]);
        }));
      }
      else if(items[index] is Album&&items[index].url.startsWith("userData"))
        {
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return ItemsScreen(items[index]);
          }));
        }
      else
      {
        showShuffleScreen(index);
      }
    }
    void playSong(int index)
    {
      SoundWaveState.playSongs(items, index);
    }
    void showShuffleScreen(int index)
    {
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return ShuffleScreen(items[index]);
        }));
    }
    void showOptions()
    {

      showCupertinoModalPopup(context: context,builder: (context){
        return CupertinoActionSheet(
          actions: <Widget>[
            CupertinoActionSheetAction(onPressed: () {changeView();}, child: FlatButton.icon(onPressed: (){changeView();},materialTapTargetSize:MaterialTapTargetSize.shrinkWrap, icon: Icon(!gridView?Icons.view_quilt:Icons.view_list,color: Colors.black,), label: Text(!gridView?"Gridview":"ListView",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black,fontWeight: FontWeight.normal),),padding: EdgeInsets.all(0.0),)),
            CupertinoActionSheetAction(onPressed: () {SoundWaveState.showBetaDialog(context);}, child: FlatButton.icon(onPressed: (){},materialTapTargetSize:MaterialTapTargetSize.shrinkWrap, icon: Icon(Icons.share,color: Colors.black), label: Text("Share",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black,fontWeight: FontWeight.normal),),padding: EdgeInsets.all(0.0),)),
          ],
          cancelButton:CupertinoActionSheetAction(onPressed: () {
            Navigator.of(context).maybePop();
          }, child: Text("Cancel",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black),),),

        );
      });
    }
    void changeView()async
    {
      setState(() {
        gridView=!gridView;
      });
      prefs.setBool("gridView", gridView);
    }
    void _getMoreData()
    {
      if(isPerformingRequest)
        {
          return;
        }
       if(scaffoldKey.currentState!=null)
       {
         scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Loading more data"),action: SnackBarAction(label: "Ok", onPressed: (){}),));
       }
      isPerformingRequest=true;
       Network.getItems(widget.data.url,page: currentPage+1).then((data){

         if(data!=null)
         {
           isPerformingRequest=false;
           currentPage++;
           double edge = 50.0;
           double offsetFromBottom = _scrollController.position.maxScrollExtent - _scrollController.position.pixels;
           if (offsetFromBottom < edge) {
             _scrollController.animateTo(
                 _scrollController.offset - (edge -offsetFromBottom),
                 duration: new Duration(milliseconds: 500),
                 curve: Curves.easeOut);
           }
           setState(() {
             items.addAll(data);
           });
         }
         else
           {
             setState(() {
               items.addAll([]);
             });
           }
       });
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
    dispose() {
    animationController.dispose();
    super.dispose();
  }
}
