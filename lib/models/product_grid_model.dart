import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picapool/controllers/product_controller.dart';
import 'package:picapool/screens/product_buy_page.dart';

class ProductGrid extends StatelessWidget {
  final List<Map<String, dynamic>> products = [
    {
      'image': 'assets/images/harrypotter.jpg',
      'title': 'Harry Potter Book',
      'price': '₹400',
      'originalPrice': '₹1098',
      'time': '2w ago',
    },
    {
      'image': 'assets/images/harrypotter.jpg',
      'title': 'Canon Camera',
      'price': '₹400',
      'originalPrice': '₹1098',
      'time': '2w ago',
    },
    {
      'image': 'assets/images/harrypotter.jpg',
      'title': 'OnePlus Phone',
      'price': '₹400',
      'originalPrice': '₹1098',
      'time': '2w ago',
    },
    {
      'image': 'assets/images/harrypotter.jpg',
      'title': 'Harry Potter Book',
      'price': '₹400',
      'originalPrice': '₹1098',
      'time': '2w ago',
    },
    {
      'image': 'assets/images/harrypotter.jpg',
      'title': 'Harry Potter Book',
      'price': '₹400',
      'originalPrice': '₹1098',
      'time': '2w ago',
    },
    {
      'image': 'assets/images/harrypotter.jpg',
      'title': 'Harry Potter Book',
      'price': '₹400',
      'originalPrice': '₹1098',
      'time': '2w ago',
    },
    {
      'image': 'assets/images/harrypotter.jpg',
      'title': 'Harry Potter Book',
      'price': '₹400',
      'originalPrice': '₹1098',
      'time': '2w ago',
    },
    {
      'image': 'assets/images/harrypotter.jpg',
      'title': 'Harry Potter Book',
      'price': '₹400',
      'originalPrice': '₹1098',
      'time': '2w ago',
    },
    {
      'image': 'assets/images/harrypotter.jpg',
      'title': 'Harry Potter Book',
      'price': '₹400',
      'originalPrice': '₹1098',
      'time': '2w ago',
    },
    {
      'image': 'assets/images/harrypotter.jpg',
      'title': 'Harry Potter Book',
      'price': '₹400',
      'originalPrice': '₹1098',
      'time': '2w ago',
    },
    {
      'image': 'assets/images/harrypotter.jpg',
      'title': 'Harry Potter Book',
      'price': '₹400',
      'originalPrice': '₹1098',
      'time': '2w ago',
    },
    {
      'image': 'assets/images/harrypotter.jpg',
      'title': 'Harry Potter Book',
      'price': '₹400',
      'originalPrice': '₹1098',
      'time': '2w ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3 / 4,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductItem(
          image: products[index]['image'],
          title: products[index]['title'],
          price: products[index]['price'],
          offerPrice: products[index]['originalPrice'],
          time: products[index]['time'],
        );
      },
    );
  }
}

class ProductItem extends StatelessWidget {
  final String image;
  final String title;
  final String price;
  final String offerPrice;
  final String time;

