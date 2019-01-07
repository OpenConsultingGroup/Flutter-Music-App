import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:soundwave/main.dart';
import 'package:soundwave/music/song.dart';
import 'package:soundwave/database.dart';

class PlayButton extends StatefulWidget{
  final double size;
  final Color color;
  final double padding;
  final bool progress;
  const PlayButton({Key key, this.size=24.0, this.color, this.padding=6.0, this.progress=false}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>PlayButtonState();

}
class PlayButtonState extends State<PlayButton>{
  StreamSubscription<Command>subscription;
  @override
  void initState() {
    super.initState();
    subscription=SoundWaveState.publishSubject.listen((command){
      if(command.command!=Command.duration&&command.command!=Command.position)
        {
          setState(() {

          });
        }

    });
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(padding: EdgeInsets.all(widget.padding),minSize: widget.size,
        child:child(),
        onPressed:(){onPressed();});
  }

  Widget child()
  {
    if(SoundWaveState.disabled)
      {
        if(widget.progress)
          {
            return Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircularProgressIndicator(),
            );
          }
        else{
          return Icon(Icons.pause,size: widget.size,color: Color(0xff616161)
            ,);

        }
      }
    else
      {
        if(SoundWaveState.currentPlaylist.playing)
          {
            return Icon(Icons.pause,size: widget.size,color: widget.color!=null?widget.color:Theme.of(context).iconTheme.color,);
          }
        else
          {
            return Icon(Icons.play_arrow,size: widget.size,color: widget.color!=null?widget.color:Theme.of(context).iconTheme.color,);
          }
      }
  }

  void onPressed() {
    if(SoundWaveState.disabled)
      {
        return;
      }
    SoundWaveState.play(playing: !SoundWaveState.currentPlaylist.playing);
  }
  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
