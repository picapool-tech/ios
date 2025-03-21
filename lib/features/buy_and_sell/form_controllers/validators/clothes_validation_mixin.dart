import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';

mixin ClothesValidationMixin {
  String? validateBrand(String? value) {
    return validateStyle(value);
  }

  String? validateDescription(String? value) {
    if (_isNullOrEmpty(value)) {
      return "Must not be empty";
    }

    if (value!.length > 200) {
      return "Should be only in 200 words";
    }
  }

  String? validateFabric(String? value) {
    return validateStyle(value);
  }

  String? validateSize(ProductCondition? value) {
    if (value == null) {
      return "Select the size of the product";
    }

    return null;
  }

  String? validateStyle(String? value) {
    if (_isNullOrEmpty(value)) {
      return "Must not be empty";
    }

    if (value!.length < 2) {
      return "Must be atleast of length 2";
    }

    return null;
  }

  bool _isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }
}
