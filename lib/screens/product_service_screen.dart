import 'package:flutter/material.dart';
import 'package:master/screens/salon_screen.dart';
import '../componants/chips.dart' as MyChips;
import '../componants/buttonChip.dart';
import 'package:master/cards/product_card.dart';
import 'package:master/product_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:master/url_provider.dart';
import 'package:provider/provider.dart';
import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:master/componants/text_input.dart';
import 'package:master/componants/global_booking.dart';
import 'package:table_calendar/table_calendar.dart' as here;

//TODO product count

// import 'product_card.dart';
import '../cards/product_selection.dart';
import '../cards/editable_card.dart' as pro;

class ProductandServiveBody extends StatefulWidget {
  const ProductandServiveBody({super.key});

  @override
  State<ProductandServiveBody> createState() => _ProductandServiveBodyState();
}

class _ProductandServiveBodyState extends State<ProductandServiveBody> {
  // String selectedOption = "Other";
  // DateTime _selectedDay = DateTime.now();
  // DateTime _focusedDay = DateTime.now();
  // List<String>? _currentList;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   String selectedOption = "Other";
  //   super.initState();
  // }
  //  bool isSelected = true;
  @override
  void initState() {
   // superbaseStream();
    bookingTime = bookingTime30;
    currentList = selectedBookDday(selectedDay, bookingTime, setState);
    // TODO: implement initState
    super.initState();
  }

  Products convertToProduct(Map<String, dynamic> map) {
    return Products(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      productImage: map['productImage'] ?? '',
      duration: map['duration'] ?? '',
      price: map['price'] ?? '',
      category: map['category'] ?? '',
    );
  }

