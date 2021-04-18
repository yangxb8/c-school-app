// 📦 Package imports:
import 'package:fuzzy/fuzzy.dart';

extension StringListUtil on Iterable<String> {
  /// Fuzzy search a list of String by keyword, options can be provided
  List<String> searchFuzzy(String key, {FuzzyOptions? options}) {
    options ??=
        FuzzyOptions(findAllMatches: true, tokenize: true, threshold: 0.5);
    final fuse = Fuzzy(toList(), options: options);
    return fuse.search(key).map((r) => r.item.toString()).toList();
  }

  /// Search if this string list contains key fuzzily
  bool containsFuzzy(String key, {FuzzyOptions? options}) {
    options ??=
        FuzzyOptions(findAllMatches: true, tokenize: true, threshold: 0.5);
    final fuse = Fuzzy(toList(), options: options);
    return fuse.search(key).isNotEmpty;
  }
}

extension StringUtil on String {
  /// Search if this string contains key fuzzily
  bool containsFuzzy(String key, {FuzzyOptions? options}) {
    return [this].containsFuzzy(key, options: options);
  }
}
