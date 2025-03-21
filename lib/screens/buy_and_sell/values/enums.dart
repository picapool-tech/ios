enum SortOption {
  newestFirst(label: 'Newest First'),
  oldestFirst(label: 'Oldest First'),
  priceHighToLow(label: 'Price: High to Low'),
  priceLowToHigh(label: 'Price: Low to High');

  final String label;

  const SortOption({required this.label});
}
