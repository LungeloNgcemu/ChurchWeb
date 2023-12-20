import 'package:flutter/material.dart';
import 'package:master/screens/users.dart';
import 'package:readmore/readmore.dart';
import 'package:master/screens/post_screen.dart';
import '../about_us.dart';
import '../gallery.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'product_service_screen.dart';
import '../componants/chips.dart' as MyChips;
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:booking_calendar/booking_calendar.dart';
import 'booking_screen.dart';
import 'info_book_screen.dart';
import 'users.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:master/url_provider.dart';
import 'package:provider/provider.dart';
import 'package:master/url_provider.dart';
import 'package:flutter/widgets.dart';

String? selectedOption;

class SalonScreen extends StatefulWidget {
  const SalonScreen({super.key});

  @override
  State<SalonScreen> createState() => _SalonScreenState();
}

class _SalonScreenState extends State<SalonScreen> {
  final PageController controller = PageController();
  int visit = 0;
  bool isVisble = false;
  List<TabItem> items = const [
    TabItem(
      icon: Icons.home_filled,
      title: 'Edit Home Page',
    ),
    TabItem(
      icon: Icons.post_add,
      title: 'Create Posts',
    ),
    TabItem(
      icon: Icons.shopping_cart_outlined,
      title: 'Create Products',
    ),
    TabItem(
      icon: Icons.add,
      title: 'Create Slots',
    ),
    TabItem(
      icon: Icons.book,
      title: 'Bookings',
    ),
    // TabItem(
    //   icon: Icons.chat,
    //   title: 'Chat',
    // ),
    TabItem(
      icon: Icons.people_alt_outlined,
      title: 'Users',
    ),
  ];

  final List<Widget> _pages = const [
    SalonBody(),
    PostScreen(),
    ProductandServiveBody(),
    BookingScreen(),
    InfoBook(),
    UsersBody(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        scrollDirection: Axis.horizontal,
        onPageChanged: (index) {
          setState(() {
            visit = index;
            (context as Element).markNeedsBuild();
          });
        },
        controller: controller,
        children: _pages,
      ),
      bottomNavigationBar: BottomBarFloating(
        items: items,
        backgroundColor: Colors.white,
        color: Colors.black,
        colorSelected: Colors.red,
        indexSelected: visit,
        paddingVertical: 8,
        onTap: (int index) => setState(() {
          visit = index;
          controller.animateToPage(index,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        }),
      ),
    );
  }
}

class SalonBody extends StatefulWidget {
  const SalonBody({super.key});

  @override
  State<SalonBody> createState() => _SalonBodyState();
}

class _SalonBodyState extends State<SalonBody> {
  @override
  void initState() {
    super.initState();
    Provider.of<ImageUrlProvider>(context, listen: false).loadImageUrlLocally();
  }

  final ImagePicker _picker = ImagePicker();
  XFile? _image; // Change PickedFile to XFile
  String? imageUrl;

  Future<void> _pickImage() async {
    _image = await _picker.pickImage(source: ImageSource.gallery) as XFile?;
    // Handle the picked image as needed
  }

  Future<void> _uploadImageToFirebase() async {
    try {
      await _pickImage();

      if (_image != null) {
        File imageFile = File(_image!.path);
        String fileName = path.basename(imageFile.path);

        firebase_storage.Reference ref = firebase_storage
            .FirebaseStorage.instance
            .ref()
            .child("images")
            .child(fileName);

        var metadata = firebase_storage.SettableMetadata(
          contentType:
              'image/jpeg', // Set the correct content type based on your image type
        );

        await ref.putFile(imageFile, metadata);

        imageUrl = await ref.getDownloadURL(); // Update state variable
        Provider.of<ImageUrlProvider>(context, listen: false).imageUrl =
            imageUrl;

        print("Image uploaded to Firebase: $imageUrl");

        setState(() {}); // Trigger a rebuild to update the UI
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error uploading image to Firebase: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: Provider.of<ImageUrlProvider>(context).imageUrl ??
                    'lib/images/hairs.jpg',
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    height: 40.0,
                    width: 40.0,
                    child: CircularProgressIndicator(
                      value: 1.0,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
                fit: BoxFit.cover,
                height: 250,
                width: double.maxFinite,
              ),
              Positioned(
                top: 210.0,
                left: 375.0,
                child: GestureDetector(
                  onTap: () async {
                    await _pickImage(); // Ensure an image is picked before attempting to upload
                    _uploadImageToFirebase();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.orange,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(1.0),
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              top: 8.0,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Salon',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    MaterialButton(
                      elevation: 0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      color: Colors.orange,
                      onPressed: () {
                        // Navigator.pushNamed(context, '/products');
                      },
                      child: const Text('Edit Page'),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        right: 8.0,
                        top: 8.0,
                      ),
                      child: Icon(Icons.add_location),
                    ),
                    Text(
                      '43 Andron Street Cresend',
                    )
                  ],
                ),
                //this is the row with icons
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconText(
                      iconimage: Icon(Icons.web),
                      icontext: Text('Website'),
                    ),
                    IconText(
                      iconimage: Icon(Icons.message),
                      icontext: Text('Message'),
                    ),
                    IconText(
                      iconimage: Icon(Icons.phone_rounded),
                      icontext: Text('Call'),
                    ),
                    IconText(
                      iconimage: Icon(Icons.location_on_rounded),
                      icontext: Text('Direction'),
                    ),
                    IconText(
                      iconimage: Icon(Icons.share_outlined),
                      icontext: Text('Share'),
                    ),
                  ],
                ),

                // We continue to next section
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Our Specialist',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    height: 135.0,
                    child: Row(
                      children: [
                        Specialist(),
                        Specialist(),
                        Specialist(),
                        Specialist(),
                        Specialist(),
                        Specialist(),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 70.0,
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
                    ],
                  ),
                ),
                selectedOption == 'About Us' ? const AboutUs() : Container(),
                selectedOption == 'Gallery' ? const Gallery() : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StartLeftText extends StatelessWidget {
  const StartLeftText({
    this.wait,
    this.call,
    super.key,
  });

  final FontWeight? wait;
  final String? call;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$call',
          style: TextStyle(
            fontWeight: wait ?? FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class Specialist extends StatelessWidget {
  const Specialist({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 0.1,
                blurRadius: 10.0,
              )
            ]),
        height: 129.0,
        width: 97.0,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                height: 70.0,
                width: 70.0,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 5.0),
              child: Text(
                'Name',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Text('Stylist'),
          ],
        ),
      ),
    );
  }
}

class IconText extends StatelessWidget {
  const IconText({super.key, this.iconimage, this.icontext});

  final Icon? iconimage;
  final Text? icontext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, right: 15.0),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: IconButton(onPressed: () {}, icon: iconimage!),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: icontext!,
          )
        ],
      ),
    );
  }
}
