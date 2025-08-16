import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meow_app/feature/chat/chat_cubit.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

extension HideKeyBoard on BuildContext {
  void hideKeyboard() {
    final FocusScopeNode currentFocus = FocusScope.of(this);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final ValueNotifier<bool> _showFilesNotifier = ValueNotifier<bool>(true);
  late Listenable _inputListenable;
  final ChatCubit _chatCubit = ChatCubit();

  @override
  void initState() {
    super.initState();

    _inputListenable = Listenable.merge([_focusNode, _controller]);
    _inputListenable.addListener(_inputListener);
  }

  bool _previousFocus = false;
  bool _isFirstCall = true;

  void _inputListener() {
    if (_isFirstCall) {
      _isFirstCall = false;
      return;
    }

    if (_focusNode.hasFocus) {
      if (_previousFocus) {
        _showFilesNotifier.value = false;
      } else {
        _showFilesNotifier.value = _controller.text.isEmpty;
      }
    } else {
      _showFilesNotifier.value = true;
    }
    _previousFocus = _focusNode.hasFocus;
  }

  @override
  void dispose() {
    _inputListenable.removeListener(_inputListener);
    _focusNode.dispose();
    _controller.dispose();
    _chatCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Page'),
      ),
      body: GestureDetector(
        onTap: () {
          context.hideKeyboard();
        },
        child: BlocBuilder<ChatCubit, ChatState>(
            bloc: _chatCubit,
            builder: (context, state) {
              return ListView.separated(
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final message = state.messages[index];
                  return message.build(context);
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
              );
            }),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _showFilesNotifier,
                builder: (BuildContext context, bool isShow, Widget? child) {
                  return AnimatedSize(
                    duration: const Duration(milliseconds: 60),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 60),
                      child: !isShow
                          ? SizedBox(
                              key: const ValueKey('button'),
                              width: 36,
                              height: 36,
                              child: IconButton(
                                onPressed: () {
                                  _showFilesNotifier.value = true;
                                },
                                icon: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  // color: theme.primaryColor,
                                ),
                                padding: EdgeInsets.zero,
                                iconSize: 22,
                              ),
                            )
                          : Container(
                              key: const ValueKey('child'),
                              child: child!,
                            ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //camera button
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();

                          final XFile? image = await picker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 80,
                          );
                          if (image != null) {
                            _chatCubit.userSendImages([image.path]);
                          }
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          // color: theme.primaryColor,
                        ),
                        padding: EdgeInsets.zero,
                        iconSize: 22,
                      ),
                    ),
                    //image button
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton(
                        onPressed: () async {
                          final ImagePicker picker = ImagePicker();

                          final List<XFile> images = await picker.pickMultiImage();

                          if (images.isEmpty) return;

                          _chatCubit.userSendImages(images.map((image) => image.path).toList());
                        },
                        icon: Icon(
                          Icons.image,
                          // color: theme.primaryColor,
                        ),
                        padding: EdgeInsets.zero,
                        iconSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TextField(
                  autofocus: true,
                  focusNode: _focusNode,
                  controller: _controller,
                  onSubmitted: (value) {},
                  decoration: InputDecoration(
                    constraints: BoxConstraints(
                      minHeight: 30,
                      maxHeight: 120,
                    ),
                    // hintText: LKey.chatTypeAMessage.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    // contentPadding: EdgeInsets.zero,
                    filled: true,
                    isDense: true,
                    // fillColor: theme.colorBackgroundSurface,
                  ),
                  maxLines: 3,
                  minLines: 1,
                  // style: context.appTheme.textMedium13Default,
                ),
              ),
              AnimatedBuilder(
                animation: Listenable.merge([_focusNode, _controller]),
                builder: (context, _) {
                  bool isEnable = _controller.text.isNotEmpty;
                  return SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton(
                      onPressed: isEnable
                          ? () {
                              _chatCubit.userSendMessage(_controller.text);
                              _controller.clear();
                            }
                          : null,
                      icon: Icon(
                        Icons.send,
                        color: isEnable ? null : theme.iconColor,
                      ),
                      iconSize: 22,
                      padding: EdgeInsets.zero,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
