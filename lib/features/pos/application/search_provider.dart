import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) {
    state = value;
  }
}

final searchProvider =
    NotifierProvider<SearchNotifier, String>(
  SearchNotifier.new,
);