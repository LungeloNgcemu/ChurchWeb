import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event_calendar/flutter_event_calendar.dart';
import 'package:master/classes/authentication/authenticate.dart';
import 'package:master/classes/calender_class.dart';
import 'package:master/classes/church_init.dart';
import 'package:master/screens/home/church_screen.dart';
import 'package:master/util/alerts.dart';
import '../../classes/on_create_class.dart';
import '../../componants/chips.dart' as MyChips;
import '../../componants/buttonChip.dart';
import 'package:master/cards/product_card.dart';
import 'package:master/providers/url_provider.dart';
import 'package:provider/provider.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:master/componants/text_input.dart';
import 'package:master/componants/global_booking.dart';
import 'package:table_calendar/table_calendar.dart' as here;

//TODO product count

// import 'product_card.dart';
import '../../cards/product_selection.dart';
import '../../cards/editable_card.dart' as pro;
import '../../componants/tittle_head.dart';
import 'create_event.dart';
import '../media/fullscreen.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> with AutomaticKeepAliveClientMixin {
  Calender calenderClass = Calender();
  CreateClass create = CreateClass();
  ChurchInit visibility = ChurchInit();
  ScrollController scrollController = ScrollController();
  DraggableScrollableController controller = DraggableScrollableController();

  Authenticate auth = Authenticate();

  CalendarDateTime? selectedDate;

  void _onDateChanged(CalendarDateTime date) {
    setState(() {
      selectedDate = date;
    });
    print("Selected date: ${date.year}-${date.month}-${date.day}");
  }

  void initState() {
    // superbaseStream();
    bookingTime = bookingTime30;
    currentList = selectedBookDday(selectedDay, bookingTime, setState);
    // TODO: implement initState
    super.initState();
  }




  Color selectedOp(String selectedOption) {
    if (selectedOption == 'Upcoming') {
      return Colors.green;
    } else if (selectedOption == 'Canceled') {
      return Colors.purple;
    } else if (selectedOption == 'Completed') {
      return Colors.orange;
    } else if (selectedOption == 'Face') {
      return Colors.pink;
    } else {
      return Colors.black;
    }
  }

  Future<void> sheeting2() async {
    return await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Sheeting();
      },
    );
  }

  void sheeting() {
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

  @override
   bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    String selectedOption =
        context.watch<SelectedOptionProvider>().selectedOption;

    debugPrint("here :" + selectedOption);
    // String selectedOption = Provider.of<SelectedOptionProvider>(context, listen: false).selectedOption;
//stream product

    return SafeArea(
      child: CustomScrollView(
        scrollDirection: Axis.vertical,
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white12,
            automaticallyImplyLeading: false,
            expandedHeight:
                visibility.visibilityToggle(context) == false ? 80 : 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  TittleHead(
                    title: 'Events',
                  ),
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: SizedBox(
                  //     height: 60.0,
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //       children: [
                  //         MyChips.Chips(
                  //           inchip: 'Upcoming',
                  //           isSelected:
                  //           Provider
                  //               .of<SelectedOptionProvider>(context)
                  //               .selectedOption ==
                  //               'Upcoming',
                  //           onSelected: () {
                  //             setState(() {
                  //               Provider.of<SelectedOptionProvider>(context,
                  //                   listen: false)
                  //                   .updateSelectedOption(
                  //                   'Upcoming', Colors.red);
                  //             });
                  //           },
                  //         ),
                  //         MyChips.Chips(
                  //           inchip: 'Completed ',
                  //           isSelected:
                  //           Provider
                  //               .of<SelectedOptionProvider>(context)
                  //               .selectedOption ==
                  //               'Completed',
                  //           onSelected: () {
                  //             setState(() {
                  //               Provider.of<SelectedOptionProvider>(context,
                  //                   listen: false)
                  //                   .updateSelectedOption(
                  //                   'Completed', Colors.black);
                  //             });
                  //           },
                  //         ),
                  //         MyChips.Chips(
                  //           inchip: 'Canceled ',
                  //           isSelected:
                  //           Provider
                  //               .of<SelectedOptionProvider>(context)
                  //               .selectedOption ==
                  //               'Canceled',
                  //           onSelected: () {
                  //             setState(() {
                  //               Provider.of<SelectedOptionProvider>(context,
                  //                   listen: false)
                  //                   .updateSelectedOption(
                  //                   'Canceled', Colors.black);
                  //             });
                  //           },
                  //         ),
                  //
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //       vertical: 5.0, horizontal: 8),
                  //   child: calenderClass.calenderReturn(_onDateChanged),
                  // ),
                  Visibility(
                    visible: Provider.of<christProvider>(context, listen: false)
                            .myMap['Project']?['Expire'] ??
                        false,
                    child: Visibility(
                      visible: visibility.visibilityToggle(context),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: NewButton(
                                where: () {
                                  create.sheeting(context, CreateEvent());
                                  // Navigator.pushNamed(context, '/productPoster');
                                  // Optionally clear the text field after adding
                                  // (You might choose to leave it as-is)
                                },
                                inSideChip: 'Create Event',
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

//  stream:supabase.from('Events').stream(primaryKey: ['id']).eq('Category',  Provider.of<SelectedOptionProvider>(context).selectedOption).order('id', ascending: false),
          StreamBuilder(
            stream: supabase.from('Events').stream(primaryKey: ['id']).eq(
                'ChurchName',
                Provider.of<christProvider>(context, listen: false)
                    .myMap['Project']?['ChurchName']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                      child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    snapshot.data?.isEmpty == true) {
                  return SliverToBoxAdapter(
                      child: Center(child: Text('No posts available.')));
                } else {
                  // below is data available
                  final productsList = snapshot.data;
                  return SliverPadding(
                    padding: EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: productsList?.length,
                        (context, index) {
                          return GestureDetector(
                            onLongPress: () async {
                              print("Tapped");
                              if (visibility.visibilityToggle(context) ==
                                  true) {
                                Future<void> delete() async {
                                  await supabase.from('Events').delete().match(
                                      {'id': productsList?[index]['id']});
                                }

                                const message = "Delete Event";
                                alertDelete(context, message, () async {
                                  await delete();
                                });
                              } else {
                                print("Not admin");
                              }
                            },
                            child: pro.EditableProductCard(
                              image: productsList?[index]['Image'] ?? '',
                              tag: selectedOp(
                                  Provider.of<SelectedOptionProvider>(context)
                                      .selectedOption),
                              title: productsList?[index]['Title'] ?? '',
                              description:
                                  productsList?[index]['Description'] ?? '',
                              day: productsList?[index]['Day'] ?? '',
                            ),
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
                    child: Center(child: Center(child: Text("Loading..."))),
                  ),
                ); // Replace with your custom loading widget
              }
            },
          ),
        ],
      ),
    );
  }
}

class Sheeting extends StatefulWidget {
  Sheeting(
      {this.card,
      this.postTitle,
      this.postDuration,
      this.image,
      this.description,
      this.price,
      super.key});

  ProductCard? card;

  String? postTitle;
  String? postDuration;
  String? image;
  String? description;
  String? price;

  @override
  State<Sheeting> createState() => _SheetingState();
}

class _SheetingState extends State<Sheeting> {
  List<String> listx = [];
  List<String> listP = [];

  // Future<void> updateList(selectedDay) async {
  //   List<String> list = await getCurrentList(setState);
  //   List<String> goodx = await matrixRevolution(selectedDay, list, setState);
  //   setState(() {
  //     listP = goodx;
  //     listx = list;
  //     isLoading = false;
  //   });
  // }

  Future<void> updateList(selectedDay) async {
    List<String> list = await getCurrentList(setState);

    print('Good');
    //from supabase
    List<String> goodx = await revolution_matrix(selectedDay, list, setState);
    setState(() {
      listP = goodx;
      listx = list;
      isLoading = false;
    });
  }

  bool isLoading = false;

  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerContact = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0, left: 10.0, right: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text(
              "Product for Booking",
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            widget.card ?? Container(),
            // const ProductCard(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              child: Row(
                children: [
                  Text("1. Enter Client Name"),
                ],
              ),
            ),
            ForTextInput(
                keyboard: TextInputType.text,
              controller: controllerName,
              label: "Client Name",
              text: "Enter Clients Name",
              con: Icons.person,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              child: Row(
                children: [
                  Text("2. Enter Clients Contact"),
                ],
              ),
            ),
            ForTextInput(
                keyboard: TextInputType.number,
              controller: controllerContact,
              label: "Clients Contact",
              text: "Enter Clients Contact",
              con: Icons.phone_rounded,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              child: Row(
                children: [
                  Text("3. Select Day for Client"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 0.1,
                        blurRadius: 10.0,
                      )
                    ]),
                child: here.TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: DateTime.now(),
                  selectedDayPredicate: (day) {
                    return here.isSameDay(selectedDay, day);
                  },
                  onDaySelected: (sselectedDay, focusedDay) {
                    setState(() {
                      isLoading = true;
                      selectedDay = sselectedDay;
                      focusedDay = focusedDay;
                    });
                    updateList(selectedDay);
                    //
                    // setState(()  {
                    //   selectedDay = sselectedDay;
                    //   focusedDay = focusedDay;
                    // });
                    // List<String> list = await getCurrentList(setState);
                    // List<String> goodx = await matrixRevolution(selectedDay,list,setState);
                    // setState(() {
                    //   listP = goodx;
                    //   listx = list;
                    // });
                  },
                  calendarFormat: calendarFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      calendarFormat = format;
                    });
                  },
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
              child: Row(
                children: [
                  Text("4. Select Time for Client"),
                ],
              ),
            ),
            isLoading
                ? SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()))
                : book_blue_print(
                    selectedDay,
                    listP,
                    isSelected,
                    listx,
                    specificAll,
                    setState,
                    widget.postTitle ?? "",
                    widget.postDuration ?? "",
                    widget.image ?? "",
                    widget.description ?? "",
                    controllerName.text ?? '',
                    controllerContact.text ?? '',
                    widget.price ?? ''),
            ElevatedButton(
              child: const Text('Close BottomSheet'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
