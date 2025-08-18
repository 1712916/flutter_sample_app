import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../image/detail_image_page.dart';

enum ChatMessageType {
  text, // Represents a text message
  image, // Represents an image message
  date, // Represents a date message
}

abstract class ChatMessage {
  final bool isUserMessage;
  final ChatMessageType type;

  ChatMessage({
    required this.isUserMessage,
    required this.type,
  });

  Widget build(BuildContext context, MessageRelativePosition position);
}

class TextChatMessage extends ChatMessage {
  final String text;

  TextChatMessage({
    required bool isUserMessage,
    required this.text,
  }) : super(isUserMessage: isUserMessage, type: ChatMessageType.text);

  @override
  Widget build(BuildContext context, MessageRelativePosition position) {
    final theme = context.appTheme;

    return FractionallySizedBox(
      widthFactor: 0.8,
      child: Align(
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: getMargin(position),
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: chatBubbleDecoration(
            context,
            isUserMessage,
            position,
          ),
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isUserMessage ? theme.colorScheme.onInverseSurface : theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class ImagesChatMessage extends ChatMessage {
  final List<String> imagePaths;

  ImagesChatMessage({
    required bool isUserMessage,
    required this.imagePaths,
  }) : super(isUserMessage: isUserMessage, type: ChatMessageType.image);

  @override
  Widget build(BuildContext context, MessageRelativePosition position) {
    return Padding(
      padding: getMargin(position),
      child: FractionallySizedBox(
        widthFactor: 0.8,
        child: SizedBox(
          height: 120,
          child: Align(
            alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                separatorBuilder: (context, index) => const SizedBox(width: 8.0),
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  final path = imagePaths[index];
                  if (path.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: GestureDetector(
                      onTap: () {
                        // Handle image tap if needed
                        DetailImagePage(
                          url: path,
                          heroTag: "heroTag",
                        ).show(context);
                      },
                      child: Image.file(
                        File(path),
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}

class DateChatMessage extends ChatMessage {
  final DateTime date;

  DateChatMessage({
    required this.date,
  }) : super(isUserMessage: true, type: ChatMessageType.date);

  @override
  Widget build(BuildContext context, MessageRelativePosition position) {
    final theme = context.appTheme;
    return Align(
      alignment: Alignment.center,
      child: Text(
        '${date.day}/${date.month}/${date.year}',
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class ChatGroupMessageState {
  final List<ChatMessage> messages;
  bool get isUserMessage => messages.isNotEmpty && messages.last.isUserMessage;

  ChatGroupMessageState({required this.messages});

  factory ChatGroupMessageState.initial() {
    return ChatGroupMessageState(messages: []);
  }

  Widget build(BuildContext context) {
    switch (isUserMessage) {
      case true:
        return Align(
          alignment: Alignment.centerRight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (int i = 0; i < messages.length; i++)
                Builder(builder: (context) {
                  return messages[i].build(context, MessageRelativePosition.fromIndex(i, messages.length));
                }),
            ],
          ),
        );
      case false:
        return Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < messages.length; i++)
                      Builder(builder: (context) {
                        return messages[i].build(context, MessageRelativePosition.fromIndex(i, messages.length));
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}

enum MessageRelativePosition {
  only,
  first,
  last,
  middle;

  factory MessageRelativePosition.fromIndex(int index, int total) {
    if (total == 0) return MessageRelativePosition.only;
    if (index == 0) return MessageRelativePosition.first;
    if (index == total - 1) return MessageRelativePosition.last;
    return MessageRelativePosition.middle;
  }
}

Decoration chatBubbleDecoration(BuildContext context, bool isUserMessage, MessageRelativePosition position) {
  final theme = context.appTheme;
  final color = isUserMessage ? theme.colorScheme.inverseSurface : theme.colorScheme.tertiaryContainer;
  final borderRadius = BorderRadius.circular(20);

  switch (isUserMessage) {
    case true:
      switch (position) {
        case MessageRelativePosition.only:
          return BoxDecoration(
            color: color,
            borderRadius: borderRadius.copyWith(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          );
        case MessageRelativePosition.first:
          return BoxDecoration(
            color: color,
            borderRadius: borderRadius.copyWith(topLeft: Radius.circular(20), bottomRight: Radius.circular(4)),
          );
        case MessageRelativePosition.last:
          return BoxDecoration(
            color: color,
            borderRadius: borderRadius.copyWith(bottomLeft: Radius.circular(20), topRight: Radius.circular(4)),
          );
        case MessageRelativePosition.middle:
          return BoxDecoration(
            color: color,
            borderRadius: borderRadius.copyWith(
              topRight: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          );
      }
    case false:
      switch (position) {
        case MessageRelativePosition.only:
          return BoxDecoration(
            color: color,
            borderRadius: borderRadius.copyWith(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          );
        case MessageRelativePosition.first:
          return BoxDecoration(
            color: color,
            borderRadius: borderRadius.copyWith(topLeft: Radius.circular(20), bottomLeft: Radius.circular(4)),
          );
        case MessageRelativePosition.last:
          return BoxDecoration(
            color: color,
            borderRadius: borderRadius.copyWith(topLeft: Radius.circular(4)),
          );
        case MessageRelativePosition.middle:
          return BoxDecoration(
            color: color,
            borderRadius: borderRadius.copyWith(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
          );
      }
  }
}

EdgeInsets getMargin(MessageRelativePosition position) {
  switch (position) {
    case MessageRelativePosition.only:
      return EdgeInsets.zero;
    case MessageRelativePosition.first:
      return EdgeInsets.only(bottom: 4);
    case MessageRelativePosition.last:
      return EdgeInsets.zero;
    case MessageRelativePosition.middle:
      return EdgeInsets.only(bottom: 4);
  }
}
