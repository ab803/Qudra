import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/Styles/AppColors.dart';

class CustomSearchBar extends StatefulWidget {
  const CustomSearchBar({super.key});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // This method switches to the institutions tab and passes the current query.
  void _submitSearch() {
    final query = _searchController.text.trim();

    FocusScope.of(context).unfocus();

    final destination = Uri(
      path: '/institution',
      queryParameters: query.isEmpty ? null : {'q': query},
    ).toString();

    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Appcolors.primaryColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _submitSearch(),
        decoration: InputDecoration(
          hintText: 'Search institutions or guidelines...',
          hintStyle: const TextStyle(color: Appcolors.secondaryColor),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Appcolors.secondaryColor),
          suffixIcon: IconButton(
            onPressed: _submitSearch,
            icon: const Icon(
              Icons.arrow_forward_rounded,
              color: Appcolors.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}