// ignore_for_file: avoid_print

import 'dart:io';

import 'deserialization.dart';
import 'encoder.dart';
import 'serialization.dart';
import 'tree.dart';

void printUsage() {
  print('''
Usage: huffman <mode> <input_file> <output_file>
    
where <mode> can be one of:
      -c  compression
      -d  decompression''');
}

enum Mode { compress, decompress }

Mode validateArgs(List<String> args) {
  if (args.length != 3) {
    printUsage();
    exit(1);
  }
  final mode = {
    '-c': Mode.compress,
    '-d': Mode.decompress,
  }[args.first];
  if (mode == null) {
    printUsage();
    exit(1);
  }
  return mode;
}

void compress(List<String> args) {
  final input = File(args[1]);
  final bytes = input.readAsBytesSync();
  final count = bytes.fold<Map<int, int>>({}, (cache, current) {
    return cache..update(current, (value) => value + 1, ifAbsent: () => 1);
  });
  final sortedUniqueBytes = List.of(count.entries)
    ..sort((a, b) => a.value.compareTo(b.value));

  final trees = <Tree<int>>[];
  final leafs = sortedUniqueBytes
      .map((entry) => Leaf<int>(frequency: entry.value, value: entry.key))
      .toList();

  final finalTree = merge(trees, leafs);
  final table = treeAsTable(finalTree);
  final encoded = encode(bytes, table);
  saveToFile(args.last, table, encoded);
}

void decompress(List<String> args) {
  final deserialization = readFile(args[1]);
  final bytes = decodeFromTable(deserialization.message, deserialization.table);
  File(args.last).writeAsBytesSync(bytes);
}
