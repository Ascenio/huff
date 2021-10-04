import 'dart:io';
import 'dart:typed_data';

import 'package:huff/src/serialization.dart' show bitsPerByte;

class Deserialization {
  const Deserialization({required this.table, required this.message});

  final Map<int, List<int>> table;
  final Uint8List message;
}

Deserialization readFile(String filePath) {
  final bytes = File(filePath).readAsBytesSync();
  assert(bytes.isNotEmpty);
  var index = 0;
  final tableResult = tableFromBytes(bytes, index);
  index = tableResult.index;
  final messageResult = listFromBytes(bytes, index);
  return Deserialization(
    table: tableResult.value,
    message: Uint8List.fromList(messageResult.value),
  );
}

class Result<T> {
  const Result({required this.value, required this.index});

  final T value;
  final int index;
}

Result<Map<int, List<int>>> tableFromBytes(List<int> bytes, int index) {
  final mapLengthResult = numberFromBytes(bytes, index);
  index = mapLengthResult.index;
  final table = <int, List<int>>{};
  for (var i = 0; i < mapLengthResult.value; i++) {
    final keyResult = numberFromSingleByte(bytes, index);
    index = keyResult.index;
    final valueResult = listFromBytes(bytes, index);
    index = valueResult.index;
    table[keyResult.value] = valueResult.value;
  }
  return Result(value: table, index: index);
}

Result<List<int>> listFromBytes(List<int> bytes, int index) {
  final bytesCountResult = numberFromBytes(bytes, index);
  index = bytesCountResult.index;
  final paddingSizeResult = numberFromBytes(bytes, index);
  index = paddingSizeResult.index;
  final contentResult = bytes.sublist(index, index + bytesCountResult.value);
  index = index + bytesCountResult.value;
  final bits = contentResult.map(bitsFromByte).expand((bits) => bits).toList();
  if (paddingSizeResult.value > 0) {
    bits.removeRange(bits.length - paddingSizeResult.value, bits.length);
  }
  return Result(value: bits, index: index);
}

List<int> bitsFromByte(int byte) {
  final bits = <int>[];
  for (var i = 0; i < bitsPerByte; i++) {
    final bit = (byte >> (bitsPerByte - 1 - i)) & 1;
    bits.add(bit);
  }
  return bits;
}

Result<int> numberFromSingleByte(List<int> bytes, int index) {
  return Result(value: bytes[index], index: index + 1);
}

Result<int> numberFromBytes(List<int> bytes, int index) {
  var number = 0;
  for (var i = 0; i < 4; i++) {
    number |= bytes[i + index] << ((4 - 1 - i) * bitsPerByte);
  }
  return Result(value: number, index: index + 4);
}
