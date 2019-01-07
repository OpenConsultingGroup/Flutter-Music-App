import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:soundwave/music/song.dart';

class ChromeSearchBar extends StatefulWidget {
  final ScrollController scrollController;
  final String hint;
  ChromeSearchBar(this.scrollController,{this.hint="Search Here"});

  @override
  State<StatefulWidget> createState()=>ChromeSearchBarState();

}
class ChromeSearchBarState extends State<ChromeSearchBar> {
  double searchBorderRatio=1.0;
  final double maxSearchBorder=25.0;

  @override
  Widget build(BuildContext context) {
    widget.scrollController.addListener((){
      final double maxOffset=200.0;
      double ratio=1.0;
      if(widget.scrollController.offset.floor()<400)
      {
        ratio=(maxOffset-widget.scrollController.offset)/maxOffset;
        print("$ratio");
        if(ratio<0.0)
        {
          ratio=0.0;
        }
        if(ratio>1.0)
        {
          ratio=1.0;
        }
        ratio=num.parse(ratio.toStringAsFixed(3));
        if(ratio==this.searchBorderRatio)
        {
          return;
        }
        setState(() {
          this.searchBorderRatio=ratio;
        });
      }
    });
    return AnimatedContainer(
      duration: Duration(milliseconds: 50),
      curve: Curves.fastOutSlowIn,
      margin: EdgeInsets.fromLTRB(this.searchBorderRatio*12.0,this.searchBorderRatio*12.0,this.searchBorderRatio*12.0,this.searchBorderRatio*15.0,),
      decoration: BoxDecoration(color:Colors.white,border: Border.all(color: Colors.black26,width: 0.5),shape: BoxShape.rectangle,borderRadius: BorderRadius.circular(this.searchBorderRatio*this.maxSearchBorder)),
      padding: EdgeInsets.fromLTRB(15.0+3.0*(1-this.searchBorderRatio),12.0+3.0*(1-this.searchBorderRatio),15.0+3.0*(1-this.searchBorderRatio),12.0+3.0*(1-this.searchBorderRatio)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(CupertinoIcons.search,color: Colors.black54,size: 26.0,),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(left:8.0),
            child: Text(widget.hint,style: TextStyle(color: Colors.black45,fontSize: 16.0,fontFamily: "sans-serif")),
          )),
        ],
      ),
    );
  }
}