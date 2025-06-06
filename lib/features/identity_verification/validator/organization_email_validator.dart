mixin OrganizationEmailValidator {
  bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  String? validateEmail(String? value) {
    if (isNullOrEmpty(value)) {
      return "Email cannot be left empty";
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value!)) {
      return "Please enter a valid email address";
    }

    return null;
  }
}
