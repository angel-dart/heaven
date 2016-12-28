library views.profile;

import 'dart:async';
import 'dart:io';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_template/angel_template.dart';
import '../models/user.dart';
import 'layout.dart';
part 'profile.g.dart';

@View()
class Profile extends Layout {
  @Inject()
  final User user;

  Profile(this.user);

  @override
  String get title => 'About ${user.username}';

  @override
  Future<String> content() async {
    return '''
    <h3>Hello, ${user.username}!</h3>
    <i>Your e-mail is: ${user.email}.</i>
    ''';
  }
}
