enum TermsInfo {
  termsOfService(
      text: "Terms of Service",
      url: "https://picapool.com/terms-and-conditions.html"),
  privacyPolicy(
      text: "Privacy policy",
      url: "https://www.picapool.com/privacy-policy.html"),
  contentPolicy(
      text: "Content policy",
      url: "https://www.picapool.com/refund-policy.html");

  final String text;
  final String url;

  const TermsInfo({
    required this.text,
    required this.url,
  });
}
