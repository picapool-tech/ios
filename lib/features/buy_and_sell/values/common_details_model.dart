import 'package:image_picker/image_picker.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';

class CommonDetailsModel {
  final List<XFile> images;
  final ProductCondition productCondition;
  final String mrp;
  final String offerPrice;
  final String yearsHeld;
  final String monthsHeld;
  final String reasonForSell;
  final String email;
  final bool isLessThanAMonth;

  CommonDetailsModel({
    required this.images,
    required this.productCondition,
    required this.mrp,
    required this.offerPrice,
    required this.yearsHeld,
    required this.monthsHeld,
    required this.reasonForSell,
    required this.email,
    this.isLessThanAMonth = false,
  });

  // Create model from JSON
  // factory CommonDetailsModel.fromJson(Map<String, dynamic> json) {
  //   return CommonDetailsModel(
  //     images: ((json['images'] as List<dynamic>?) ?? [])
  //         .map((path) => XFile(path.toString()))
  //         .toList(),
  //     productCondition: ProductConditionEnums.values.firstWhere(
  //       (e) => e.toString().split('.').last == json['productCondition'],
  //       orElse: () => ProductConditionEnums.values.first,
  //     ),
  //     mrp: json['mrp']?.toString() ?? '',
  //     offerPrice: json['offerPrice']?.toString() ?? '',
  //     yearsHeld: json['yearsHeld']?.toString() ?? '',
  //     monthsHeld: json['monthsHeld']?.toString() ?? '',
  //     reasonForSell: json['reasonForSell']?.toString() ?? '',
  //     email: json['email']?.toString() ?? '',
  //   );
  // }

  List<XFile> getImageToUpload() {
    return images;
  }

  // Convert model to JSON
  Map<String, dynamic> toJsonForAttributes() => {
        'productCondition': productCondition.name,
        if (!isLessThanAMonth) 'yearsHeld': yearsHeld,
        if (!isLessThanAMonth) 'monthsHeld': monthsHeld,
        if (isLessThanAMonth) 'timeHeld': "Less than a month",
        'reasonForSell': reasonForSell,
      };

  Map<String, dynamic> toJsonRequired() => {
        'images': [],
        'mrp': mrp.replaceAll(",", ""),
        'offerPrice': offerPrice.replaceAll(",", ""),
        'email': "notrequired@email.com",
      };
}
