import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/youtube.dart';
import 'package:master/util/alerts.dart';
import '../../classes/church_init.dart';
import '../../classes/on_create_class.dart';
import '../../componants/chips.dart' as MyChips;
import '../../componants/buttonChip.dart';
import 'package:master/providers/url_provider.dart';
import 'package:provider/provider.dart';
import 'package:master/componants/global_booking.dart';
import 'package:flutter/services.dart';

//TODO product count

// import 'product_card.dart';
import '../../cards/product_selection.dart';
import '../../cards/editable_card.dart' as pro;
import '../../componants/tittle_head.dart';
import 'create_media.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen>
    with AutomaticKeepAliveClientMixin {
  CreateClass create = CreateClass();
  ChurchInit visibility = ChurchInit();
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    Provider.of<SelectedOptionProvider>(context, listen: false)
        .updateSelectedOption('Special', Colors.grey);
    // TODO: implement initState
    super.initState();
  }

  bool modelOpen = false;
  final ScrollController scrollController = ScrollController();
  DraggableScrollableController controller = DraggableScrollableController();
  YouTube youTube = YouTube();
  Authenticate auth = Authenticate();

  Color selectedOp(String selectedOption) {
    if (selectedOption == 'Special') {
      return Colors.green;
    } else if (selectedOption == 'Sermon') {
      return Colors.purple;
    } else if (selectedOption == 'Live') {
      return Colors.orange;
    } else if (selectedOption == 'Study') {
      return Colors.pink;
    } else {
      return Colors.black;
    }
  }

  List<Map<String, dynamic>> optionMedia(
      String selectedOption, List<Map<String, dynamic>> list) {
    List<Map<String, dynamic>> theList = [];

    if (selectedOption == 'Special') {
      for (var item in list) {
        if (item['Category'] == selectedOption) {
          theList.add(item);
        }
      }
      return theList;
    } else if (selectedOption == 'Sermon') {
      for (var item in list) {
        if (item['Category'] == selectedOption) {
          theList.add(item);
        }
      }
      return theList;
    } else if (selectedOption == 'Live') {
      for (var item in list) {
        if (item['Category'] == selectedOption) {
          theList.add(item);
        }
      }
      return theList;
    } else if (selectedOption == 'Study') {
      for (var item in list) {
        if (item['Category'] == selectedOption) {
          theList.add(item);
        }
      }
      return theList;
    } else {
      return theList;
    }
  }

  // Future<void> sheeting2() async {
  //   return await showModalBottomSheet<void>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Sheeting();
  //     },
  //   );
  // }

  // void sheeting(String image, duration, String title, String description,
  //     String productImage, String price) {
  //   Widget _buildBottomSheet(
  //     BuildContext context,
  //     ScrollController scrollController,
  //     double bottomSheetOffset,
  //   ) {
  //     return Sheeting(
  //       description: description,
  //       postTitle: title,
  //       postDuration: duration,
  //       image: productImage,
  //       price: price,
  //       card: ProductCard(
  //           title: title,
  //           description: description,
  //           duration: "Duration :" + duration,
  //           productImage: image,
  //           price: price
  //           // catagory: "4hello",
  //
  //           ),
  //     );
  //   }

  //   showFlexibleBottomSheet(
  //     minHeight: 0,
  //     initHeight: 0.8,
  //     maxHeight: 0.8,
  //     context: context,
  //     builder: _buildBottomSheet,
  //     isExpand: true,
  //     bottomSheetBorderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
  //     bottomSheetColor: Colors.white,
  //   );
  // }

  Stream? productStream;

  Stream load() {
    return supabase
        .from('Procucts')
        .stream(primaryKey: ['id'])
        .eq('Category',
            Provider.of<SelectedOptionProvider>(context).selectedOption)
        .order('id', ascending: false);
  }

  void superbaseStream() {
    productStream = load();
  }

  void deleteVideo(id) async {
    await supabase.from('Media').delete().eq('id', id);

    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    String selectedOption =
        context.watch<SelectedOptionProvider>().selectedOption;
    final idProvider = Provider.of<IdProvider>(context, listen: false);

    debugPrint("here :" + selectedOption);
    // String selectedOption = Provider.of<SelectedOptionProvider>(context, listen: false).selectedOption;
//stream product

    return SafeArea(
      child: Stack(
        children: [
          CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.white54,
                expandedHeight:
                    ChurchInit.visibilityToggle(context) == false ? 140 : 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
                    children: [
                      TittleHead(
                        title: 'Media',
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: 60.0,
                          child: Row(
                            children: [
                              MyChips.Chips(
                                inchip: 'Sermon',
                                isSelected:
                                    Provider.of<SelectedOptionProvider>(context)
                                            .selectedOption ==
                                        'Sermon',
                                onSelected: () {
                                  setState(() {
                                    Provider.of<SelectedOptionProvider>(context,
                                            listen: false)
                                        .updateSelectedOption(
                                            'Sermon', Colors.red);
                                  });
                                },
                              ),
                              MyChips.Chips(
                                inchip: 'Study ',
                                isSelected:
                                    Provider.of<SelectedOptionProvider>(context)
                                            .selectedOption ==
                                        'Study',
                                onSelected: () {
                                  setState(() {
                                    Provider.of<SelectedOptionProvider>(context,
                                            listen: false)
                                        .updateSelectedOption(
                                            'Study', Colors.black);
                                  });
                                },
                              ),
                              MyChips.Chips(
                                stretch: 70.0,
                                inchip: 'Live',
                                isSelected:
                                    Provider.of<SelectedOptionProvider>(context)
                                            .selectedOption ==
                                        'Live',
                                onSelected: () {
                                  setState(() {
                                    Provider.of<SelectedOptionProvider>(context,
                                            listen: false)
                                        .updateSelectedOption(
                                            'Live', Colors.green);
                                  });
                                },
                              ),
                              MyChips.Chips(
                                inchip: 'Special',
                                isSelected:
                                    Provider.of<SelectedOptionProvider>(context)
                                            .selectedOption ==
                                        'Special',
                                onSelected: () {
                                  setState(() {
                                    Provider.of<SelectedOptionProvider>(context,
                                            listen: false)
                                        .updateSelectedOption(
                                            'Special', Colors.grey);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                            Provider.of<christProvider>(context, listen: false)
                                    .myMap['Project']?['Expire'] ??
                                false,
                        child: Visibility(
                          visible: ChurchInit.visibilityToggle(context),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: NewButton(
                                    where: () async {
                                      setState(() {
                                        modelOpen = true;
                                      });

                                      await create.sheeting(
                                          context, MediaPoster());
                                    },
                                    inSideChip: 'Create Video Content',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Provider.of<SelectedOptionProvider>(context).selectedOption
              StreamBuilder(
                stream: supabase
                    .from('Media')
                    .stream(primaryKey: ['id'])
                    .eq(
                        "Church",
                        Provider.of<christProvider>(context, listen: false)
                                .myMap['Project']?['ChurchName'] ??
                            "")
                    .order('id', ascending: false),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                          child: Text('Connecting...'));
                    } else if (!snapshot.hasData ||
                        snapshot.data?.isEmpty == true) {
                      return SliverToBoxAdapter(
                          child: Center(child: Text('No posts available.')));
                    } else {
                      // below is data available

                      final MediaList =
                          optionMedia(selectedOption, snapshot.data ?? []);
                      // final MediaList = snapshot.data;

                      print('List:$MediaList');

                      return SliverPadding(
                        padding: EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            childCount: MediaList?.length,
                            (context, index) {
                              final linkId = youTube
                                  .convertVideo(MediaList?[index]['URL']);
                              idProvider.changeID(linkId);
                              return GestureDetector(
                                onLongPress: () {
                                  if (ChurchInit.visibilityToggle(context) ==
                                      true) {
                                    const message = "Delete Video?";
                                    //delete by id
                                    alertDelete(context, message, () async {
                                      deleteVideo(MediaList?[index]['id']);
                                    });
                                  }
                                },
                                child: youTube.displayYoutubeOnly(linkId,
                                        MediaList?[index]['Title'] ?? "",
                                        MediaList?[index]['Description'] ?? "",
                                        context,)


                                // modelOpen
                                //     ? youTube.displayYoutubeOnly(linkId,
                                //         MediaList?[index]['Title'] ?? "",
                                //         MediaList?[index]['Description'] ?? "",
                                //         context,)
                                //     :
                                //      youTube.playYoutube(
                                //         linkId,
                                //         MediaList?[index]['Title'] ?? "",
                                //         MediaList?[index]['Description'] ?? "",
                                //         context,
                                //       ),


                              );
                            },
                          ),
                        ),
                      );
                    }
                  } else {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100.0),
                        child: Center(child: Text("Loading...")),
                      ),
                    ); // Replace with your custom loading widget
                  }
                },
              ),
            ],
          ),
          Visibility(
            visible: modelOpen,
            child: GestureDetector(
              onTap: () => setState(() {
                modelOpen = false;
              }),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          )
        ],
      ),
    );
  }
}

