import '../database_model/object_box_entity/chat_entity.dart';

enum ChatMessageType {
  none,
  text, // Represents a text message
  image, // Represents an image message
  date; // Represents a date message

  //factory from string
  factory ChatMessageType.fromString(String value) {
    switch (value) {
      case 'text':
        return ChatMessageType.text;
      case 'image':
        return ChatMessageType.image;
      case 'date':
        return ChatMessageType.date;
    }
    return ChatMessageType.none;
  }

  //convert to string
  @override
  String toString() {
    switch (this) {
      case ChatMessageType.text:
        return 'text';
      case ChatMessageType.image:
        return 'image';
      case ChatMessageType.date:
        return 'date';
      case ChatMessageType.none:
        return '';
    }
  }
}

//create extension create ChatMessageType from String
extension ChatModelExtension on String {
  ChatMessageType toChatMessageType() {
    return ChatMessageType.fromString(this);
  }

  ChatSource toChatSource() {
    return ChatSource.fromString(this);
  }
}

enum ChatSource {
  none,
  system,
  user,
  gameHistory;

  //factory from string
  factory ChatSource.fromString(String value) {
    switch (value) {
      case 'system':
        return ChatSource.system;
      case 'user':
        return ChatSource.user;
      case 'gameHistory':
        return ChatSource.gameHistory;
    }
    return ChatSource.none;
  }
}

abstract class ChatModel<T> {
  final ChatMessageType type;
  final ChatSource source;
  final DateTime createdAt;
  final T data;

  ChatModel({
    required this.type,
    required this.source,
    required this.createdAt,
    required this.data,
  });

  //factory from ChatEntity
  static ChatModel fromEntity(ChatEntity entity) {
    final source = entity.sender.toChatSource();
    final type = entity.type.toChatMessageType();

    switch (type) {
      case ChatMessageType.text:
        return ChatTextMessage(
          source: source,
          createdAt: entity.createdAt,
          data: entity.message,
        );
      case ChatMessageType.image:
        return ChatTextMessage(
          source: source,
          createdAt: entity.createdAt,
          data: entity.message,
        );
      case ChatMessageType.date:
      case ChatMessageType.none:
        return NoneMessage();
    }
  }
}

class NoneMessage extends ChatModel<String> {
  NoneMessage()
      : super(
          type: ChatMessageType.none,
          source: ChatSource.none,
          createdAt: DateTime.now(),
          data: '',
        );
}

//ChatTextMessage
class ChatTextMessage extends ChatModel<String> {
  ChatTextMessage({
    required super.source,
    required super.createdAt,
    required super.data,
  }) : super(type: ChatMessageType.text);
}
