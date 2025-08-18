import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Chat Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
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
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        children: [
                          BottomDropdownButton<AttachmentType>(
                            options: AttachmentType.values,
                            onSelected: (value) async {
                              switch (value) {
                                case AttachmentType.gallery:
                                  final ImagePicker picker = ImagePicker();

                                  final List<XFile> images = await picker.pickMultiImage();

                                  if (images.isEmpty) return;

                                  _chatCubit.userSendImages(images.map((image) => image.path).toList());
                                  break;
                                case AttachmentType.camera:
                                  final ImagePicker picker = ImagePicker();

                                  final XFile? image = await picker.pickImage(
                                    source: ImageSource.camera,
                                    imageQuality: 80,
                                  );
                                  if (image != null) {
                                    _chatCubit.userSendImages([image.path]);
                                  }
                                  break;
                              }
                            },
                            itemBuilder: (context, option) {
                              switch (option) {
                                case AttachmentType.gallery:
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        HugeIcon(
                                          icon: HugeIcons.strokeRoundedImage01,
                                          color: theme.iconColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(child: Text('Gallery', style: theme.textTheme.bodyMedium)),
                                      ],
                                    ),
                                  );
                                case AttachmentType.camera:
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        HugeIcon(
                                          icon: HugeIcons.strokeRoundedCamera01,
                                          color: theme.iconColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible(child: Text('Camera', style: theme.textTheme.bodyMedium)),
                                      ],
                                    ),
                                  );
                              }
                            },
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: theme.dividerColor.withAlpha(100),
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
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                // contentPadding: EdgeInsets.zero,
                                filled: false,
                                isDense: true,
                                // fillColor: theme.colorBackgroundSurface,
                              ),
                              maxLines: 3,
                              minLines: 1,
                              // style: context.appTheme.textMedium13Default,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedBuilder(
                    animation: Listenable.merge([_focusNode, _controller]),
                    builder: (context, _) {
                      bool isEnable = _controller.text.isNotEmpty;
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        width: 52,
                        height: 52,
                        child: IconButton(
                          onPressed: isEnable
                              ? () {
                                  _chatCubit.userSendMessage(_controller.text);
                                  _controller.clear();
                                }
                              : null,
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedSent,
                            color: isEnable ? theme.iconColor : theme.iconColor.withOpacity(0.5),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor2,
    );
  }
}

class BottomDropdownButton<T> extends StatefulWidget {
  final List<T> options;
  final ValueChanged<T>? onSelected;
  final WidgetBuilder<T> itemBuilder;

  const BottomDropdownButton({
    Key? key,
    required this.options,
    this.onSelected,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  State<BottomDropdownButton<T>> createState() => _BottomDropdownButtonState<T>();
}

class _BottomDropdownButtonState<T> extends State<BottomDropdownButton<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (_overlayEntry != null) {
      _removeDropdown();
    } else {
      // đóng keyboard khi mở dropdown
      FocusScope.of(context).unfocus();
      _showDropdown();
    }
  }

  void _showDropdown() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Stack(
          children: [
            // background để bấm ra ngoài thì đóng dropdown
            GestureDetector(
              onTap: _removeDropdown,
              behavior: HitTestBehavior.translucent,
            ),
            CompositedTransformFollower(
              link: _layerLink,
              offset: const Offset(0, -90), // đặt dropdown lên trên button
              showWhenUnlinked: false,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(20),
                  color: context.appTheme.colorScheme.surfaceContainer,
                  child: Container(
                    constraints: BoxConstraints(
                      // maxHeight: 300, // giới hạn chiều cao của dropdown
                      minWidth: 120, // chiều rộng tối thiểu của dropdown
                      maxWidth: 120, // chiều rộng tối thiểu của dropdown
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.options
                          .map((option) => InkWell(
                                onTap: () {
                                  widget.onSelected?.call(option);
                                  _removeDropdown();
                                },
                                child: widget.itemBuilder.call(context, option),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleDropdown,
          child: SizedBox(
            width: 36,
            height: 36,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedAttachment,
              color: theme.iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

enum AttachmentType {
  gallery,
  camera,
}

typedef WidgetBuilder<T> = Widget Function(BuildContext context, T item);
