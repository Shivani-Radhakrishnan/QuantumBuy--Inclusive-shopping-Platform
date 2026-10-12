// Runs the app's rule-based voice parser over commands, one per line on stdin, and
// prints one JSON object per line. Used by ml/eval/voice_eval.py as the baseline.
//
//   dart run tool/parse_commands.dart < commands.txt
import 'dart:convert';
import 'dart:io';

import 'package:shopping_app/data/product_catalog.dart';
import 'package:shopping_app/services/voice_command.dart';

void main() {
  const repo = ProductRepository();
  String? text;
  while ((text = stdin.readLineSync(encoding: utf8)) != null) {
    final command = parseVoiceCommand(text!, products: repo.allProducts, categories: repo.categories);
    final out = switch (command) {
      AddProductCommand(:final product, :final quantity) =>
        {'intent': 'add', 'product': product.id, 'quantity': quantity},
      OpenCategoryCommand(:final category) => {'intent': 'open_category', 'category': category},
      OpenCartCommand() => {'intent': 'open_cart'},
      UnknownCommand() => {'intent': 'unknown'},
    };
    stdout.writeln(jsonEncode(out));
  }
}
