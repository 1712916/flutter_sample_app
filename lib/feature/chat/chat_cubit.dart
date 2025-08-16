import 'package:flutter_bloc/flutter_bloc.dart';

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

  void userSendMessage(String message) {
    final newMessage = TextChatMessage(
      isUserMessage: true,
      text: message,
    );

    _addChatMessage(newMessage);
  }

  void userSendImages(List<String> images) {
    final newMessage = ImagesChatMessage(
      isUserMessage: true,
      imagePaths: images,
    );

    _addChatMessage(newMessage);
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
