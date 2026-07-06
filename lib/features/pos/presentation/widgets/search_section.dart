import 'package:flutter/material.dart';
import 'package:restobill/core/design/widgets/app_search_bar.dart';

class SearchSection extends StatelessWidget {
  const SearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: AppSearchBar(
        hintText: 'Search menu...',
      ),
    );
  }
}