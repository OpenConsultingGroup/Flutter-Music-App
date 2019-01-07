import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:soundwave/items_screen.dart';
import 'package:soundwave/music/song.dart';

class MoreButton extends StatelessWidget {
  
  const MoreButton(
         this.data,
        {Key key,})
        :
        super(key: key);

  final Details  data;

  @override
  Widget build(BuildContext context) {

    return CupertinoButton(
        minSize: 0.0,
        onPressed: (){
         Navigator.of(context).push(MaterialPageRoute(builder: (context){
           return ItemsScreen(data);
         }));
        },
        padding: EdgeInsets.all(0.0),
        child: Text("View all",style: Theme.of(context).textTheme.subhead,maxLines: 1,overflow: TextOverflow.ellipsis,));
  }
}
