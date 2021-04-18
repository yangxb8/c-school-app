mixin Filterable {
  /// Properties that can be used as filters, must be converted to String or List<String>
  Map<String, dynamic> get filterableProperties;

  /// <Name, Condition> pair, condition must be converted to String or List<String>
  /// If String is used, find exact match. If list is used, check if property is in the list
  bool match(Map<String, dynamic> conditions) {
    for (var entry in conditions.entries) {
      if (!filterableProperties.containsKey(entry.key)) {
        return false;
      }
      var property = filterableProperties[entry.key];
      if (entry.value is String) {
        if (property is String && property != entry.value) {
          return false;
        } else if (property is List<String> &&
            !property.contains(entry.value)) {
          return false;
        }
      } else if (entry.value is List<String>) {
        if (property is String && !entry.value.contains(property)) {
          return false;
        } else if (property is List<String> &&
            !property.any((element) => entry.value.contains(element))) {
          return false;
        }
      } else {
        // If value is not String or List<String>
        return false;
      }
    }
    return true;
  }
}

/// Make sure to pass the right type
extension Filter on List<Filterable> {
  List<T> filter<T extends Filterable>(Map<String, dynamic> conditions){
    return where((element) => element.match(conditions)) as List<T>;
  }
}
