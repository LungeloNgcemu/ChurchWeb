import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'componants/buttonChip.dart';
import 'package:image_picker/image_picker.dart' as p;
import 'dart:io';
import 'functions_for_cloud.dart';
import 'product_modal.dart';
import 'url_provider.dart';
import 'componants/global_booking.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

// create_page and poster are linked
class ProductPoster extends StatefulWidget {
  ProductPoster({
    super.key,
  });

  @override
  State<ProductPoster> createState() => _ProductPosterState();
}

class _ProductPosterState extends State<ProductPoster> {
  bool isLoading = false;
  final p.ImagePicker _pickerg = p.ImagePicker();

  p.XFile? _imageh;

  // final sselectedOption = " ";
  String? id;

  Future<void> _pickImage() async {
    final pickedImage = await _pickerg.pickImage(source: p.ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageh = pickedImage;
      });
    }
  }

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  Future<void> superbaseProduct(
      title, description, duration, category, price, image) async {
    //String productImage = await uploadImageToFirebaseStorage(File(image!.path));
    final productImage = await _uploadImageToSuperbase(image);

    print('Inserting');
    await supabase.from('Products').insert({
      'Title': title.toString(),
      'Description': description.toString(),
      'Duration': duration.toString(),
      'Category': category.toString(),
      'Price': price.toString(),
      'ProductImage': productImage,
    });
  }

//  String? imageUrl;

  Future<String> _uploadImageToSuperbase(image) async {
    try {
      print('Image picked');
      if (_imageh != null) {
        final imageFile = File(image!.path);
        final fileName = path.basename(imageFile.path);
        print('File picked: $fileName');

        final String pathv = await supabase.storage.from('SalonStorage').upload(
            '$fileName', imageFile,
            fileOptions:
                const FileOptions(cacheControl: '3600', upsert: false));
        print('Uploaded image path: $pathv');

        final publicUrl =
            await supabase.storage.from('SalonStorage').getPublicUrl(fileName);
        print('Public URL: $publicUrl');

        return publicUrl;
      } else {
        print("No image selected");
        return '';
      }
    } catch (e) {
      print("Error uploading image to Supabase: $e");
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    String selectedOption =
        Provider.of<SelectedOptionProvider>(context).selectedOption;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          height: h * 0.98,
          //   color: Colors.yellow,
          child: Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                            'Create Product',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    EnterText(
                      height: 50.0,
                      text: "Title",
                      inText: "Enter Title",
                      controller: titleController,
                    ),
                    EnterText(
                      height: 50.0,
                      text: "Description",
                      inText: "Enter description",
                      controller: descriptionController,
                    ),
                    EnterText(
                      height: 50.0,
                      text: "Duration",
                      inText: "Enter duration",
                      controller: durationController,
                    ),
                    EnterText(
                      height: 50.0,
                      text: "Price",
                      inText: "Enter price",
                      controller: priceController,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        NewButton(
                          inSideChip: "Load Image for Product",
                          where: () {
                              _pickImage();

                            /// Update state variables here
                          },
                        ),
                        ImageFrame(
                          image: _imageh,
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: NewButton(
                            inSideChip: "Post",
                            where: () async {
                              setState(() {
                                isLoading = true;
                              });
                              final title = titleController.text;
                              final description = descriptionController.text;
                              final duration = durationController.text;
                              final price = priceController.text;

                             await  superbaseProduct(title, description, duration,
                                  selectedOption, price, _imageh);

                              setState(() {
                                isLoading = false;
                              });
                              titleController.clear();
                              descriptionController.clear();
                              priceController.clear();
                              Navigator.of(context)
                                  .pop(); // Close the AlertDialog
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    // Semi-transparent overlay
                    child: const Center(
                      child: SizedBox(
                        height: 100.0,
                        width: 100.0,
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageFrame extends StatefulWidget {
  ImageFrame({this.image, Key? key}) : super(key: key);

  final dynamic image;

  @override
  _ImageFrameState createState() => _ImageFrameState();
}

class _ImageFrameState extends State<ImageFrame> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        height: 145.0,
        width: 145.0,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: _buildImage(widget.image),
      ),
    );
  }

  Widget _buildImage(dynamic image) {
    if (image == null) {
      return Container(); // You can use a placeholder here
    }

    if (image is p.XFile) {
      return Image.file(
        File(image.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250.0,
      );
    } else if (image is File) {
      return Image.file(
        image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 250.0,
      );
    } else {
      return Image.network(
          "https://picsum.photos/seed/picsum/200/300"); // Handle other cases if needed
    }
  }
}

class EnterText extends StatelessWidget {
  const EnterText({
    this.height,
    this.text,
    this.inText,
    this.controller, // Add this line
    Key? key,
  }) : super(key: key);

  final double? height;
  final String? text;
  final String? inText;
  final TextEditingController? controller; // Add this line

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  text!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: height!,
                  child: TextField(
                    controller: controller,
                    // Add this line
                    maxLines: null,
                    expands: true,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                          left: 8.0, bottom: 8.0, top: 8.0),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      // filled: true,
                      hintText: inText ?? "",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
