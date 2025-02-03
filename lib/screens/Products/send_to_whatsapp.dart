// Example usage
import 'dart:developer';

import 'package:picapool/models/product_model.dart';

void main() {
  String username = "Dipan";
  int userId = 34;
  List<Map<String, dynamic>> products = [
    {
      "name": "Indi Tandoori Pizza (Regular)",
      "id": 1,
      "originalPrice": 299,
      "discountPrice": 269
    },
    {
      "name": "Farmhouse (Regular)",
      "id": 2,
      "originalPrice": 259,
      "discountPrice": 152
    },
  ];

  // String waLink = generateWhatsAppLink(username, userId, products);
  // print(waLink);
}

String generateWhatsAppLink(
  String username,
  int userId,
  List<Product> products,
) {
  const String baseUrl = "https://wa.me/918330935063?text=";

  // Prepare order text
  String orderText = "";
  for (int i = 0; i < products.length; i++) {
    final product = products[i];
    orderText +=
        "${i + 1}. *${product.name}* (P_ID: ${product.id}) - ~₹${product.mrp}~ ₹${product.offerPrice}\n";
  }
  log(orderText);

  // Calculate totals
  double finalPrice =
      products.fold(0, (sum, item) => sum + (item.offerPrice ?? 0)) * 1.05 + 30;

  double totalSavings = 45;
  for (var product in products) {
    double diff =
        (product.mrp ?? 0).toDouble() - (product.offerPrice ?? 0).toDouble();
    if (diff < 0) diff = 0;
    totalSavings += diff;
  }
  // double totalSavings = products.fold(
  //         0, (sum, item) => sum + ((item.mrp ?? 0) - (item.offerPrice ?? 0))) +
  //     45;

  finalPrice = double.parse(finalPrice.toStringAsFixed(2));

  // Generate message
  String message = """
Hi!
This is *$username* (ID: $userId).

I’d like to proceed with the following order:

$orderText
*Final Price (Inc. Tax&Charges):* ₹$finalPrice
*Total Savings (Inc. Tax&Charges):* ₹$totalSavings

Could you please check if there are any additional discounts available? 😊
""";

  // Encode the message for URL
  String encodedMessage = Uri.encodeComponent(message);

  return baseUrl + encodedMessage;
}
