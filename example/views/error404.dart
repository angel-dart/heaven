library views.error404;

import 'dart:async';
import 'dart:io';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_template/angel_template.dart';
import 'layout.dart';

part 'error404.g.dart';

@View()
class Error404 extends Layout {
  @Inject()
  final RequestContext request;

  Error404(this.request);

  @override
  String get title => '404 Not Found';

  @override
  Future<String> content() async {
    return '''
    <i>No resource exists at ${request.uri}.</i>
    ''';
  }
}