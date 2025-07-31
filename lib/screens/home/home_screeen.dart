import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart%20';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/church_init.dart';
import 'package:master/classes/home_class.dart';
import 'package:provider/provider.dart';
import 'widgets/about_us.dart';
import '../../classes/on_create_class.dart';
import '../../componants/chips.dart' as MyChips;
import '../../componants/minister.dart';
import 'package:master/screens/home/widgets/map.dart' as location;
import '../../providers/url_provider.dart';
import 'create_minister.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  HomeClass homeClass = HomeClass();
  CreateClass create = CreateClass();
  ChurchInit visbibity = ChurchInit();
  Authenticate auth = Authenticate();
  ScrollController scrollController = ScrollController();
  DraggableScrollableController controller = DraggableScrollableController();

  String selectedOption = 'About Us';

  @override
  void initState() {
    _initChurch();
    // snackInit();

    super.initState();
  }

  Future<void> _initChurch() async {
    ChurchInit churchStart = ChurchInit();
    Authenticate auth = Authenticate();

    await churchStart.init(context);
    final message = " Welcome to Church Connect";
    homeClass.ministerInit(setState, context);
    // auth.alertWelcome(context, message) ;// Wait for the initialization to complete

    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;

  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Column(
      //mainAxisAlignment: MainAxisAlignment.spaceBe,
      children: [
        Stack(
          children: <Widget>[
            // buildStreamBuilder(context, "FrontImage"),
            Container(
              color: Colors.grey[100],
              height: h * 0.2796,
              width: double.maxFinite,
              child: Image.asset("lib/images/clear.png"),
              // child: homeClass.xbuildStreamBuilder(context, 'FrontImage'),
            ),
            // Positioned(
            //   top: 210.0,
            //   left: 375.0,
            //   child: Visibility(
            //     visible: visbibity.visibilityToggle(context),
            //     child: GestureDetector(
            //       onTap: () async {
            //         homeClass.uploadImageToSuperbase('FrontImage', context);
            //         // final imagex = await _uploadImageToFirebase();
            //         // uploadForSalon("FrontImage", imagex);
            //       },
            //       child: Container(
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(5.0),
            //           color: Colors.orange,
            //         ),
            //         child: const Padding(
            //           padding: EdgeInsets.all(1.0),
            //           child: Icon(Icons.edit, color: Colors.white),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            top: 8.0,
          ),
          child: Container(
            // color: Colors.red,
            height: h * 0.625,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.church),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          Provider.of<christProvider>(context, listen: false)
                                  .myMap['Project']?['ChurchName'] ??
                              "Loading...",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    // textB.locataseline: TextBaseline.alphabetic,
                    children: [
                      Icon(Icons.location_pin),
                      // const Padding(
                      //   padding: EdgeInsets.only(
                      //     right: 8.0,
                      //     top: 12.0,
                      //   ),
                      //   child: Icon(Icons.add_location,size: 15,),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          Provider.of<christProvider>(context, listen: false)
                                  .myMap['Project']?['Address'] ??
                              "Loading...",
                          softWrap: true,
                          style: TextStyle(fontSize: 15.0),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ministers',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Visibility(
                          visible: Provider.of<christProvider>(context,
                                      listen: false)
                                  .myMap['Project']?['Expire'] ??
                              false,
                          child: Visibility(
                            visible: visbibity.visibilityToggle(context),
                            child: TextButton(
                              onPressed: () {
                                create.sheeting(context, CreateMinister());
                                // Navigator.pushNamed(context, '/edit');
                              },
                              child: const Text('Create Minister'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    height: h * 0.182,
                    child: StreamBuilder(
                      stream: homeClass.minister,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return SizedBox();
                          case ConnectionState.waiting:
                            return SizedBox();
                          case ConnectionState.active:
                            if (snapshot.hasError) {
                              print('Has Error');
                            } else if (!snapshot.hasData) {
                              print('NO data here');
                            } else if (snapshot.hasData) {
                              // List<dynamic> specs = [];

                              final specs = snapshot.data;
                              print('THIS ministers $specs');

                              return SizedBox(
                                height: 150.0,
                                width: w * 0.9611,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: specs.length,
                                  itemBuilder: (context, index) {
                                    return Minister(
                                        tap: () {
                                          homeClass.delete('Minister',
                                              specs[index]['id']);
                                        },
                                        name: specs[index]['Name'],
                                        work: specs[index]['Work'],
                                        image: specs[index]['Image']);
                                  },
                                ),
                              );
                            }
                          case ConnectionState.done:
                            return SizedBox();
                        }
                        return SizedBox();
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible:
                            Provider.of<christProvider>(context, listen: false)
                                    .myMap['Project']?['Expire'] ??
                                false,
                        child: Visibility(
                          visible: visbibity.visibilityToggle(context),
                          child: TextButton(
                              onPressed: () {
                                homeClass.galleryInsert(context, setState);
                              },
                              child: Text('Upload Images')),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 50.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        MyChips.Chips(
                          inchip: 'About Us',
                          isSelected: selectedOption == 'About Us',
                          onSelected: () {
                            setState(() {
                              selectedOption = 'About Us';
                            });
                          },
                        ),
                        MyChips.Chips(
                          inchip: 'Gallery',
                          isSelected: selectedOption == 'Gallery',
                          onSelected: () {
                            setState(() {
                              selectedOption = 'Gallery';
                            });
                          },
                        ),
                        MyChips.Chips(
                          inchip: 'Map',
                          isSelected: selectedOption == 'Map',
                          onSelected: () {
                            setState(() {
                              selectedOption = 'Map';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  selectedOption == 'About Us' ? AboutUs() : Container(),
                  selectedOption == 'Gallery'
                      ? homeClass.buildGallery(context)
                      : Container(),
                  selectedOption == 'Map' ? location.Map() : Container(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
