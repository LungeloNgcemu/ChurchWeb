import 'package:flutter/material.dart';
import '../componants/chips.dart' as MyChips;
// import 'product_card.dart';
import '../cards/product_selection.dart';
import '../cards/editable_card.dart';
// class ProductsServices extends StatefulWidget {
//   const ProductsServices({super.key});
//
//   @override
//   State<ProductsServices> createState() => _ProductsServicesState();
// }
//
// class _ProductsServicesState extends State<ProductsServices> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child:
//       ),
//     );
//   }
// }

class ProductandServiveBody extends StatefulWidget {
  const ProductandServiveBody({super.key});

  @override
  State<ProductandServiveBody> createState() => _ProductandServiveBodyState();
}

class _ProductandServiveBodyState extends State<ProductandServiveBody> {
  //  bool isSelected = true;
  String selectedOption = 'HairCut';
  // String? selectedOption;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
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
                            padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 8.0),
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
            //  Padding(
            //    padding: const EdgeInsets.only(left:8.0),
            //    child: Row(
            //      children: [
            //        MaterialButton(
            //                 elevation: 0,
            //                 shape: const RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.all(
            //                     Radius.circular(20.0),
            //                   ),
            //                 ),
            //                 color: Colors.orange,
            //                 onPressed: () {
            //                   // Navigator.pushNamed(context, '/products');
            //                 },
            //                 child: const Text('Create Products',),
            //               ),
            //      ],
            //    ),
            //  ),
            
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                height: 60.0,
                child: Row(
                  children: [
                    MyChips.Chips(
                      inchip: 'HairCut',
                      isSelected: selectedOption == 'HairCut',
                      onSelected: () {
                        setState(() {
                          selectedOption = 'HairCut';
                        });
                      },
                    ),
                    MyChips.Chips(
                      inchip: 'HairWash ',
                      isSelected: selectedOption == 'HairWash',
                      onSelected: () {
                        setState(() {
                          selectedOption = 'HairWash';
                        });
                      },
                    ),
                    MyChips.Chips(
                      stretch: 70.0,
                      inchip: 'Braids',
                      isSelected: selectedOption == 'Braids',
                      onSelected: () {
                        setState(() {
                          selectedOption = 'Braids';
                        });
                      },
                    ),
                    MyChips.Chips(
                      inchip: 'Face',
                      isSelected: selectedOption == 'Face',
                      onSelected: () {
                        setState(() {
                          selectedOption = 'Face';
                        });
                      },
                    ),
                    MyChips.Chips(
                      inchip: 'Nails',
                      isSelected: selectedOption == 'Nails',
                      onSelected: () {
                        setState(() {
                          selectedOption = 'Nails';
                        });
                      },
                    ),
                    MyChips.Chips(
                      inchip: 'Makeup',
                      isSelected: selectedOption == 'Makeup',
                      onSelected: () {
                        setState(() {
                          selectedOption = 'Makeup';
                        });
                      },
                    ),
                    MyChips.Chips(
                      inchip: 'Other',
                      isSelected: selectedOption == 'Other',
                      onSelected: () {
                        setState(() {
                          selectedOption = 'Other';
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
                            padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 8.0),
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
            // ProductCard(),
            // ProductCard(),
            selectedOption == 'HairCut' ? const Haircut() : Container(),
            selectedOption == 'HairWash' ? const HairWash() : Container(),
            selectedOption == 'Braids' ? const Braids() : Container(),
            selectedOption == 'Face' ? const Face() : Container(),
          ],
        ),
      ),
    );
  }
}
