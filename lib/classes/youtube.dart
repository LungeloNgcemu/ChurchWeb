import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart%20';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../screens/media/fullscreen.dart';
import '../providers/url_provider.dart';



class YouTube {
  late String videoId;

  String convertVideo(String url) {
    videoId = YoutubePlayer.convertUrlToId(url)!;

    print(videoId);

    return videoId;
  }

  // void scrollToIndex(int index,ScrollController scrollController) {
  //   scrollController.animateTo(
  //     index * 500.0, // Adjust this value according to your list item size
  //     duration: Duration(milliseconds: 500),
  //     curve: Curves.easeInOut,
  //   );
  // }

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
      bottomSheetBorderRadius: BorderRadius.only(
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
    YoutubePlayerController controller = YoutubePlayerController(
      initialVideoId: id,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        showLiveFullscreenButton: false,
      ),
    );

    final idProvider = Provider.of<IdProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10.0),
          boxShadow:[
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

                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => FulllSceen(),
                //   ),
                // );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0),topRight:Radius.circular(10.0) ),
                child: YoutubePlayerBuilder(
                  onEnterFullScreen: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FulllSceen(),
                      ),
                    );
                  },
                  onExitFullScreen: () {
                    final visibilityProvider =
                        Provider.of<VisibilityProvider>(context, listen: false);

                    // Call the toggleVisibility method when the button is pressed
                    visibilityProvider.visibilityToggle(true);
                  },
                  player: YoutubePlayer(
                    bottomActions: [],
                    controller: controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.amber,
                    progressColors: const ProgressBarColors(
                      playedColor: Colors.amber,
                      handleColor: Colors.amberAccent,
                    ),
                    onReady: () {},
                  ),
                  builder: (context, player) {
                    return player;
                  },
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
                      child: Text(tittle,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(description,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 11.0,
                          color: Color.fromARGB(141, 0, 0, 0),
                        ),
                      ),
                    ),
                    // RatingBar.builder(
                    //     initialRating: 3,
                    //     minRating: 1,
                    //     direction: Axis.horizontal,
                    //     allowHalfRating: true,
                    //     itemCount: 5,
                    //     itemSize: 20,
                    //     itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    //     itemBuilder: (context, _) => Icon(
                    //       Icons.star,
                    //       color: Colors.amber,
                    //     ),
                    //     onRatingUpdate: (rating) {
                    //       print(rating);
                    //     },
                    //   ),
                  ],
                ),
              ),


          ],
        ),
      ),
    );
  }

  Widget xplayYoutube(
    String id,
    String tittle,
    String description,
    BuildContext context,
      YoutubePlayerController controller
  ) {

    return RotatedBox(
      
      quarterTurns: 1,
      child: YoutubePlayerBuilder(
        player: YoutubePlayer(
aspectRatio: 14/9,
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
