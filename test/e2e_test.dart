import 'dart:io';

import 'package:huff/huff.dart';
import 'package:test/test.dart';

void main() {
  test('file integrity is persisted', () {
    final inputFile = File('test/lorem.txt');
    final inputBytes = inputFile.readAsBytesSync();
    final decompressedFile = File('test/decompressed.txt');
    compress(['-c', inputFile.path, 'test/compressed.txt']);
    decompress(['-d', 'test/compressed.txt', decompressedFile.path]);
    final decompressedBytes = decompressedFile.readAsBytesSync();
    expect(decompressedBytes, inputBytes);
  });
}
