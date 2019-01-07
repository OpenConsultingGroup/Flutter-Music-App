import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/database.dart';

class SocialButton extends StatefulWidget{
  final Details details;
  const SocialButton(this.details,{Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>SocialButtonState();

}
class SocialButtonState extends State<SocialButton>{
  Function onPressed;
  Icon icon;

  DatabaseInterface databaseInterface;

  SocialButtonState(){
    databaseInterface=DatabaseInterface();
    databaseInterface.open();
  }
  bool isPublic=false;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: databaseInterface.isPublic(widget.details).asStream(),
        builder:(context,snapshot)
        {
          if(!snapshot.hasData)
          {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CupertinoSwitch(value: isPublic, onChanged: (value){
                  isPublic=value;databaseInterface.makePublicPlaylist(widget.details, value).then((value){
                  setState(() {

                  });
                });},),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text("Public",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black),),
                )
              ],
            );

          }
        print("Hello");
        isPublic=snapshot.data!=null&&snapshot.data.value!=null;

         return Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                CupertinoSwitch(value: isPublic, onChanged: (value)
                {
                  databaseInterface.makePublicPlaylist(widget.details,value).then((value){setState(() {
                      print(value);
                      if(value!=null)
                        {
                          isPublic=true;
                        }
                      else
                        {
                          isPublic=false;
                        }
                  });});
                },),
                Padding(
                  padding: const EdgeInsets.only(left:8.0),
                  child: Text("Public",style: Theme.of(context).textTheme.title.copyWith(color: Colors.black),),
                )
                ],
              );
          });
  }

}