  List<Products> convertToProductsList(
      List<QueryDocumentSnapshot<Object?>>? querySnapshots) {
    if (querySnapshots == null) return [];

    return querySnapshots.map((snapshot) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      return convertToProduct(data);
    }).toList();
  }

  Products products = Products();

  Stream<QuerySnapshot> getProductsStream(a) {
    return FirebaseFirestore.instance
        .collection("Products")
        .doc(a)
        .collection("Item")
        .snapshots();
  }

  Color selectedOp(String selectedOption) {
    if (selectedOption == 'HairCut') {
      return Colors.green;
    } else if (selectedOption == 'HairWash') {
      return Colors.purple;
    } else if (selectedOption == 'Braids') {
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

  void sheeting(String image, duration, String title, String description,
      String productImage, String price) {
    Widget _buildBottomSheet(
      BuildContext context,
      ScrollController scrollController,
      double bottomSheetOffset,
    ) {
      return Sheeting(
        description: description,
        postTitle: title,
        postDuration: duration,
        image: productImage,
        price: price,
        card: ProductCard(
            title: title,
            description: description,
            duration: "Duration :" + duration,
            productImage: image,
            price: price
            // catagory: "4hello",

            ),
      );
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
    return  supabase.from('Procucts').stream(primaryKey: ['id']).eq('Category',  Provider.of<SelectedOptionProvider>(context).selectedOption).order('id', ascending: false);
  }

  void superbaseStream(){
    productStream = load();
  }


  @override
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
            backgroundColor:Colors.white12 ,
            expandedHeight: 330,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 8.0,
                      right: 8.0,
                      top: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              height: 50.0,
                              width: 50.0,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text(
                                'Create Products & Services',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 23.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        child: Text(
                          '1. Select Product Type',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 23.0,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: 60.0,
                      child: Row(
                        children: [
                          MyChips.Chips(
                            inchip: 'HairCut',
                            isSelected:
                                Provider.of<SelectedOptionProvider>(context)
                                        .selectedOption ==
                                    'HairCut',
                            onSelected: () {
                              setState(() {
                                Provider.of<SelectedOptionProvider>(context,
                                        listen: false)
                                    .updateSelectedOption(
                                        'HairCut', Colors.red);
                              });
                            },
                          ),
                          MyChips.Chips(
                            inchip: 'HairWash ',
                            isSelected:
                                Provider.of<SelectedOptionProvider>(context)
                                        .selectedOption ==
                                    'HairWash',
                            onSelected: () {
                              setState(() {
                                Provider.of<SelectedOptionProvider>(context,
                                        listen: false)
                                    .updateSelectedOption(
                                        'HairWash', Colors.black);
                              });
                            },
                          ),
                          MyChips.Chips(
                            stretch: 70.0,
                            inchip: 'Braids',
                            isSelected:
                                Provider.of<SelectedOptionProvider>(context)
                                        .selectedOption ==
                                    'Braids',
                            onSelected: () {
                              setState(() {
                                Provider.of<SelectedOptionProvider>(context,
                                        listen: false)
                                    .updateSelectedOption(
                                        'Braids', Colors.green);
                              });
                            },
                          ),
                          MyChips.Chips(
                            inchip: 'Face',
                            isSelected:
                                Provider.of<SelectedOptionProvider>(context)
                                        .selectedOption ==
                                    'Face',
                            onSelected: () {
                              setState(() {
                                Provider.of<SelectedOptionProvider>(context,
                                        listen: false)
                                    .updateSelectedOption('Face', Colors.grey);
                              });
                            },
                          ),
                          MyChips.Chips(
                            inchip: 'Nails',
                            isSelected: selectedOption == 'Nails',
                            onSelected: () {
                              setState(() {
                                Provider.of<SelectedOptionProvider>(context,
                                        listen: false)
                                    .updateSelectedOption(
                                        'Nails', Colors.purple);
                              });
                            },
                          ),
                          MyChips.Chips(
                            inchip: 'Makeup',
                            isSelected:
                                Provider.of<SelectedOptionProvider>(context)
                                        .selectedOption ==
                                    'Makeup',
                            onSelected: () {
                              setState(() {
                                Provider.of<SelectedOptionProvider>(context,
                                        listen: false)
                                    .updateSelectedOption(
                                        'Makeup', Colors.blueAccent);
                              });
                            },
                          ),
                          MyChips.Chips(
                            inchip: 'Other',
                            isSelected:
                                Provider.of<SelectedOptionProvider>(context)
                                        .selectedOption ==
                                    'Other',
                            onSelected: () {
                              setState(() {
                                Provider.of<SelectedOptionProvider>(context,
                                        listen: false)
                                    .updateSelectedOption(
                                        'Other', Colors.orange);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 8.0),
                        child: Text(
                          '2. Create Product',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 23.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: NewButton(
                            where: () {
                              Navigator.pushNamed(context, '/productPoster');
                              // Optionally clear the text field after adding
                              // (You might choose to leave it as-is)
                              setState(() {});
                            },
                            inSideChip: 'Create Product',
                          ),
                        ),
                      ],
                    ),
                  ),
                  /////////////////////////////////////////////////////////////////////////////////////////////////
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                    child: Text(
                      'View Products Below',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 23.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /////////////////////////////////////////////////////

          //      ProductCard(),
          // ProductCard(),
          // selectedOption == 'HairCut' ? const Haircut() : Container(),
          // selectedOption == 'HairWash' ? const HairWash() : Container(),
          // selectedOption == 'Braids' ? const Braids() : Container(),
          // selectedOption == 'Face' ? const Face() : Container(),
          StreamBuilder(
            stream:supabase.from('Products').stream(primaryKey: ['id']).eq('Category',  Provider.of<SelectedOptionProvider>(context).selectedOption).order('id', ascending: false),
            builder: (context,snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                      child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    snapshot.data?.isEmpty == true) {
                  return SliverToBoxAdapter(child: Text('No posts available.'));
                } else {
                  // below is data available
                  final productsList = snapshot.data;
                  return SliverPadding(
                    padding: EdgeInsets.all(20),
                    sliver: SliverList(delegate: SliverChildBuilderDelegate(
                      childCount:productsList?.length,
                      (context, index) {

                        return GestureDetector(
                          onDoubleTap: () async {
                            await supabase.from('Products').delete().match({ 'id': productsList?[index]['id'] });
                          },
                          child: pro.EditableProductCard(
                            image: productsList?[index]['ProductImage'] ?? '',
                            tag: selectedOp(
                                Provider.of<SelectedOptionProvider>(context)
                                    .selectedOption),
                            title:productsList?[index]['Title'] ?? '',
                            description: productsList?[index]['Description'] ?? '',
                            duration: productsList?[index]['Duration'] ?? '',
                            price: productsList?[index]['Price'] ?? '',
                            where: () {
                              getBookings();
                              sheeting(
                                productsList?[index]['ProductImage'] ?? '',
                                productsList?[index]['Duration'] ?? '',
                                productsList?[index]['Title'] ?? '',
                                productsList?[index]['Description'] ?? '',
                                productsList?[index]['ProductImage'] ?? '',
                                productsList?[index]['Price'] ?? '',
                              );
                            },
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
                    child: Center(child: Text("Loading...")),
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

  Future<void> updateList(selectedDay) async {
    List<String> list = await getCurrentList(setState);
    List<String> goodx = await matrixRevolution(selectedDay, list, setState);
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
                : bookerBooker(
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
