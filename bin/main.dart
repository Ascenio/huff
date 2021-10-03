import 'package:huff/huff.dart';

void main(List<String> args) {
  final mode = validateArgs(args);
  if (mode == Mode.compress) {
    compress(args);
  } else if (mode == Mode.decompress) {
    decompress(args);
  }
}
