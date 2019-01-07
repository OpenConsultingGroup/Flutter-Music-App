import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:soundwave/collections_screen.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/database.dart';
import 'package:soundwave/shuffle_screen.dart';

class MenuButton extends StatefulWidget{
  final Widget icon;
  final Details song;
  final Color color;
  final bool showPlay;

  const MenuButton(this.song,{Key key,this.icon, this.color, this.showPlay =true}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>MenuButtonState();

}
class MenuButtonState extends State<MenuButton>{

  Widget icon;
  DatabaseInterface databaseInterface;
  @override
  void initState() {
    super.initState();
    databaseInterface=DatabaseInterface();

  }
  @override
  Widget build(BuildContext context) {
    if(widget.icon==null)
    {
      icon=Icon(Icons.more_horiz,color: widget.color!=null?widget.color:Theme.of(context).iconTheme.color,);
    }
    else
    {
      icon=widget.icon;
    }
    return CupertinoButton(
      minSize: 0.0,
      padding: EdgeInsets.all(4.0),
      child: icon,
      onPressed: showDetails,
    );
  }
  void showDetails()
  {
    Details song=widget.song;
    List<Widget>menuItems=[];

    menuItems.add(Padding(
      padding: const EdgeInsets.symmetric(vertical:16.0),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child:  FadeInImage.assetNetwork(placeholder: "images/music_placeholder.png",image:song.thumbnail,width: 75.0,height: 75.0,fit: BoxFit.fill,),
        ),
        title: Text(song.title,style: Theme.of(context).textTheme.title,),
        subtitle: song is Song?Text(song.artist,style: Theme.of(context).textTheme.subtitle,):Text(song.type[0].toUpperCase()+song.type.substring(1),style: Theme.of(context).textTheme.subtitle,),
      ),
    ));


    if(widget.song is Song)
      {
        menuItems.add(LikeTile(widget.song));
        menuItems.add(ListTile(
          leading: Icon(Icons.share,color: Theme.of(context).iconTheme.color,),
          title: Text("Share",style: Theme.of(context).textTheme.title,),
          onTap: (){
            SoundWaveState.showBetaDialog(context);
          },
        ));

        menuItems.add(ListTile(
          leading: Icon(Icons.playlist_add,color: Theme.of(context).iconTheme.color,),
          title: Text("Add to Playlist",style: Theme.of(context).textTheme.title,),
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context){
              return CollectionsScreen(songs:[widget.song]);
            }));
          },
        ));

         if(widget.showPlay)
           {

             menuItems.add(Center(child: Padding(
               padding: const EdgeInsets.symmetric(horizontal:16.0),
               child: Divider(color: Theme.of(context).primaryColorLight,),
             )));
             menuItems.add(ListTile(
               onTap: (){
                 SoundWaveState.addNext(widget.song);
                 Navigator.of(context).maybePop();
               },
               leading: Icon(Icons.skip_next,color: Theme.of(context).iconTheme.color,),
               title: Text("Play next",style: Theme.of(context).textTheme.title,),
             ));
             menuItems.add(ListTile(
               onTap: (){
                 SoundWaveState.addToQueue(widget.song);
                 Navigator.of(context).maybePop();
                },
               leading: Icon(Icons.add_circle,color: Theme.of(context).iconTheme.color,),
               title: Text("Add to End of Queue",style: Theme.of(context).textTheme.title,),
             ));
           }

      }
    menuItems.add(ListTile(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ShuffleScreen(widget.song)));
      },
      leading: Icon(Icons.info,color: Theme.of(context).iconTheme.color,),
      title: Text("Details",style: Theme.of(context).textTheme.title,),
    ));
    showModalBottomSheet(context: context, builder: (context){
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView.builder(itemBuilder: (context,index){
          return menuItems[index];
        },
          shrinkWrap: true,
          itemCount: menuItems.length,
        ),
      );
    });
  }
}

class LikeTile extends StatefulWidget{
  final Song song;

  const LikeTile(this.song,{Key key, }) : super(key: key);
  @override
  State<StatefulWidget> createState() =>LikeTileState();

}
class LikeTileState extends State<LikeTile>{
  Function onPressed;
  Icon icon;
  bool isliked=false;
  DatabaseInterface databaseInterface;

  LikeTileState(){
    databaseInterface=DatabaseInterface();
    databaseInterface.open();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(padding: EdgeInsets.all(0.0),minSize: 0.0,
        child: FutureBuilder(
            future: databaseInterface.isFavourite(widget.song),
            builder:(context,snapshot)
            {
              if(!snapshot.hasData)
              {
                ListTile(
                  leading: Icon(Icons.favorite_border,color: Theme.of(context).iconTheme.color,),
                  title: Text("Like",style: Theme.of(context).textTheme.title,),
                );
              }
              isliked=snapshot.data!=null&&snapshot.data.value!=null;

              return  ListTile(
                leading: Icon(isliked?Icons.favorite:Icons.favorite_border,color: Theme.of(context).iconTheme.color,),
                title: Text(isliked?"Dislike":"Like",style: Theme.of(context).textTheme.title,),
              );
            }),
        onPressed:(){
          if(isliked)
          {
            databaseInterface.removeFavourite(widget.song).then((snapshot){
              setState(() {
                isliked=false;
              });
            });
          }
          else{
            databaseInterface.addFavourite(widget.song).then((snapshot){
              setState(() {
                isliked=true;
              });
            });
          }
        });
  }

}
