import 'dart:async';
import 'package:angel_template/angel_template.dart';

abstract class Layout extends Template {
  String get title;

  Future<String> content();

  @override
  Future<String> render() async {
    return '''
    <!DOCTYPE html>
    <html>
      <head>
        <title>${title} - Angel</title>
      </head>
      <body>
        <h1>Angel Templates</h1>
        <hr>
        ${await content()}
      </body>
    </html>
    ''';
  }
}