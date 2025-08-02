import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../classes/youtube.dart';
import '../../componants/global_booking.dart';
import '../../providers/url_provider.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as p;

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

  @override
  void initState() {
    // final idProvider = Provider.of<IdProvider>(context, listen: false);

    // controller = p.YoutubePlayerController.fromVideoId(
    //   videoId: idProvider!.id!,
    //   autoPlay: false,
    //   params: const p.YoutubePlayerParams(showFullscreenButton: true),
    // );

    super.initState();
  }

  p.YoutubePlayerController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (controller == null) {
      final idProvider = Provider.of<IdProvider>(context, listen: false);
      controller = p.YoutubePlayerController.fromVideoId(
        videoId: idProvider.id!,
        autoPlay: false,

        params: const p.YoutubePlayerParams(showFullscreenButton: true),
      );
    }
  }

  // @override
  // void dispose() {
  //   controller?.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final idProvider = Provider.of<IdProvider>(context, listen: false);

    return Align(
      alignment: Alignment.center,
      child: Column(children: [
        Expanded(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(15.0),
                topLeft: Radius.circular(15.0)),
            child: RotatedBox(
              quarterTurns: 1,
              child: p.YoutubePlayer(
                controller: controller!,
                aspectRatio: 16 / 9,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
