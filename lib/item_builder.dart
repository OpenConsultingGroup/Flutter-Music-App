import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:soundwave/collections_screen.dart';
import 'package:soundwave/items_screen.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/shuffle_screen.dart';
import 'package:soundwave/widgets/menu_button.dart';
import 'package:soundwave/database.dart';
import 'package:soundwave/widgets/favourite_button.dart';
import 'package:soundwave/widgets/more_button.dart';

class ItemBuilder{
  static final int topic=1,forYou=2,recent=3;
  final BuildContext context;
  DatabaseInterface _databaseInterface;
  ItemBuilder(this.context){
    _databaseInterface=DatabaseInterface();
  }
  void play(List<Song>songs,int index){
    SoundWaveState.playSongs(songs,index);
  }
  Widget buildTopicPlaylist(String title,List playlist)
  {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.symmetric(vertical:4.0,horizontal: 4.0),
              child: ListTile(
                title: Text(title,style:Theme.of(context).textTheme.headline,maxLines: 1,overflow: TextOverflow.ellipsis),
                trailing: Text("View all",style:Theme.of(context).textTheme.subhead,maxLines: 1,overflow: TextOverflow.ellipsis,),
              )
          ),
          Table(
            children: [
              TableRow(
                children: [
                  playlist[0].buildWidget(context,()
                  {
                    showAlbumScreen(playlist[0]);
                  }),
                  playlist[1].buildWidget(context,()
                  {
                    showAlbumScreen(playlist[0]);
                  }),
                ]
              ),
              TableRow(
                  children: [
                    playlist[2].buildWidget(context,()
                    {
                      showAlbumScreen(playlist[0]);
                    }),
                    playlist[3].buildWidget(context,()
                    {
                      showAlbumScreen(playlist[0]);
                    }),
                  ]
              )
            ],
          )
        ],
      ),
    );
  }

  Widget buildTrendingPlaylist(String title ,List<Song>songs)
  {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('Editorial Picks',style:Theme.of(context).textTheme.headline,maxLines: 1,overflow: TextOverflow.ellipsis,),
            trailing: MoreButton(Details(title: "Editorial Picks",url: "library/top 20 songs")),
          ),
          ListView.builder(itemBuilder: (context,index){
            return songs[index].buildItemWidget(context,()
            {
              play(songs,index);
            },
            );
          },
            padding: EdgeInsets.symmetric(vertical: 4.0,horizontal: 8.0),
            physics: ClampingScrollPhysics(),
            itemCount: songs.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
          ),
        ],
      ),
    );
  }
  Widget buildTopAlbums(List<Details>details)
  {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.symmetric(vertical:4.0,horizontal: 4.0),
              child: ListTile(
                title: Text('Top Albums ',style:Theme.of(context).textTheme.headline,maxLines: 1,overflow: TextOverflow.ellipsis,),
                trailing: MoreButton(Details(title: "Top Albums",url: "library/top punjabi albums")),
              )
          ),
          Container(
            height: 258.0,
            child: ListView.builder(
              itemBuilder:(context,index){
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: details[index].buildTrendingWidget(context, (){
                    showAlbumScreen(details[index]);
                  },index),
                );
              },
              physics: BouncingScrollPhysics(),
              itemCount: details.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
            ),
          ),

        ],
      ),
    );
  }

  Widget buildArtistList(List<Artist>artists,{Axis axis=Axis.horizontal})
  {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.symmetric(vertical:4.0,horizontal: 4.0),
              child: ListTile(
                title: Text('Artists',style:Theme.of(context).textTheme.headline,maxLines: 1,overflow: TextOverflow.ellipsis,),
                trailing:axis==Axis.horizontal? MoreButton(Details(title: "Artists",url: "artists")):null,
              )
          ),
          Container(
            constraints: BoxConstraints(maxHeight: 180.0),
            child: ListView.builder(itemBuilder: (context,index){
              return axis==Axis.horizontal?artists[index].buildWidget(context,()
              {
              showAlbumScreen(artists[index]);
              }):
              artists[index].buildItemWidget(context,()
              {
                showAlbumScreen(artists[index]);
              });
            },
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              physics: ClampingScrollPhysics(),
              itemCount: artists.length,
              shrinkWrap: true,
              scrollDirection: axis,
            ),
          )
        ],
      ),
    );
  }
  Widget buildMadeForYou(Album playlist)
  {
    List<Song>songs=playlist.songs;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical:12.0,horizontal: 12.0),
          child: Text("Made for you",style: Theme.of(context).textTheme.headline,),
        ),
        Container(
          margin: EdgeInsets.only(top: 12.0),
          child: ListView.builder(itemBuilder: (context,index){
            return playlist.buildPlaylistCover(context,(){showAlbumScreen(playlist[index]);});
          },
            physics: ClampingScrollPhysics(),
            itemCount: songs.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
          ),
        )
      ],
    );
  }

  void showAlbumScreen(dynamic data) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return ShuffleScreen(data);
    }));
  }

  Widget buildRecentlyPlayed(List<Details>songs)
  {
    return Column(
      children: <Widget>[
        Padding(
            padding: const EdgeInsets.symmetric(vertical:4.0,horizontal: 4.0),
            child: ListTile(
              title: Text("Recently Played",style:Theme.of(context).textTheme.headline,maxLines: 1,overflow: TextOverflow.ellipsis),
              trailing: Text("View all",style:Theme.of(context).textTheme.subhead,maxLines: 1,overflow: TextOverflow.ellipsis,),
            )
        ),
        Container(
          height: 190.0,
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: ListView.builder(itemBuilder: (context,index){
            return songs[index].buildRecentWidget(context,()
            {
              play(songs,index);
            },
            );
          },
            physics: ClampingScrollPhysics(),
            itemCount: songs.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }
  //Build Big Playlist
  Widget buildSongsList(List<Song>songs,Details details)
  {
    return Container(
      margin: EdgeInsets.only(top: 4.0),
      child: Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Column(
            children: <Widget>[
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    createPlaylistButton(songs),
                    createPlayButton(songs)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical:4.0,horizontal: 0.0),
                child: ListTile(
                  title: Text('Queue',style:Theme.of(context).textTheme.headline,maxLines: 1,overflow: TextOverflow.ellipsis,),
                  )
                ),
          ListView.builder(itemBuilder: (context,index){

            return songs[index].buildItemWidget(context,(){
              play(songs,index);
            });
          },
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            physics: ClampingScrollPhysics(),
            itemCount: songs.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
          ),
        ],
      ),
    ));
  }
  Widget createPlaylistButton(List<Song>songs)
  {
    return Center(child:RaisedButton(child:Icon(Icons.add,size: 32.0,color: Colors.teal.shade900,),padding: EdgeInsets.all(12.0), onPressed: () {Navigator.of(context).push(MaterialPageRoute(builder: (context){return CollectionsScreen(songs:songs);}));},shape: CircleBorder(),color: Colors.white,));
  }
  Widget createPlayButton(List<Song>songs)
  {
    return Center(child: RaisedButton(child:Icon(Icons.play_arrow,size: 32.0,color: Colors.white,),padding: EdgeInsets.all(12.0), onPressed: () {play(songs, 0);},shape: CircleBorder(),color: Colors.lightGreen,));
  }
  Widget buildAlbumScreen(Album playlist)
  {
    List<Widget> widgets=[buildSongsList(playlist.songs,playlist)];
    return ListView.builder(itemBuilder: (context,index){
      return widgets[index];
    },
      itemCount: widgets.length,
     shrinkWrap: true,
      physics: ClampingScrollPhysics(),
    );
  }
  Widget buildSongScreen(Song song)
  {
    Album playlist=Album(songs:[song]);
    List<Widget> widgets=[buildSongsList(playlist.songs,playlist)];
    return ListView.builder(itemBuilder: (context,index){
      return widgets[index];
    },
      itemCount: widgets.length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
    );
  }
  Widget buildArtistScreen(Artist artist)
  {
    List<Widget> widgets=[];
    return ListView.builder(itemBuilder: (context,index){
      return widgets[index];
    },
      itemCount: widgets.length,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
    );
  }
  Widget buildRelatedWidget(dynamic data,Function callback)
  {
    double size=175.0;
    return CupertinoButton(
      minSize: 0.0,
      padding: EdgeInsets.all(0.0),
      onPressed: (){callback();},
      child: Container(
        padding: EdgeInsets.fromLTRB(10.0,15.0,10.0,15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Image(image: NetworkImage(data.thumbnail),width: size,height: size,fit: BoxFit.fill,),
            ),
            Padding(
              padding: const EdgeInsets.only(top:16.0),
              child: Text(data.title,style: Theme.of(context).textTheme.title,),
            ),

          ],
        ),
      ),
    );
  }
  Widget buildDetails(dynamic details)
  {
    if(details.type=="artist")
      {
        return Container(width:0.0,height:0.0);
      }
     String title=details.released;
    print(details.label);
     String subtitle="©"+details.label;
     print(details.released);
     if(title==null)
       {
         title="";
       }
     if(subtitle==null)
       {
         subtitle="";
       }
     return Container(
       padding: EdgeInsets.only(top:0.0),
       child: ListTile(
         title:Text(title,style: Theme.of(context).textTheme.subhead,textAlign: TextAlign.center,),
         subtitle:Text(subtitle,style: Theme.of(context).textTheme.subhead,textAlign: TextAlign.center,),
  ),
     );
  }
  Widget buildRelated(List items)
  {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0,12.0,8.0,0.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0,16.0,8.0,8.0),
            child: Text("You might also like",style: Theme.of(context).textTheme.headline,),
          ),
          Container(
            height: 250.0,
            child: ListView.builder(itemBuilder: (context,index){
              return buildRelatedWidget(items[index], (){showAlbumScreen(items[index]);});
            },
              physics: BouncingScrollPhysics(),
              itemCount: items.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
            ),
          )
        ],
      ),
    );
  }
  void addSearch(dynamic data)
  {
    _databaseInterface.addRecentSearch(data);
    showAlbumScreen(data);
  }
  //Search Screen
  Widget buildSearchItem(dynamic data,{Widget trailing})
  {

    return CupertinoButton(
      onPressed:(){ addSearch(data);},
      padding: EdgeInsets.all(0.0),
      minSize: 0.0,
      child: Container(
        margin: EdgeInsets.symmetric(vertical:8.0,horizontal: 12.0),
        child: Row(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(color:Color(0xfffeee6ff),borderRadius: data.type=="artist"?BorderRadius.circular(40.0):BorderRadius.circular(4.0)),
              child: ClipRRect(
                borderRadius:data.type=="artist"?BorderRadius.circular(40.0):BorderRadius.circular(4.0),
                child: FadeInImage.assetNetwork(placeholder: Details.placeholders[data.type], image: data.thumbnail,width: 70.0,height: 70.0,fit: BoxFit.fill,),),
            ),
              Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(data.title,style: Theme.of(context).textTheme.title,maxLines: 1,overflow: TextOverflow.ellipsis,),
                    Padding(
                      padding: const EdgeInsets.only(top:4.0),
                      child: Text(data.artist,style:Theme.of(context).textTheme.subtitle,maxLines: 1,overflow: TextOverflow.ellipsis,),
                    ),
                  ],
                ),
              ),
            ),
            trailing==null?IconButton(icon: Icon(Icons.chevron_right),color:  Theme.of(context).primaryColorLight,onPressed: (){ addSearch(data);},):trailing
          ],
        ),
      ),
    );
  }

  Widget buildCategoryGrid(List<Genre> categories)
  {
    return Padding(
      padding: const EdgeInsets.only(top:8.0),
      child: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.symmetric(vertical:4.0,horizontal: 4.0),
              child: ListTile(
                title: Text('Top Genre',style:Theme.of(context).textTheme.headline,maxLines: 1,overflow: TextOverflow.ellipsis,),
                trailing: MoreButton(Details(title: "Categories",url: "genres")),
              )
          ),
          Container(
            height: 250.0,
            child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,childAspectRatio: 0.6),
              itemBuilder:(context,index){
                return categories[index].buildWidget(context, (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=>ItemsScreen(categories[index])));});
              },
              physics: BouncingScrollPhysics(),
              itemCount: categories.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
            ),
          ),

        ],
      ),
    );
  }
}