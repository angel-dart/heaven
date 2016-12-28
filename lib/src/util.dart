import 'package:charcode/ascii.dart';

String snake(String id) {
  var buf = new StringBuffer();

  for (var ch in id.codeUnits) {
    if (($A <= ch && ch <= $Z) ||
        ($a <= ch && ch <= $z) ||
        ($0 <= ch && ch <= $9)) {
      buf.writeCharCode(ch);
    } else {
      buf.writeCharCode($underscore);
    }
  }

  return buf.toString();
}