import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:picapool/screens/Products/products_homePage.dart';
import 'package:picapool/widgets/Sell_Form_Page0.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _currentIndex = 0;
  bool _isReadMore = false;

  final List<String> imgList = [
    'assets/images/bgproduct.png',
    'assets/images/bgproduct.png',
    'assets/images/bgproduct.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150'), // Seller image URL
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dilip kumar',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: "MontserratR")),
                Text('(Seller)',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontFamily: "MontserratR")),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Apple iPad (10th Generation): with A14 Bionic chip, 27.69 cm (10.9")',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    fontFamily: "MontserratR"),
              ),
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () {
                  // Define what happens when the button is tapped
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFFE9DA),
                  side: const BorderSide(color: Color(0xffFF6600)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min, // To minimize the button width
                    children: [
                      Text(
                        'Go to site',
                        style: TextStyle(
                            fontFamily: "MontserratR",
                            fontWeight: FontWeight.bold,
                            color: Color(0xffFF6600)),
                      ),
                      SizedBox(width: 5), // Space between text and icon
                      Icon(Icons.arrow_circle_right_outlined,
                          size: 20, color: Color(0xffFF6600)), // Icon with size
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.width * 9 / 16,
                        aspectRatio: 16 / 9,
                        autoPlay: true,
                        enlargeCenterPage: false,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                      ),
                      items: imgList.map((item) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Image.asset(item, fit: BoxFit.cover);
                          },
                        );
                      }).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: imgList.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => setState(() {
                            _currentIndex = entry.key;
                          }),
                          child: Container(
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 2.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.orange)
                                  .withOpacity(
                                      _currentIndex == entry.key ? 0.9 : 0.4),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Text(
                    'Selling price : ',
                    style: TextStyle(
                        fontFamily: "MontserratM",
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                  Text(
                    ' Rs. 55,000',
                    style: TextStyle(
                        fontFamily: "MontserratM",
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.orange),
                  ),
                ],
              ),
              const Text(
                '(MRP Rs.70,000 )',
                style: TextStyle(
                    fontSize: 14,
                    fontFamily: "MontserratM",
                    color: Color(0xff565656)),
              ),
              const SizedBox(height: 20),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reason for selling : ',
                    style: TextStyle(
                        fontFamily: "MontserratR",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text(
                    'Upgrading to a better table.',
                    style: TextStyle(
                        fontFamily: "MontserratR",
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Text(
                    'Description - ',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: "MontserratR",
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text(
                    '(2 years old)',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: "MontserratR",
                        color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _isReadMore
                    ? 'Colourfully reimagined and more versatile than ever, iPad is great for the things you do every day. With an all-screen design, 27.69 cm (10.9") Liquid Retina display, and support for the new Magic Keyboard Folio, it’s the perfect choice for working, creating, and staying connected. Powered by the A14 Bionic chip with support for the Apple Pencil (1st generation) and available in four colours, iPad lets you unleash your creativity in unprecedented ways.'
                    : 'Colourfully reimagined and more versatile than ever, iPad is great for the things you do every day. With an all-screen design, 27.69 cm (10.9") Liquid Retina ...',
                style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "MontserratR",
                    color: Colors.black),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isReadMore = !_isReadMore;
                  });
                },
                child: Text(
                  _isReadMore ? 'Read less' : 'Read more',
                  style: const TextStyle(fontSize: 16, color: Colors.orange),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Details',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: "MontserratR",
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Brand- ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "MontserratR")),
                      Text('Apple',
                          style: TextStyle(
                              fontSize: 16, fontFamily: "MontserratR")),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('Color- ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "MontserratR")),
                      Text('Silver',
                          style: TextStyle(
                              fontSize: 16, fontFamily: "MontserratR")),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Model Name - ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "MontserratR")),
                      Text('iPad',
                          style: TextStyle(
                              fontSize: 16, fontFamily: "MontserratR")),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Storage - ',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "MontserratR")),
                      Text('64 GB',
                          style: TextStyle(
                              fontSize: 16, fontFamily: "MontserratR")),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ProductsHomepage(
                        currentIndex: 1,
                      )),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffFF8D41),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Proceed',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: "MontserratSB"),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
