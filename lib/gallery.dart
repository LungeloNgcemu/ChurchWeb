import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';


class Gallery extends StatefulWidget {
 Gallery({this.images,this.grid, Key? key}) : super(key: key);
  final List<String>? images;
  final Widget? grid;
  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {

  @override
  Widget build(BuildContext context) {
    final image = widget.images ?? [];
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: widget.grid ?? Container(),
    );
  }
}

class Tile extends StatelessWidget {

 Tile({required this.image});

 final String? image;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.grey, // Set the border color
          width: 1.0, // Set the border width
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          imageUrl: image ?? "",
          placeholder: (context, url) => const Center(
            child: SizedBox(
              height: 40.0,
              width: 40.0,
              child: CircularProgressIndicator(
                value: 1.0,
              ),
            ),
          ),
          errorWidget: (context, url, error) =>
              Icon(Icons.error),
          fit: BoxFit.cover,
          //height: 250,
          //width: double.maxFinite,
        ),
      ),
    );
  }
}