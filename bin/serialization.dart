import 'dart:io';
import 'dart:math';

import 'dart:typed_data';

double log2(num x) => log(x) / ln2;

const bitsPerByte = 8;

void saveToFile(String filePath, Map<int, List<int>> table, Uint8List encoded) {
  final builder = BytesBuilder()
    ..add(bytesFromTable(table))
    ..add(bytesFromList(encoded));
  File(filePath).writeAsBytesSync(builder.takeBytes());
}

Uint8List bytesFromTable(Map<int, List<int>> table) {
  final builder = BytesBuilder()..add(bytesFromNumber(table.entries.length));
  for (final entry in table.entries) {
    builder
      ..add(bytesFromNumber(entry.key))
      ..add(bytesFromList(entry.value));
  }
  return builder.takeBytes();
}

Uint8List bytesFromList(List<int> encoded) {
  int bitsNeeded;
  int paddingSize;
  if (encoded.length < bitsPerByte) {
    bitsNeeded = bitsPerByte;
    paddingSize = bitsPerByte - encoded.length;
  } else {
    bitsNeeded = log2(encoded.length).ceil();
    paddingSize = pow(2, bitsNeeded).toInt() - encoded.length;
  }
  final builder = BytesBuilder()
    ..add(encoded)
    ..add(List.generate(paddingSize, (_) => 0));
  final bits = builder.takeBytes();
  assert(bits.length % 2 == 0);
  final bytesCount = bits.length ~/ bitsPerByte;
  builder
    ..add(bytesFromNumber(bytesCount))
    ..add(bytesFromNumber(paddingSize))
    ..add(bytesFromBits(bits));
  return builder.takeBytes();
}

Uint8List bytesFromBits(List<int> bits) {
  final builder = BytesBuilder();
  for (var i = 0; i < bits.length; i += bitsPerByte) {
    var byte = 0;
    for (var j = 0; j < bitsPerByte; j++) {
      byte |= bits[i + j] << (bitsPerByte - 1 - j);
    }
    builder.addByte(byte);
  }
  return builder.takeBytes();
}

Uint8List bytesFromNumber(int number) {
  final builder = BytesBuilder();
  for (var i = 3; i >= 0; i--) {
    final byte = (number >> (i * bitsPerByte)) & 255;
    builder.addByte(byte);
  }
  return builder.takeBytes();
}
