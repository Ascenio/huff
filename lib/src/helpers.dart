import 'package:collection/collection.dart';

bool listsAreEqual<T>(List<T> a, List<T> b) {
  if (a.length != b.length) {
    return false;
  }
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) {
      return false;
    }
  }
  return true;
}

Map<U, T> swapMap<T, U>(Map<T, U> map) {
  final entries = map.entries.map((entry) => MapEntry(entry.value, entry.key));
  return Map.fromEntries(entries);
}

EqualityMap<List<T>, U> equalityMapFromMap<T, U>(Map<List<T>, U> map) {
  return EqualityMap<List<T>, U>.from(
    ListEquality<T>(IdentityEquality<T>()),
    map,
  );
}
