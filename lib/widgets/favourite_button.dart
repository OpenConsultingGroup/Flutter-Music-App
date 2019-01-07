import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/database.dart';

class FavouriteButton extends StatefulWidget{
  final dynamic song;
  final double size;
  final Color color;
  final double padding;
  const FavouriteButton(this.song,{Key key, this.size=24.0, this.color, this.padding=6.0}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>FavouriteButtonState();

}
class FavouriteButtonState extends State<FavouriteButton>{
  Function onPressed;
  Icon icon;
  bool isliked=false;
  DatabaseInterface databaseInterface;

  FavouriteButtonState(){
    databaseInterface=DatabaseInterface();
    databaseInterface.open();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(padding: EdgeInsets.all(widget.padding),minSize: widget.size,
        child: StreamBuilder(
          stream: databaseInterface.isFavourite(widget.song).asStream(),
              builder:(context,snapshot)
                  {
                    if(!snapshot.hasData)
                      {
                      return CupertinoButton(padding: EdgeInsets.all(6.0),minSize: widget.size,child:ImageIcon(AssetImage("images/heart.png"),size: widget.size,color: widget.color!=null?widget.color:Theme.of(context).iconTheme.color,), onPressed:null);

                      }
                    bool isLiked=snapshot.data!=null&&snapshot.data.value!=null;

                    return CupertinoButton(padding: EdgeInsets.all(6.0),minSize: widget.size,child:isLiked? ImageIcon(AssetImage("images/heartactive.png"),size: widget.size,color: Colors.red,):ImageIcon(AssetImage("images/heart.png"),size: widget.size,color:Theme.of(context).iconTheme.color,), onPressed: (){
                      if(isLiked)
                        {
                          databaseInterface.removeFavourite(widget.song).then((snapshot){
                            setState(() {
                              isLiked=false;
                            });
                          });
                        }
                      else{
                        databaseInterface.addFavourite(widget.song).then((snapshot){
                         setState(() {
                           isLiked=true;
                         });
                        });
                      }
                    });
                  }),
              onPressed:onPressed);
  }

}
