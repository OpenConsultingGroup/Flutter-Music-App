import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:soundwave/music/song.dart';

class Carousel extends StatefulWidget {
  final List<Details>details;
  Carousel(this.details);

  @override
  State<StatefulWidget> createState()=>CarouselState();

}
class CarouselState extends State<Carousel>{
  PageController controller;
  CarouselState()
  {
    controller=PageController();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: 320.0,
          child: PageView.builder(itemBuilder: (BuildContext context, int index) {
            return  buildCarouselItem(widget.details[index]);
          },
            itemCount: widget.details.length,
            physics: PageScrollPhysics(),
            controller: this.controller,
            scrollDirection: Axis.horizontal,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(5.0,5.0,5.0,10.0),
          child: Center(
            child: DotsIndicator(
              initialPage: 0,
              controller:this.controller,
              onPageSelected: (index)=>print(""),
              itemCount: 3,
            ),
          ),
        )
      ],
    );
  }
  Widget buildCarouselItem(Details details)
  {
    double height=300.0;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
          children: <Widget>[
          Container(
            height: height,
            child: Stack(
              fit: StackFit.expand,
                children: <Widget>[
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:[
                      FadeInImage.assetNetwork(placeholder: "images/music_placeholder.png", image: details.thumbnail,width: 200.0,height: 200.0,fit: BoxFit.fill,),
                      Padding(
                        padding: const EdgeInsets.only(top:12.0),
                        child: ListTile(
                          title: Text(details.title,style: Theme.of(context).textTheme.headline.copyWith(fontSize: 16.0),),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top:4.0),
                            child: Text(details.artist+" - "+details.label,style: Theme.of(context).textTheme.subhead.copyWith(fontSize: 14.0),maxLines: 1,overflow: TextOverflow.ellipsis,),
                          ),
                          trailing: IconButton(icon: Icon(Icons.play_circle_outline,size: 32.0,), onPressed: (){},color: Theme.of(context).iconTheme.color,),
                        ),
                      ),
                    ]
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

}
class DotsIndicator extends AnimatedWidget {

  DotsIndicator(
      {this.controller,
        this.itemCount,
        this.color,
        this.onPageSelected,
        this.initialPage,
      })
      : super(listenable: controller);

  // The PageController that this DotsIndicator is representing.
  final int initialPage;
  final PageController controller;
  final Color color;
  // The number of items managed by the PageController
  final int itemCount;

  // Called when a dot is tapped
  final ValueChanged<int> onPageSelected;


  // The base size of the dots
  final double dotSize=6.0;

  // The increase in the size of the selected dot
  final double dotIncreaseSize=2.0;

  // The distance between the center of each dot
  final double dotSpacing=24.0;

  Widget _buildDot(int index) {

    return new Container(
      width: dotSpacing,
      child: new Center(
        child: new Material(
          color: (controller.page==null?this.initialPage:controller.page.abs().toInt())%3==index?Colors.white:Colors.white54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
          child: new Container(
            width: 20.0 ,
            height: 3.0,
            child: Divider()
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List<Widget>.generate(itemCount, _buildDot),
    );
  }
}