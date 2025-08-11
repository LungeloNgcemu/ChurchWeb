import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:full_screen_image/full_screen_image.dart';

class Gallery extends StatefulWidget {
  Gallery({this.images, this.grid, Key? key}) : super(key: key);
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
    return FullScreenWidget(
      disposeLevel: DisposeLevel.Low,
      child: Center(
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(image ?? "",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error))),
      ),
    );
  }
}
