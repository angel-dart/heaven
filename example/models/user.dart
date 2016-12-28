library models.user;

import 'package:source_gen/generators/json_serializable.dart';
part 'user.g.dart';

@JsonSerializable()
class User extends _$UserSerializerMixin {
  User({this.username, this.email});

  factory User.fromJson(Map json) => _$UserFromJson(json);

  @JsonKey('username')
  String username;

  @JsonKey('email')
  String email;
}
