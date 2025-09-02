import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/persistence/app_image_manager.dart';
import '../../data/database_model/object_box_entity/chat_entity.dart';
import '../../data/models/chat.dart';
import '../../data/models/image_storage_model.dart';
import 'widget/chat_message.dart';

class ChatState {
  final List<ChatGroupMessageState> messages;

  ChatState({required this.messages});

  factory ChatState.initial() {
    return ChatState(messages: []);
  }
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatState.initial()) {
    final newMessage = TextChatMessage(
      isUserMessage: false,
      text: "Xin chào, tôi là Meow, trợ lý ảo của bạn. Bạn cần gì?",
    );

    _addChatMessage(newMessage);

    final timeMessage = DateChatMessage(
      date: DateTime.now(),
    );
    _addChatMessage(timeMessage);
  }

  final AppImageManager _appImageManager = AppImageManager(ImageStorageFeature.chat);

  void userSendMessage(String message) {
    final newMessage = TextChatMessage(
      isUserMessage: true,
      text: message,
    );

    _addChatMessage(newMessage);

    AObjectBox.create().then(
      (objectBox) {
        final store = objectBox.store.box<ChatEntity>();
        store.put(ChatEntity(message: message, sender: 'user', type: 'text', createdAt: DateTime.now()));
      },
    );
  }

  void userSendImages(List<String> images) {
    final newMessage = ImagesChatMessage(
      isUserMessage: true,
      imagePaths: images,
    );

    _addChatMessage(newMessage);

    Future.sync(
      () {
        for (var image in images) {
          _appImageManager.saveImageFromPath(
            image,
          );
        }
      },
    );
  }

  void _addChatMessage(ChatMessage message) {
    final updatedMessages = List<ChatGroupMessageState>.from(state.messages);
    if (updatedMessages.isEmpty) {
      updatedMessages.add(ChatGroupMessageState(messages: [message]));
    } else {
      if (message.type == ChatMessageType.date) {
        updatedMessages.insert(0, ChatGroupMessageState(messages: [message]));
        emit(ChatState(messages: updatedMessages));

        return;
      }

      final lastGroup = updatedMessages.first;
      if (lastGroup.isUserMessage == message.isUserMessage) {
        lastGroup.messages.add(message);
      } else {
        updatedMessages.insert(0, ChatGroupMessageState(messages: [message]));
      }
    }
    emit(ChatState(messages: updatedMessages));
  }
}
