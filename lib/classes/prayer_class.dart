import 'package:flutter/material.dart';
import 'package:flutter_product_carousel/flutter_product_carousel.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';

class Prayer {
  // Widget pictureScroll() {
  //   final ProductCarouselController _productCarouselController = ProductCarouselController();
  //
  //   return ProductCarousel(
  //     imagesList: const [
  //       'https://fastly.picsum.photos/id/10/2500/1667.jpg?hmac=J04WWC_ebchx3WwzbM-Z4_KC_LeLBWr5LZMaAkWkF68',
  //       'https://fastly.picsum.photos/id/11/2500/1667.jpg?hmac=xxjFJtAPgshYkysU_aqx2sZir-kIOjNR9vx0te7GycQ',
  //       'https://fastly.picsum.photos/id/12/2500/1667.jpg?hmac=Pe3284luVre9ZqNzv1jMFpLihFI6lwq7TPgMSsNXw2w'
  //     ],
  //     carouselOptions: ProductCarouselOptions(
  //       autoPlay: true,
  //       height: 150,
  //       enabledInfiniteScroll: true,
  //       boxFit: BoxFit.cover,
  //       productCarouselController: _productCarouselController,
  //      // showNavigationIcons: true,
  //       onTap: () {},
  //     ),
  //   );
  // }

List<String> imagesList = const [
  'https://fastly.picsum.photos/id/10/2500/1667.jpg?hmac=J04WWC_ebchx3WwzbM-Z4_KC_LeLBWr5LZMaAkWkF68',
  'https://fastly.picsum.photos/id/11/2500/1667.jpg?hmac=xxjFJtAPgshYkysU_aqx2sZir-kIOjNR9vx0te7GycQ',
  'https://fastly.picsum.photos/id/12/2500/1667.jpg?hmac=Pe3284luVre9ZqNzv1jMFpLihFI6lwq7TPgMSsNXw2w'
];



  Widget sliderPictures(){
    return CarouselSlider(
        items: imagesList.map((item) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.cyan,
          ),

          child: Center(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(item, fit: BoxFit.cover, width: 1000)),
          ),
        )).toList(),
        options: CarouselOptions(
          height: 130,
          aspectRatio: 16/4,
          viewportFraction: 0.8,
          initialPage: 0,
          enableInfiniteScroll: true,
          reverse: false,
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 5),
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: true,
          enlargeFactor: 0.3,
         // onPageChanged: callbackFunction,
          scrollDirection: Axis.horizontal,
        )
    );
  }



String convertDate(){

  List<String> months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];


    print('Inserting Prayers');

    DateTime now = DateTime.now();

    String year = DateFormat('yyyy').format(now);
    String day = DateFormat('dd').format(now);
    int month = int.parse( DateFormat('M').format(now));

    final formattedDate = "$day ${months[month - 1]} $year";

    return formattedDate;
}



}





