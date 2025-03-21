mixin FurnitureValidationMixin {
  bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  String? validateField(String? value) {
    if (isNullOrEmpty(value)) {
      return "Cannot be left empty";
    }

    return null;
  }

  String? validateUnits(String? value) {
    if (isNullOrEmpty(value)) {
      return "Connot be left empty";
    }

    try {
      double? unitValue = double.tryParse(value!);
      if (unitValue == null || unitValue <= 0) {
        return "Dimension must be greater than 0";
      }
    } catch (e) {
      return "Please enter a valid number";
    }

    return null;
  }
}
