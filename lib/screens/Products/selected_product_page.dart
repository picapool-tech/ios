import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class SelectedProductPage extends StatefulWidget {
  final Map<String, String> product;

  const SelectedProductPage({
    super.key,
    required this.product,
  });

  @override
  _SelectedProductPageState createState() => _SelectedProductPageState();
}

class _SelectedProductPageState extends State<SelectedProductPage> {
  final List<String> imgList = [
    'assets/images/Controller.png', // Replace with your image asset paths
    'assets/images/Controller.png',
    'assets/images/Controller.png',
  ];

  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Offer',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'MontserratM',
            fontSize: 16,
          ),
        ),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                'assets/avatar.jpg',
              ), // Replace with your image asset path
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Find "dominos" offer',
                  hintStyle: TextStyle(
                    color: Color(0xff000000),
                    fontFamily: "MontserratR",
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.orange),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.product['title'] ?? "Product Title",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: "MontserratM",
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.grey.withOpacity(0.5), width: 1),
                    ),
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: 250,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false,
                        viewportFraction: 0.9,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _current = index;
                          });
                        },
                      ),
                      items: [
                        Image.asset(
                          width: double.infinity,
                          widget.product['image'] ??
                              'assets/images/Controller.png',
                          fit: BoxFit.cover,
                        )
                      ],
                      // .map((item) => ClipRRect(
                      //       borderRadius: BorderRadius.circular(10),
                      //       child: ,
                      //     ))
                      // .toList(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imgList.map((url) {
                      int index = imgList.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == index
                              ? const Color.fromRGBO(0, 0, 0, 0.9)
                              : const Color.fromRGBO(0, 0, 0, 0.4),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'MRP : ${widget.product['price'] ?? "0"}',
              style: const TextStyle(
                fontFamily: "MontserratM",
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Description',
              style: TextStyle(
                fontFamily: "MontserratM",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.product['description'] ?? "Product Description",
              style: const TextStyle(
                fontSize: 14,
                fontFamily: "MontserratR",
                color: Colors.black,
              ),
            ),
            // const Text(
            //   'Read more',
            //   style: TextStyle(
            //     fontSize: 14,
            //     fontFamily: "MontserratM",
            //     color: Colors.orange,
            //   ),
            // ),
            const SizedBox(height: 20),
            const Text(
              'Details',
              style: TextStyle(
                fontSize: 16,
                fontFamily: "MontserratM",
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.product['details'] ?? "Product Details",
              style: const TextStyle(
                fontSize: 14,
                fontFamily: "MontserratM",
                color: Colors.black,
              ),
            ),
            // const Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Features',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontFamily: "MontserratM",
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black,
            //           ),
            //         ),
            //         Text(
            //           'Built-In Microphone',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontFamily: "MontserratR",
            //             color: Colors.black,
            //           ),
            //         ),
            //       ],
            //     ),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           '',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontFamily: "MontserratM",
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black,
            //           ),
            //         ),
            //         Text(
            //           'Headset Jack',
            //           style: TextStyle(
            //             fontSize: 14,
            //             fontFamily: "MontserratR",
            //             color: Colors.black,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Handle See Offers action
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffFF8D41),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            'See Offers',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontFamily: "MontserratSB",
            ),
          ),
        ),
      ),
    );
  }
}
