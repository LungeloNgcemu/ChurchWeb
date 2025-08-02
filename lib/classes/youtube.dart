import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/material.dart';
import '../screens/media/fullscreen.dart';
import '../providers/url_provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as p;

class YouTube {
  late String videoId;
  late final player = Player();

  String convertVideo(String url) {
    videoId = YoutubePlayer.convertUrlToId(url)!;
    return videoId;
  }

  void sheeting(BuildContext context) {
    Widget _buildBottomSheet(
      BuildContext context,
      ScrollController scrollController,
      double bottomSheetOffset,
    ) {
      return FulllSceen();
    }

    showFlexibleBottomSheet(
      minHeight: 0,
      initHeight: 0.8,
      maxHeight: 0.8,
      context: context,
      builder: _buildBottomSheet,
      isExpand: true,
      bottomSheetBorderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      bottomSheetColor: Colors.white,
    );
  }

  Widget playYoutube(
    String id,
    String tittle,
    String description,
    BuildContext context,
  ) {
    final _controller = p.YoutubePlayerController.fromVideoId(
      videoId: id,
      autoPlay: false,
      params: const p.YoutubePlayerParams(showFullscreenButton: true),
    );

    final idProvider = Provider.of<IdProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color with opacity
              spreadRadius: 2, // Spread radius
              blurRadius: 5, // Blur radius
              offset: Offset(2, 2), // Offset in the x and y direction
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onDoubleTap: () {
                idProvider.changeID(id);
                sheeting(context);
              },
              child: AbsorbPointer(
                absorbing: false,
                child: p.YoutubePlayer(
                  controller: _controller,
                  aspectRatio: 16 / 9,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      tittle,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      description,
                      softWrap: true,
                      style: const TextStyle(
                        fontSize: 11.0,
                        color: Color.fromARGB(141, 0, 0, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget displayYoutubeOnly(
    String id,
    String title,
    String description,
    BuildContext context,
  ) {
    final thumbnailUrl = "https://img.youtube.com/vi/$id/0.jpg";

    final idProvider = Provider.of<IdProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: GestureDetector(
        onDoubleTap: () {
          idProvider.changeID(id);
          sheeting(context);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  thumbnailUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black12,
                    height: 200,
                    child: const Center(child: Icon(Icons.error)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        description,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: Color.fromARGB(141, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget xplayYoutube(String id, String tittle, String description,
      BuildContext context, YoutubePlayerController controller) {
    return RotatedBox(
      quarterTurns: 1,
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
          aspectRatio: 14 / 9,
          bottomActions: [],
          controller: controller,
        ),
        builder: (context, player) {
          return player;
        },
      ),
    );
  }
}
