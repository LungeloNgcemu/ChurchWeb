import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/componants/global_booking.dart';
import 'package:master/componants/overview.dart';
import 'package:master/providers/url_provider.dart';
import 'package:master/util/alerts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../classes/church_init.dart';
import 'package:master/widgets/common/connect_loader.dart';
import 'package:master/widgets/common/connect_icon.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  ChurchInit visbibity = ChurchInit();
  Authenticate auth = Authenticate();

  bool isLoading = false;

  Future<Position> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  Widget renderMap() {
    final project =
        Provider.of<christProvider>(context, listen: false).myMap['Project'];

    // Parse stored coordinates — fall back to a world-centre default so the
    // map always renders even when no location has been saved yet.
    final double? lat = double.tryParse(project?['GpsLat']?.toString() ?? '');
    final double? lng = double.tryParse(project?['GpsLong']?.toString() ?? '');
    final bool hasLocation = lat != null && lng != null;

    final LatLng centre =
        hasLocation ? LatLng(lat!, lng!) : const LatLng(0, 0);

    return FlutterMap(
      options: MapOptions(
        initialCenter: centre,
        initialZoom: hasLocation ? 16.2 : 2.0,
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
        ),
        if (hasLocation)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(lat!, lng!),
                width: 40,
                height: 40,
                child: const Locator(),
              ),
            ],
          ),
      ],
    );
  }

  ChurchInit churchStart = ChurchInit();

  Future<void> uploadLocation({lat, long, church}) async {
    print(long);

    Authenticate auth = Authenticate();
    try {
      await supabase
          .from("Church")
          .update({'GpsLong': long, 'GpsLat': lat}).eq("ChurchName", church);
      print("Completed");
    } catch (error) {
      print("location upload error : $error");
      const message = "Something went wrong adding the location";
      alertReturn(context, message);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: isLoading
          ? const Center(child: ConnectLoader())
          : Column(
              children: [
                Visibility(
                  visible: ChurchInit.visibilityToggle(context),
                  child: Visibility(
                    visible: Provider.of<christProvider>(context, listen: false)
                            .myMap['Project']?['Expire'] ??
                        false,
                    child: Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () async {
                            final provider = Provider.of<christProvider>(
                                context,
                                listen: false);
                            final churchName =
                                provider.myMap['Project']?['ChurchName'] ?? '';

                            setState(() => isLoading = true);

                            try {
                              final location = await getLocation();
                              final latitude = location.latitude;
                              final longitude = location.longitude;

                              await uploadLocation(
                                  lat: latitude,
                                  long: longitude,
                                  church: churchName);

                              // Patch provider so renderMap reads new coords
                              provider.myMap['Project']['GpsLat'] =
                                  latitude.toString();
                              provider.myMap['Project']['GpsLong'] =
                                  longitude.toString();
                              provider.updatemyMap(newValue: provider.myMap);

                              if (context.mounted) {
                                alertComplete(context, 'Location Updated');
                              }
                            } catch (_) {
                              if (context.mounted) {
                                alertReturn(context,
                                    'Could not get location. Check permissions.');
                              }
                            }

                            setState(() => isLoading = false);
                          },
                          child: Text("Select Location"),
                        )),
                  ),
                ),
                Container(
                  height: 400.0,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(50.0)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: renderMap(),
                  ),
                ),
              ],
            ),
    );
  }
}

class Locator extends StatelessWidget {
  const Locator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const ConnectIcon(size: 20),
    );
  }
}
