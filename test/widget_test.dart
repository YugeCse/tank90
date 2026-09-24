// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:tank90/utils/num_utils.dart';

// void main() {
//   test("测试方法", () {
//     var number = 329076;
//     var values = number.spiltToList();
//     debugPrint('number($number) values = ${values.join(',')}');
//   });
// }

import 'dart:convert';
import 'dart:io';

import 'package:flutter/rendering.dart';

void main() {
  test("文件JSON生成", () {
    final file = File('./test/map_stage_level.txt');
    final content = file.readAsStringSync();

    final reg = RegExp(
      r'static const List<List<int>> (map\d+)\s*=\s*\[(.*?)\];',
      dotAll: true,
    );
    final matches = reg.allMatches(content);

    final dir = Directory('json_maps');
    if (!dir.existsSync()) dir.createSync();

    for (final m in matches) {
      final name = m.group(1)!;
      final body = m.group(2)!;
      final numbers = RegExp(
        r'\d+',
      ).allMatches(body).map((e) => int.parse(e.group(0)!)).toList();
      final rows = <List<int>>[];
      for (var i = 0; i < numbers.length; i += 26) {
        rows.add(numbers.sublist(i, i + 26));
      }
      final jsonStr = const JsonEncoder.withIndent('  ').convert(rows);
      File('${dir.path}/$name.json').writeAsStringSync(jsonStr);
      debugPrint('生成 $name.json');
    }
  });
}
