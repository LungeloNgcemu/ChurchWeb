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
import '../../post/post_screen.dart';

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
    try {
      return FlutterMap(
        options: MapOptions(
          //-29.86109279114517, 31.014298324827156
          initialCenter: LatLng(
              double.parse(Provider.of<christProvider>(context, listen: false)
                  .myMap['Project']?['GpsLat']),
              double.parse(Provider.of<christProvider>(context, listen: false)
                  .myMap['Project']?['GpsLong'])),
          initialZoom: 16.2,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          TileLayer(
            urlTemplate: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
            userAgentPackageName: 'com.example.app',
            // You can implement custom error handling logic here
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                    double.parse(
                        Provider.of<christProvider>(context, listen: false)
                                .myMap['Project']?['GpsLat'] ??
                            "-29.841178318331405"),
                    double.parse(
                        Provider.of<christProvider>(context, listen: false)
                                .myMap['Project']?['GpsLong'] ??
                            " 30.964530725047396")),
                width: 70,
                height: 70,
                child: Locator(),
              )
            ],
          ),
        ],
      );
    } catch (error) {
      print("This is the Map error : $error");
      return Container();
    }
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
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Visibility(
                  visible: visbibity.visibilityToggle(context),
                  child: Visibility(
                    visible: Provider.of<christProvider>(context, listen: false)
                            .myMap['Project']?['Expire'] ??
                        false,
                    child: Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () async {
                            Future<void> locator() async {
                              final location = await getLocation();
                              final latitude = location.latitude;
                              final longitude = location.longitude;

                              print(
                                  "Latitude: $latitude, Longitude: $longitude");

                              await uploadLocation(
                                  lat: latitude,
                                  long: longitude,
                                  church: Provider.of<christProvider>(context,
                                              listen: false)
                                          .myMap['Project']?['ChurchName'] ??
                                      "");
                            }

                            setState(() {
                              isLoading = true;
                            });

                            await locator();

                            const message = "Loaction Updated";

                            alertComplete(context, message);



                            Future.delayed(Duration(seconds: 1),(){
                              setState(() {
                                isLoading = false;
                              });
                            });
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
  Locator({super.key});

  ChurchInit churchStart = ChurchInit();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(Provider.of<christProvider>(context, listen: false)
                    .myMap['Project']?['Color'] ??
                '0xFF000000')),
        child: Center(
          child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(Provider.of<christProvider>(context, listen: false)
                        .myMap['Project']?['Color'] ??
                    '0xFF000000')),
            child:
                ClipOval(child: xbuildStreamBuilder(context, "ProfileImage")),
          ),
        ),
      ),
    );
  }
}
