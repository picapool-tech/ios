mixin ElectronicsValidationMixin {
  bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  String? validateField(String? value) {
    if (isNullOrEmpty(value)) {
      return "Cannot be left empty";
    }

    return null;
  }
}
