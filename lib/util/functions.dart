import 'dart:io';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Read asset from assets/ and write to temp file, return the file
Future<File> createFileFromAssets(String path) async {
  final byteData = await rootBundle.load('assets/$path');
  final file = File('${(await getTemporaryDirectory()).path}/$path');
  file.createSync(recursive: true);
  file.writeAsBytesSync(byteData.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  return file;
}

/// Write string to temp file and return the file
Future<File> createFileFromString(String str) async {
  final file = File('${(await getTemporaryDirectory()).path}/${Uuid().v1()}');
  file.createSync(recursive: true);
  file.writeAsStringSync(str, flush: true);
  return file;
}

/// Determine the first visible item by finding the item with the
/// smallest trailing edge that is greater than 0.  i.e. the first
/// item whose trailing edge in visible in the viewport.
/// Return -1 if list is empty
int findFirstVisibleItemIndex(Iterable<ItemPosition> positions) {
  if (positions.isNotEmpty) {
    return positions
        .where((ItemPosition position) => position.itemTrailingEdge > 0)
        .reduce((ItemPosition min, ItemPosition position) =>
            position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
        .index;
  } else {
    return -1;
  }
}

/// Determine the first visible item by finding the item with the
/// smallest trailing edge that is greater than 0.  i.e. the first
/// item whose trailing edge in visible in the viewport.
/// Return -1 if list is empty
int findLastVisibleItemIndex(Iterable<ItemPosition> positions) {
  if (positions.isNotEmpty) {
    return positions
        .where((ItemPosition position) => position.itemLeadingEdge < 1)
        .reduce((ItemPosition max, ItemPosition position) =>
            position.itemLeadingEdge > max.itemLeadingEdge ? position : max)
        .index;
  } else {
    return -1;
  }
}
