import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/screens/Products/selected_product_page.dart';

class ViewProductsPage extends StatelessWidget {
  const ViewProductsPage({super.key});

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
          'Deals',
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
                  'assets/avatar.jpg'), // Replace with your image asset path
            ),
          ),
        ],
      ),
      body: Padding(
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
                  hintText: 'Find "dominos" deals',
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
            // Products Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 3, // Number of items
                itemBuilder: (context, index) {
                  return _buildProductCard(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    final List<Map<String, String>> products = [
      {
        'image':
            'assets/dominos/Margherita Pizza.png', // Replace with your image asset path
        'title': 'Margherita Pizza',
        'price': '₹ 109',
        'status': 'available',
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

    final product = products[index];
    final isSoldOut = product['status'] == 'sold_out';

    return InkWell(
      onTap: () {
        Get.to(() => SelectedProductPage(
              product: products[index],
            ));
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const SelectedProductPage(),
        //   ), // Navigate to SelectedProductPage
        // );
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: Image.asset(
                    product['image']!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Domions Offer',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'MontserratR',
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['title']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'MontserratM',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product['price']!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'MontserratM',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isSoldOut)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    'SOLD OUT',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'MontserratM',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
