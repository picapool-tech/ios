import 'package:flutter/material.dart';

class PublicChatPage extends StatefulWidget {
  const PublicChatPage({super.key});

  @override
  _PublicChatPageState createState() => _PublicChatPageState();
}

class _PublicChatPageState extends State<PublicChatPage> {
  List<Map<String, dynamic>> products = [
    {
      'image':
          'assets/images/image 82.png', // Replace with your actual image path
      'name': 'OnePlus 11 Pro',
      'price': '₹ 40,000',
      'selected': false,
    },
    {
      'image':
          'assets/images/image 82.png', // Replace with your actual image path
      'name': 'OnePlus 10 Pro',
      'price': '₹ 46,000',
      'selected': false,
    },
    {
      'image':
          'assets/images/image 82.png', // Replace with your actual image path
      'name': 'OnePlus 11 Pro',
      'price': '₹ 40,000',
      'selected': false,
    },
    {
      'image':
          'assets/images/image 82.png', // Replace with your actual image path
      'name': 'OnePlus 10 Pro',
      'price': '₹ 46,000',
      'selected': false,
    },
    {
      'image':
          'assets/images/image 82.png', // Replace with your actual image path
      'name': 'OnePlus 10 Pro',
      'price': '₹ 46,000',
      'selected': false,
    },
    {
      'image':
          'assets/images/image 82.png', // Replace with your actual image path
      'name': 'OnePlus 10 Pro',
      'price': '₹ 46,000',
      'selected': false,
    },
    {
      'image':
          'assets/images/image 82.png', // Replace with your actual image path
      'name': 'OnePlus 10 Pro',
      'price': '₹ 46,000',
      'selected': false,
    },
    {
      'image':
          'assets/images/image 82.png', // Replace with your actual image path
      'name': 'OnePlus 10 Pro',
      'price': '₹ 46,000',
      'selected': false,
    },
    {
      'image':
          'assets/images/image 82.png', // Replace with your actual image path
      'name': 'OnePlus 10 Pro',
      'price': '₹ 46,000',
      'selected': false,
    },
    {
      'image':
          'assets/images/image 82.png', // Replace with your actual image path
      'name': 'OnePlus 10 Pro',
      'price': '₹ 46,000',
      'selected': false,
    },
    {
      'image':
          'assets/images/image 82.png', // Replace with your actual image path
      'name': 'OnePlus 10 Pro',
      'price': '₹ 46,000',
      'selected': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Buy 1 get 2",
          style: TextStyle(
            fontSize: 18,
            fontFamily: "MontserratM",
            color: Colors.black,
          ),
        ),
        // centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Products to Pool",
              style: TextStyle(
                fontSize: 16,
                fontFamily: "MontserratM",
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio:
                      0.90, // Adjust the aspect ratio to reduce the height
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        products[index]['selected'] =
                            !products[index]['selected'];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: products[index]['selected']
                              ? Colors.orange
                              : Colors.grey.shade300,
                          width: products[index]['selected'] ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip
                            .none, // This allows the checkbox to go out of bounds if needed
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Image.asset(
                                    products[index]['image'],
                                    height:
                                        120, // Adjust image height to reduce card size
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  products[index]['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: "MontserratM",
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  products[index]['price'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: "MontserratM",
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top:
                                -10, // Make sure this positions the checkbox visibly outside
                            right:
                                -10, // Ensures it aligns with the top-right edge of the card
                            child: Checkbox(
                              value: products[index]['selected'],
                              onChanged: (bool? value) {
                                setState(() {
                                  products[index]['selected'] = value ?? false;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              activeColor: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement the logic to proceed to the chat screen
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //       builder: (context) => ChatPage(
                  //         chat: ,
                  //       ),
                  //     ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Proceed",
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "MontserratM",
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
