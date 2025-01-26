// Example usage
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
  const String baseUrl = "https://wa.me/917224052216?text=";

  // Prepare order text
  String orderText = "";
  for (int i = 0; i < products.length; i++) {
    final product = products[i];
    orderText +=
        "${i + 1}. *${product.name}* (P_ID: ${product.id}) - ~₹${product.mrp}~ ₹${product.offerPrice}%0A";
  }

  // Calculate totals
  double finalPrice =
      products.fold(0, (sum, item) => sum + (item.offerPrice ?? 0));
  double totalSavings = products.fold(
      0, (sum, item) => sum + (item.mrp ?? 0 - (item.offerPrice ?? 0)));

  // Generate message
  String message = """
Hi!
This is *$username* (ID: $userId).

I’d like to proceed with the following order:

$orderText
*Final Price:* ₹$finalPrice
*Total Savings:* ₹$totalSavings

Could you please check if there are any additional discounts available? 😊
""";

  // Encode the message for URL
  String encodedMessage = Uri.encodeComponent(message);

  return baseUrl + encodedMessage;
}
