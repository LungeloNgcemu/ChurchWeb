import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';


class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  @override

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        height: 400.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0)
        ) ,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(51.509364, -0.128928),
              initialZoom: 16.2,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              TileLayer(
                urlTemplate:
                'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.example.app',
                // You can implement custom error handling logic here
          
              ),
            ],
          ),
        ),
      ),
    );
  }
}
