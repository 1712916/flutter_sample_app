import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meow_app/resources/resources.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import 'text.dart';

Future<String?> openImage(ImageSource imageSource) async {
  XFile? imageFile = await ImagePicker().pickImage(source: imageSource, imageQuality: 90);
  if (imageFile != null) {
    return imageFile.path;
  }

  return null;
}

class ImagePickerWidget extends StatelessWidget {
  const ImagePickerWidget({super.key, this.onImageSelected});

  final ValueChanged<String?>? onImageSelected;

  static OverlayEntry? _overlayEntry;

  static void showOverlay(BuildContext context, Widget child) {
    if (_overlayEntry != null) return; // Tránh tạo nhiều overlay cùng lúc

    //bottom is position get from context
    // 👉 Lấy vị trí và kích thước của widget để hiển thị overlay ngay phía trên
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Nhấn vào ngoài để đóng overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: () => hideOverlay(),
              behavior: HitTestBehavior.opaque,
            ),
          ),

          // Hiển thị widget được truyền vào
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).size.height - position.dy + 8, // 👉 Hiển thị bên trên widget
            child: Material(
              color: Colors.transparent,
              child: child,
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Center(
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: theme.cardColor2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(Icons.camera, color: theme.iconColor),
              title: LText(
                LKey.camera,
                style: theme.textTheme.titleMedium,
              ),
              onTap: () async {
                String? imagePath = await openImage(ImageSource.camera);
                if (imagePath != null) {
                  onImageSelected?.call(imagePath);
                }
                hideOverlay();
              },
            ),
            Divider(height: 1),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(Icons.photo_library, color: theme.iconColor),
              title: LText(
                LKey.gallery,
                style: theme.textTheme.titleMedium,
              ),
              onTap: () async {
                String? imagePath = await openImage(ImageSource.gallery);
                if (imagePath != null) {
                  onImageSelected?.call(imagePath);
                }
                hideOverlay();
              },
            )
          ],
        ),
      ),
    );
  }
}