// class Sheeting extends StatefulWidget {
//   Sheeting(
//       {this.card,
//       this.postTitle,
//       this.postDuration,
//       this.image,
//       this.description,
//       this.price,
//       super.key});
//
//   ProductCard? card;
//
//   String? postTitle;
//   String? postDuration;
//   String? image;
//   String? description;
//   String? price;
//
//   @override
//   State<Sheeting> createState() => _SheetingState();
// }
//
// class _SheetingState extends State<Sheeting> {
//   List<String> listx = [];
//   List<String> listP = [];
//
//   // Future<void> updateList(selectedDay) async {
//   //   List<String> list = await getCurrentList(setState);
//   //   List<String> goodx = await matrixRevolution(selectedDay, list, setState);
//   //   setState(() {
//   //     listP = goodx;
//   //     listx = list;
//   //     isLoading = false;
//   //   });
//   // }
//
//   Future<void> updateList(selectedDay) async {
//     List<String> list = await getCurrentList(setState);
//
//     print('Good');
//     //from supabase
//     List<String> goodx = await revolution_matrix(selectedDay, list, setState);
//     setState(() {
//       listP = goodx;
//       listx = list;
//       isLoading = false;
//     });
//   }
//
//   bool isLoading = false;
//
//   TextEditingController controllerName = TextEditingController();
//   TextEditingController controllerContact = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.vertical,
//       child: Padding(
//         padding: const EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             const Text(
//               "Product for Booking",
//               style: TextStyle(
//                 fontSize: 22.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             widget.card ?? Container(),
//             // const ProductCard(),
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
//               child: Row(
//                 children: [
//                   Text("1. Enter Client Name"),
//                 ],
//               ),
//             ),
//             ForTextInput(
//               controller: controllerName,
//               label: "Client Name",
//               text: "Enter Clients Name",
//               con: Icons.person,
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
//               child: Row(
//                 children: [
//                   Text("2. Enter Clients Contact"),
//                 ],
//               ),
//             ),
//             ForTextInput(
//               controller: controllerContact,
//               label: "Clients Contact",
//               text: "Enter Clients Contact",
//               con: Icons.phone_rounded,
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
//               child: Row(
//                 children: [
//                   Text("3. Select Day for Client"),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20.0),
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8.0),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.grey,
//                         spreadRadius: 0.1,
//                         blurRadius: 10.0,
//                       )
//                     ]),
//                 child: here.TableCalendar(
//                   firstDay: DateTime.utc(2010, 10, 16),
//                   lastDay: DateTime.utc(2030, 3, 14),
//                   focusedDay: DateTime.now(),
//                   selectedDayPredicate: (day) {
//                     return here.isSameDay(selectedDay, day);
//                   },
//                   onDaySelected: (sselectedDay, focusedDay) {
//                     setState(() {
//                       isLoading = true;
//                       selectedDay = sselectedDay;
//                       focusedDay = focusedDay;
//                     });
//                     updateList(selectedDay);
//                     //
//                     // setState(()  {
//                     //   selectedDay = sselectedDay;
//                     //   focusedDay = focusedDay;
//                     // });
//                     // List<String> list = await getCurrentList(setState);
//                     // List<String> goodx = await matrixRevolution(selectedDay,list,setState);
//                     // setState(() {
//                     //   listP = goodx;
//                     //   listx = list;
//                     // });
//                   },
//                   calendarFormat: calendarFormat,
//                   onFormatChanged: (format) {
//                     setState(() {
//                       calendarFormat = format;
//                     });
//                   },
//                 ),
//               ),
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
//               child: Row(
//                 children: [
//                   Text("4. Select Time for Client"),
//                 ],
//               ),
//             ),
//             isLoading
//                 ? SizedBox(
//                     height: 150,
//                     child: Center(child: CircularProgressIndicator()))
//                 : book_blue_print(
//                     selectedDay,
//                     listP,
//                     isSelected,
//                     listx,
//                     specificAll,
//                     setState,
//                     widget.postTitle ?? "",
//                     widget.postDuration ?? "",
//                     widget.image ?? "",
//                     widget.description ?? "",
//                     controllerName.text ?? '',
//                     controllerContact.text ?? '',
//                     widget.price ?? ''),
//             ElevatedButton(
//               child: const Text('Close BottomSheet'),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
