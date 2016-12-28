library views.hello;

import 'dart:async';
import 'dart:io';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_template/angel_template.dart';
import 'layout.dart';
part 'hello.g.dart';

@View()
class Hello extends Layout {
  @override
  String get title => 'Hello, world!';

  @override
  content() async => '<i>Welcome to Angel templates!</i>';
}
