import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryProvider =
    NotifierProvider<CategoryNotifier, String>(CategoryNotifier.new);

class CategoryNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void select(String id) {
    state = id;
  }
}