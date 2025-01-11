import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/screens/vicinity/request_vicinity.dart';

class BrandOfferModel {
  final String title;
  final String description;
  final String imageUrl;

  BrandOfferModel({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  factory BrandOfferModel.fromJson(Map<String, dynamic> json) {
    return BrandOfferModel(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}

class OnePlusCommunityOfferPage extends StatelessWidget {
  OnePlusCommunityOfferPage({super.key});

  final BrandOfferModel model = BrandOfferModel(
    title: 'Dominos Offer',
    description:
        "Now that's a DEAL 🤝 Treat your family and friends with #DominosExclusiveOffers. Use code PIZZAPARTY and get 6 Pizzas at just Rs.350/-. Order Now.",
    imageUrl: "assets/dominos/OfferImag1.png",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            // Handle pooling action
            Get.to(() => const RequestVicinity(), arguments: {
              "brands": {
                ...model.toJson(),
              }
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffFF8D41),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
          ),
          child: const Text(
            'Start Pooling',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'MontserratM',
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          model.title,
          style: const TextStyle(
            color: Colors.black,
            fontFamily: 'MontserratM',
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                width: double.infinity,
                'assets/dominos/OfferImag1.png', // Replace with your image asset path
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            // View Details Text
            const Text(
              'View Details',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'MontserratM',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _productDetailsList(),
            const SizedBox(height: 20),
            const Text("""
Now that's a DEAL 🤝 Treat your family and friends with #DominosExclusiveOffers. Use code PIZZAPARTY and get 6 Pizzas at just Rs.350/-. Order Now.

Step 1: Login the Dominos app
Step 2: Choose the option for delivery (No takeaway)
Step 3: Add 1 Margherita Pizza (Regular Size)
Step 4: Go to the pizza Mania Section and Add 2 onion pizza and 3 tomato Pizza
step 5: Apply Coupon code PIZZAPARTY and get 6 pizzas in 350

""")
            // Product 1 Details
            // _buildProductDetail(
            //   imagePath: 'assets/images/image 80.png',
            //   title: 'Margherita Pizza',
            //   display: '6.7" Fluid AMOLED, 120Hz',
            //   processor: 'Snapdragon 8 Gen 2',
            //   ram: '12GB/16GB',
            //   storage: '256GB/512GB',
            //   camera: '50MP+48MP+8MP rear, 32MP front',
            //   price: '₹ 89',
            //   originalPrice: '₹ 104',
            // ),
            // const SizedBox(height: 20),
            // // Product 2 Details
            // _buildProductDetail(
            //   imagePath: 'assets/images/image 82.png',
            //   title: 'OnePlus 10 Pro :',
            //   display: '6.7" Fluid AMOLED, 120Hz',
            //   processor: 'Snapdragon 8 Gen 1',
            //   ram: '12GB/16GB',
            //   storage: '256GB/512GB',
            //   camera: '50MP+48MP+8MP rear, 32MP front',
            //   price: '₹ 89',
            //   originalPrice: '₹ 104',
            // ),
            // const SizedBox(height: 20),
            // // Start Pooling Button
            // // Center(
            // //   child:
            // // ),
            // const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  final List<Map<String, String>> products = [
    {
      'image':
          'assets/dominos/Margherita Pizza.png', // Replace with your image asset path
      'title': 'Margherita Pizza',
      'price': '₹ 109',
      'status': 'available',
      'originalPrice': "109",
      'description':
          'Margherita Pizza is a delicious pizza with a thin crust, topped with tomato sauce, mozzarella cheese, and fresh basil leaves. It is a simple and classic pizza that is perfect for any occasion.',
      'details': """Step 1: Login the Dominos app
Step 2: Choose the option for delivery (No takeaway)
Step 3: Add 1 Margherita Pizza (Regular Size)
Step 4: Go to the pizza Mania Section and Add 2 onion pizza and 3 tomato Pizza
step 5: Apply Coupon code PIZZAPARTY and get 6 pizzas in 350"""
    },
    {
      'image':
          'assets/dominos/Onion Pizza.png', // Replace with your image asset path
      'title': 'Onion Pizza',
      'price': '₹ 53',
      'status': 'available',
      'originalPrice': "69",
      'description':
          'Onion Pizza is a delicious pizza with a thin crust, topped with tomato sauce, mozzarella cheese, and fresh onions. It is a simple and classic pizza that is perfect for any occasion.',
      'details': """Step 1: Login the Dominos app
Step 2: Choose the option for delivery (No takeaway)
Step 3: Add 1 Margherita Pizza (Regular Size)
Step 4: Go to the pizza Mania Section and Add 2 onion pizza and 3 tomato Pizza
step 5: Apply Coupon code PIZZAPARTY and get 6 pizzas in 350"""
    },
    {
      'image':
          'assets/dominos/Tomato Pizza.png', // Replace with your image asset path
      'title': 'Tomato Pizza',
      'price': '₹ 53',
      'status': 'available',
      'originalPrice': "69",
      'description':
          'Tomato Pizza is a delicious pizza with a thin crust, topped with tomato sauce, mozzarella cheese, and fresh basil leaves. It is a simple and classic pizza that is perfect for any occasion.',
      'details': """Step 1: Login the Dominos app
Step 2: Choose the option for delivery (No takeaway)
Step 3: Add 1 Margherita Pizza (Regular Size)
Step 4: Go to the pizza Mania Section and Add 2 onion pizza and 3 tomato Pizza
step 5: Apply Coupon code PIZZAPARTY and get 6 pizzas in 350"""
    },
    // {
    //   'image': 'assets/images/ps 5.png', // Replace with your image asset path
    //   'title': 'Game console Apple iPad play',
    //   'price': '₹ 400',
    //   'status': 'sold_out'
    // },
    // {
    //   'image': 'assets/images/ps 5.png', // Replace with your image asset path
    //   'title': 'Game console Apple iPad play',
    //   'price': '₹ 400',
    //   'status': 'available'
    // },
    // {
    //   'image': 'assets/images/ps 5.png', // Replace with your image asset path
    //   'title': 'Game console Apple iPad play',
    //   'price': '₹ 400',
    //   'status': 'available'
    // },
    // {
    //   'image': 'assets/images/ps 5.png', // Replace with your image asset path
    //   'title': 'Game console Apple iPad play',
    //   'price': '₹ 400',
    //   'status': 'available'
    // },
    // {
    //   'image': 'assets/images/ps 5.png', // Replace with your image asset path
    //   'title': 'Game console Apple iPad play',
    //   'price': '₹ 400',
    //   'status': 'sold_out'
    // },
  ];

  Widget _productDetailsList() {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductDetailDominos(
          imagePath: product['image']!,
          title: product['title']!,
          price: product['price']!,
          description: product['description']!,
          originalPrice: product['originalPrice'] ?? "104",
        );
      },
    );
  }

  Widget _buildProductDetailDominos({
    required String imagePath,
    required String title,
    required String description,
    required String price,
    required String originalPrice,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'MontserratM',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'MontserratR',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  text: price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'MontserratM',
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: ' M.R.P. ',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'MontserratR',
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      text: originalPrice,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'MontserratR',
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetail({
    required String imagePath,
    required String title,
    required String display,
    required String processor,
    required String ram,
    required String storage,
    required String camera,
    required String price,
    required String originalPrice,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            imagePath,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'MontserratM',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '• Display: $display\n'
                '• Processor: $processor\n'
                '• RAM: $ram\n'
                '• Storage: $storage\n'
                '• Camera: $camera',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'MontserratR',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  text: price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'MontserratM',
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: ' M.R.P. ',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'MontserratR',
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      text: originalPrice,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'MontserratR',
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
