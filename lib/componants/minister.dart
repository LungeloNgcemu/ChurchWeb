import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


class Minister extends StatelessWidget {
  Minister({
    this.name,
    this.work,
    this.image,
    this.tap,
    super.key,
  });

  String? name;
  String? work;
  String? image;
  void Function()? tap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 10.0, right: 10.0, bottom: 10.0, top: 10.0),
      child: GestureDetector(
        onDoubleTap: tap,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Row(
                  
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                         
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        height: 70.0,
                    
                        child: ClipRRect(
                           borderRadius: BorderRadius.only(topRight: Radius.circular(20.0), topLeft: Radius.circular(20.0)),
                          child: CachedNetworkImage(
                            imageUrl: image ?? "",
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
                            //height: 250,
                            //width: double.maxFinite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3.0, bottom: 3.0),
                child: Text(
                  name ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(work ?? ''),
              ),
            ],
          ),
          
        ),
      ),
    );
  }
}
