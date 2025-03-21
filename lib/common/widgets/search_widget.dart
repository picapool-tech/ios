import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picapool/utils/svg_icon.dart';
import 'package:picapool/utils/theme.dart';

class SearchWidget extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback? onTapped;
  final double? height;
  final Color? borderColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? trailingIconColor;
  const SearchWidget({
    super.key,
    required this.onSearch,
    this.onTapped,
    this.height,
    this.borderColor,
    this.textColor,
    this.hintColor,
    this.trailingIconColor,
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
        const Color(0xff9A9A9A).withOpacity(0.2),
      ),
      controller: _searchController,
      hintText: "Search",
      leading: const SvgIcon(
        "assets/icons/search.svg",
        size: 24,
      ),
      onTap: widget.onTapped,
      constraints: BoxConstraints(
        minHeight: widget.height ?? 50,
      ),
      padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 15, vertical: 0)),
      side: WidgetStateBorderSide.resolveWith(
        (Set<WidgetState> states) => BorderSide(
          color: widget.borderColor ??
              AppTheme.light.colorScheme.surfaceContainerHigh,
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
            color:
                widget.hintColor ?? AppTheme.light.colorScheme.onSurfaceVariant,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          );
        },
      ),
      textStyle: WidgetStateProperty.resolveWith<TextStyle?>(
        (Set<WidgetState> states) {
          return GoogleFonts.montserrat(
              color: widget.textColor ??
                  AppTheme.light.colorScheme.onSurfaceVariant,
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
                    setState(() {
                      _searchController.clear();
                      widget.onSearch("");
                    });
                  },
                  color: widget.trailingIconColor ??
                      AppTheme.light.colorScheme.onSurfaceVariant,
                ),
              )
              .toList()
          : null,
    );
  }
}
