import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart%20';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../classes/youtube.dart';
import '../../componants/global_booking.dart';
import '../../providers/url_provider.dart';

class FulllSceen extends StatefulWidget {
  FulllSceen({this.url, this.description, this.id, this.tittle, super.key});

  String? url;
  String? id;
  String? tittle;
  String? description;

  @override
  State<FulllSceen> createState() => _FulllSceenState();
}

class _FulllSceenState extends State<FulllSceen> {
  YouTube youTube = YouTube();
  IdProvider? idProvider;
  YoutubePlayerController? controller;

  @override
  void initState() {
   // TODO: implement initState


    final  idProvider = Provider.of<IdProvider>(context,listen: false);

   controller = YoutubePlayerController(
      initialVideoId: idProvider!.id!,
      flags: YoutubePlayerFlags(
        disableDragSeek: false,
        autoPlay: false,
        mute: false,
        hideControls: false,
        showLiveFullscreenButton: false
      ),
    );


    super.initState();
  }

  @override
  void dispose() {

    controller?.dispose();
    // TODO: implement dispose
    super.dispose();
  }


  // final linkId = youTube.convertVideo(MediaList?[index]['URL']);
  @override
  Widget build(BuildContext context) {
   final  idProvider = Provider.of<IdProvider>(context,listen: false);
    // Call the toggleVisibility method when the button is pressed

    return Align(
      alignment: Alignment.center,
      child: Column(
        children:[ Expanded(
          child: Container(
            child: ClipRRect(
              borderRadius: BorderRadius.only(topRight:Radius.circular(15.0),topLeft: Radius.circular(15.0) ),
              child: youTube.xplayYoutube(idProvider.id!, widget.tittle ?? "",
                  widget.description ?? "", context,controller!),
            ),
          ),
        ),
      ]),
    );

  }
}
