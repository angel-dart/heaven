import 'dart:io';
import 'package:angel_common/angel_common.dart';
import '../models/user.dart';
import '../views/error404.dart' as views;
import '../views/hello.dart' as views;
import '../views/profile.dart' as views;

main() async {
  var app = new Angel()
    ..before.add((RequestContext req, res) async {
      req.inject(User, new User(username: 'jdoe1', email: 'jdoe1@gmail.com'));
      return true;
    });

  var errorHandler = new ErrorHandler(handlers: {404: views.error404});

  await app.configure(errorHandler);

  app
    ..get('/', views.hello)
    ..get('/profile', views.profile)
    ..all('*', errorHandler.throwError())
    ..all('*', errorHandler.middleware(defaultStatus: 404))
    ..responseFinalizers.add(gzip());

  await new DiagnosticsServer(app, new File('log.txt'))
      .startServer(InternetAddress.ANY_IP_V4, 3000);
}
