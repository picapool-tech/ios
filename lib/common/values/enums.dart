enum VendorLogin {
  google,
  apple;

  String get assest {
    switch (this) {
      case VendorLogin.google:
        return "assets/icons/google.png";
      case VendorLogin.apple:
        return "assets/icons/apple_logos.png";
      default:
        return "";
    }
  }
}
