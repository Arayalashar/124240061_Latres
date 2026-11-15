import 'package:hive/hive.dart';

class User extends HiveObject {
  final String username;
  final String password;

  User({
    required this.username,
    required this.password,
  });
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final username = reader.readString();
    final password = reader.readString();
    return User(
      username: username,
      password: password,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer.writeString(obj.username);
    writer.writeString(obj.password);
  }
}