  ProductItem({
    required this.image,
    required this.title,
    required this.price,
    required this.offerPrice,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProductDetailsPage()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: image == null || image == "string" || image == ""
                      ? Image.memory(base64Decode(
                          "iVBORw0KGgoAAAANSUhEUgAAAHcAAABZCAMAAAAzQUv+AAAAQlBMVEX09PTw8PD////y8vL4+Pj8/PxYWFjMzMxTU1Opqalra2tiYmKEhIS0tLTh4eGhoaHX19d3d3fp6enBwcGOjo6ZmZkeTKvXAAAFGUlEQVRo3u2Z2XLjOAxFAYqbuJOi/v9XB6CX2HFqWulQk5oqox9akVw+AkhcADQsv2Pw5r65b+6b++a+uW/uvxjSv1/gIoB8BuMXNp2LstSo8NF9qV4M8ASu1w9glGDWzxaTxOlxlsV9gBFa0PbFfPwu+MC+UubR42DDZj7Z6vT2TfCBPHoAo9ps5/WVSt6MroTxFefnL6r7GkPQRb1uZ7XbTeF03SCPxxqjNDaMgFLmAHsKI4doD+gA87n3UKuojWIhUQpTMaY0UJLIKIM28jupfMzfZRGXXY0JmIrbXr22WruwFklAtemuJAw7hD60vhJaws15AhMWllgtEfe89+qt77zitPB7aqnRBw+pyJH9LLfgnHd+hJqCGqzfDQo2megd/AoLJPp/mNvbgZw6kL9y1boGthFqaLUXIZKJJFQFBERnO6k4xn75kK3pzx4f0SvtzFi4q3IBgjLdD6HSdW0ikZYQiNaXI4BZdzmBq7LdBIeX8/iaThsB82a22J119LSTmiDf39ekIPjyR/ABf4O/xY3TaWyu0rdlFCKZVq+zpCWn2zJSBFwSqzVqLlfGy+airL2WYRCl6pWyzCXZnDOrzcyd6i9tKec2wqgPeaDUTVQVBPOSD6Lofbq/JFf07VH750ZAcVWgN2okWuHyDpPjPHZM8E4/g+Wuo+Ddl+jZCmoyFyH5qoru5Rk8qoIwdiedTKQZ07lUjXYRbRTls8fVteYrKTOr83SuYuaui7zl8UOgi6wOR1U8hbsJ+kviM5ikhcoj+Xz92FlcjiWB1xv4P+Be4nyVzFXd5KTrAiPOp3Bv+4q/9CnUtK+w+QBX78/II86ZS4d1DzW9j+6cRwpP4Y4uqqigjXoCU5hp3e8d5QncoZObDgs8gpelBq4JDc7iUl3wiTwjZXoEQ2ukyfddpubXQXK4qxZsb2rUQVlGdVpk0jd3z+COeWHlvqZubYwrYvOePU7hPi+cwUVJxTYKzN66PW4xB2ogLx7fX+0Uf8fEkqnJ2N0YR32N5bkROIc79pINRgksW4wmKbHs/kMyT+PS17auddiS5L4dS6Z+2T2CT+JSNklDM7+voXdqa6zLjdNJ4ux91bkSPBmfcQTntfa1xyQXaujtzWNESvAZ/STl7P4x3V9NCLW0RF0NXfCfqV5DTY1tukvXz86vWtW7+cIK2f06XrUaeFCL6udzCudspUHo1ezDXasp6pzH6KzPB4bMQ3MobvmAXSQz0iA+a+5e1AETlyIhlZw17399JPlirKFPyjXlHHhsVvzi5ser3cBTuZImQPl55R6qAZ+uXMETuQjrjpCjvJ0UXYbQfQjEuDQFcJxlrhPXl1tG6p9ckIsSA8UHhIA+Cw6DUChCEEibi3LuEPgwN+gua1BpzayaskSTE7oc4wJmj1hqLRizIfBU7lK9K8QNrnKZEFnTi4Bz1RbqbP2+eRd3P3pNmLqvaqg59Ka3xA2ryh56XVxGbaKWuxOhCxKqo9vqG9wenSNuTHpwnWTu2ojrl+wgBH4LfwK3OT38vXJVr3jlAnM7+LycwA2iMzcWruo0AbZw81e37mQI4Pam42QuVD5K6GL3rtLcR+sbdJaeuTQq+JWK/Rq9cwkmc0sCMNRbmK3x/JtdMSQWCUyTaSsASA/Hs2Uqd2gklxqWi4XyyIPiA2KWShgliC74GczlLnivDUOuzAqXQnG7Na6P/3D2l79LkmvLj+xvfw9F/B3uT+3NfXPf3Df3/8L9B9IIpYNdK/ehAAAAAElFTkSuQmCC"))
                      : Image.memory(
                          base64Decode(image),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontFamily: "MontserratR",
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontFamily: "MontserratM",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      offerPrice,
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: "MontserratM",
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: "MontserratM",
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
