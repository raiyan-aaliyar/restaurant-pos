import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:restobill/core/design/widgets/app_search_bar.dart';
import 'package:restobill/features/pos/application/search_provider.dart';

class SearchSection extends ConsumerWidget {
  const SearchSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppSearchBar(
      hintText: "Search menu items...",
      onChanged: (value) {
        ref.read(searchProvider.notifier).setSearch(value);
      },
    );
  }
} 