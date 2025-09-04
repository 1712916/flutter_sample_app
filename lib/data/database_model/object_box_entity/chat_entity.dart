import 'package:objectbox/objectbox.dart';

@Entity()
class ChatEntity {
  @Id()
  int id;

  ///[message] is not directly string;
  ///in this app it wil
  String message;

  String sender;

  String type;

  DateTime createdAt;

  ChatEntity({
    this.id = 0,
    required this.message,
    required this.sender,
    required this.type,
    required this.createdAt,
  });
}
