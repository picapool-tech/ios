mixin VehicleValidationMixin {
  bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  String? validateField(String? value) {
    if (isNullOrEmpty(value)) {
      return "Cannot be left empty";
    }

    return null;
  }

  String? validateKmsDriven(String? value) {
    if (isNullOrEmpty(value)) {
      return "Cannot be empty";
    }

    // Remove any non-numeric characters (like commas, spaces)
    String cleanValue = value!.replaceAll(RegExp(r'[^\d]'), '');

    // Try to parse the cleaned value
    int? kms = int.tryParse(cleanValue);
    if (kms == null) {
      return "Kilometers driven must be a valid number";
    }

    // Check for negative values
    if (kms < 0) {
      return "Kilometers driven cannot be negative";
    }

    // Check if value is unreasonably high
    if (kms > 1000000) {
      return "Value appears too high. Please verify";
    }

    return null;
  }

  String? validateYear(String? value) {
    if (isNullOrEmpty(value)) {
      return "Cannot be left empty";
    }

    // Parse the year to an integer
    
    int? yearInt = int.tryParse(value!);
    if (yearInt == null) {
      return "Year must be a valid number";
    }

    // Check if the year is within a reasonable range
    int currentYear = DateTime.now().year;
    if (yearInt < 1886 || yearInt > currentYear + 1) {
      // +1 for next year models
      return "Year must be between 1886 and ${currentYear + 1}";
    }

    return null;
  }
}
