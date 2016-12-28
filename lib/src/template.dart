import 'dart:async';

abstract class Template {
  Future<String> render();
}