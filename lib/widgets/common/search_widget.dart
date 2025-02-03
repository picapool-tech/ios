import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/utils/svg_icon.dart';
import 'package:picapool/utils/theme.dart';

class SearchWidget extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback? onTapped;
  const SearchWidget({
    super.key,
    required this.onSearch,
    this.onTapped,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      surfaceTintColor: WidgetStatePropertyAll(
        Color(0xff9A9A9A).withOpacity(0.2),
      ),
      controller: _searchController,
      hintText: "Search",
      leading: const SvgIcon(
        "assets/icons/search.svg",
        size: 24,
      ),
      onTap: widget.onTapped,
      padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 15, vertical: 0)),
      side: WidgetStateBorderSide.resolveWith(
        (Set<WidgetState> states) => BorderSide(
          color: AppTheme.light.colorScheme.surfaceContainerHigh,
          width: 2,
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) =>
            AppTheme.light.colorScheme.surfaceContainerHigh.withOpacity(0.2),
      ),
      elevation: WidgetStateProperty.resolveWith<double>(
        (Set<WidgetState> states) => 0,
      ),
      hintStyle: WidgetStateProperty.resolveWith<TextStyle?>(
        (Set<WidgetState> states) {
          return GoogleFonts.montserrat(
              color: AppTheme.light.colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w300);
        },
      ),
      textStyle: WidgetStateProperty.resolveWith<TextStyle?>(
        (Set<WidgetState> states) {
          return GoogleFonts.montserrat(
              color: AppTheme.light.colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w300);
        },
      ),
      onChanged: widget.onSearch,
      textInputAction: TextInputAction.done,
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      trailing: (_searchController.text.isNotEmpty)
          ? Iterable.generate(1, (index) => index)
              .map(
                (index) => IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearch("");
                  },
                  color: AppTheme.light.colorScheme.onSurfaceVariant,
                ),
              )
              .toList()
          : null,
    );
  }
}
