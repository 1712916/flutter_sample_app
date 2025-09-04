import '../../core/persistence/app_image_manager.dart';
import '../database_model/object_box_entity/chat_entity.dart';
import '../models/chat.dart';
import '../models/image_storage_model.dart';

class ChatHistoryFilterData {
  final int limit;
  final int offset;
  final ChatSource? source;
  final List<DateTime>? rangeDate;

  ChatHistoryFilterData({
    required this.limit,
    required this.offset,
    required this.source,
    required this.rangeDate,
  });
}

abstract class ChatRepository {
  Future<List<ChatModel>> getChatHistory({ChatHistoryFilterData? filter});

  Future sendTextMessage(ChatSource source, String message);

  Future sendImagesMessage(ChatSource source, List<String> images);
}

class ChatRepositoryImpl extends ChatRepository {
  final _ChatSendRepository<String> _sendTextRepository = _SendTextRepository();
  final _ChatSendRepository<List<String>> _sendImageRepository = _SendImageRepository();

  @override
  Future sendImagesMessage(ChatSource source, List<String> images) {
    return _sendImageRepository.send(source, images);
  }

  @override
  Future sendTextMessage(ChatSource source, String message) {
    return _sendTextRepository.send(source, message);
  }

  @override
  Future<List<ChatModel>> getChatHistory({ChatHistoryFilterData? filter}) {
    return AObjectBox.create().then(
      (objectBox) {
        final store = objectBox.store.box<ChatEntity>();
        return store.getAll().map(ChatModel.fromEntity).toList();
      },
    );
  }
}

abstract class _ChatSendRepository<T> {
  Future send(ChatSource source, T data);

  ChatMessageType get type;
}

class _SendTextRepository extends _ChatSendRepository<String> {
  @override
  Future send(ChatSource source, String data) async {
    AObjectBox.create().then(
      (objectBox) {
        final store = objectBox.store.box<ChatEntity>();
        store.put(
          ChatEntity(
            message: data,
            sender: source.toString(),
            type: type.toString(),
            createdAt: DateTime.now(),
          ),
        );
      },
    );
  }

  @override
  ChatMessageType get type => ChatMessageType.text;
}

class _SendImageRepository extends _ChatSendRepository<List<String>> {
  final AppImageManager _appImageManager = AppImageManager(ImageStorageFeature.chat);

  @override
  Future send(ChatSource source, List<String> images) async {
    final storageImages = await Future.wait(images.map(
      (e) => _appImageManager.saveImageFromPath(e),
    ));

    final dataString = storageImages.map((e) => e.path).join(',');

    AObjectBox.create().then(
      (objectBox) {
        final store = objectBox.store.box<ChatEntity>();
        store.put(
          ChatEntity(
            message: dataString,
            sender: source.toString(),
            type: type.toString(),
            createdAt: DateTime.now(),
          ),
        );
      },
    );
  }

  @override
  ChatMessageType get type => ChatMessageType.image;
}
