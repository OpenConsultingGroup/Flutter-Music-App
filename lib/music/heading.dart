import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Heading {
  String title;
  Color color;
  Heading(this.title,{this.color=Colors.black});

  Widget buildWidget()
  {
    List<String> parts=[];
    int divider=(title.length/2).floor();
    parts.add(title.substring(0,divider));
    parts.add(title.substring(divider));

    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: ListTile(
        title: RichText(textAlign: TextAlign.center,text: TextSpan(style:TextStyle(fontWeight: FontWeight.bold,fontSize: 19.0),children: [TextSpan(text:parts[0],style: TextStyle(color:Colors.purple)),TextSpan(text:parts[1],style: TextStyle(color: CupertinoColors.black))])),
        subtitle: Padding(
          padding: const EdgeInsets.only(top:4.0),
          child: Text("Enjoy Latest Albums of Bollywood",style: TextStyle(fontSize: 15.0,color: Colors.blueGrey[200]),maxLines: 1,textAlign: TextAlign.center,),

        ),
      ),
    );
  }
}