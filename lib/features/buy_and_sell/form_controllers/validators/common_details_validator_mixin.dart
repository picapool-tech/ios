import 'package:get/get.dart';
import 'package:picapool/screens/buy_and_sell/values/product_condition_class.dart';

mixin CommonDetailsValidatorMixin {
  String? validateCondition(ProductCondition? value) {
    if (value == null) {
      return "Select product condition";
    }

    return null;
  }

  String? validateEmailAddress(String? value) {
    if (_isNullOrEmpty(value)) {
      return "email must not be empty";
    }

    if (!GetUtils.isEmail(value!)) {
      return "Enter a valid email";
    }

    return null;
  }

  String? validateMonth(String? value) {
    if (_isNullOrEmpty(value)) {
      return null;
    }
    final month = int.tryParse(value!);
    if (month == null) {
      return null;
    }
    if (month < 0) {
      return 'Month must be greater than or equal to 0';
    }
    return null;
  }

  String? validateMrp(String? value) {
    if (_isNullOrEmpty(value)) {
      return "Add a mrp for this product";
    }

    try {
      value = value!.replaceAll(",", "");
      double mrp = double.parse(value);
      if (mrp <= 0) {
        return "MRP must be greater than zero";
      }
      return null;
    } catch (e) {
      return "Please enter a valid number";
    }
  }

  String? validateOfferPrice(String? value) {
    if (_isNullOrEmpty(value)) {
      return "Add a offer price for this product";
    }

    try {
      value = value!.replaceAll(",", "");
      double mrp = double.parse(value);
      if (mrp <= 0) {
        return "Offer price must be greater than zero";
      }
      return null;
    } catch (e) {
      return "Please enter a valid number";
    }
  }

  String? validateReasonForSell(String? value) {
    if (_isNullOrEmpty(value)) {
      return "Reason must not be empty";
    }
    return null;
  }

  String? validateYear(String? value) {
    if (_isNullOrEmpty(value)) {
      return null;
    }
    final year = int.tryParse(value!);
    if (year == null) {
      return null;
    }
    if (year < 0) {
      return 'Month must be greater than or equal to 0';
    }
    return null;
  }

  bool _isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }
}
