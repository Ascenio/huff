import 'dart:typed_data';

import 'helpers.dart';
import 'tree.dart';

Uint8List encode(Uint8List bytes, Map<int, List<int>> table) {
  final builder = BytesBuilder();
  for (final byte in bytes) {
    builder.add(table[byte]!);
  }
  return builder.takeBytes();
}

Uint8List decode(Uint8List bytes, Tree<int> tree) {
  final decoded = BytesBuilder();
  var current = tree;
  var lastWasNode = false;
  for (final byte in bytes) {
    if (current is Leaf<int>) {
      decoded.addByte(current.value);
      current = tree;
      lastWasNode = false;
    }
    if (current is Node<int>) {
      if (byte == 0) {
        current = current.left;
      } else {
        current = current.right;
      }
      lastWasNode = true;
    }
  }
  if (lastWasNode && current is Leaf<int>) {
    decoded.addByte(current.value);
  }
  return decoded.toBytes();
}

Uint8List decodeFromTable(
  Uint8List bytes,
  Map<int, List<int>> byteToBitsTable,
) {
  final builder = BytesBuilder();
  final bitsToByteTable = equalityMapFromMap(swapMap(byteToBitsTable));
  var i = 0;
  while (i < bytes.length) {
    final slice = <int>[];
    while (!bitsToByteTable.containsKey(slice) && i < bytes.length) {
      slice.add(bytes[i++]);
    }
    while (bitsToByteTable.containsKey(slice) && i < bytes.length) {
      slice.add(bytes[i++]);
    }
    if (i < bytes.length) {
      slice.removeLast();
      i--;
    }
    builder.addByte(bitsToByteTable[slice]!);
  }
  return builder.takeBytes();
}
