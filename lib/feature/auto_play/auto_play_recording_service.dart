import 'package:dio/dio.dart';

class AutoPlayRecordingService {
  static const String _recordServer = 'http://192.168.1.3:5001'; // Replace with your actual server URL

  //Just using for testing purpose
  static const bool recordGame = false;

  static final AutoPlayRecordingService _instance = AutoPlayRecordingService._internal();

  factory AutoPlayRecordingService() {
    return _instance;
  }

  AutoPlayRecordingService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _recordServer,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  Dio get dio => _dio;

  /// Start recording auto-play session
  Future<bool> start() async {
    try {
      final response = await _dio.get('/start');
      return response.statusCode == 200;
    } catch (e) {
      // Log error if needed
      return false;
    }
  }

  /// Stop recording auto-play session
  Future<bool> stop() async {
    try {
      final response = await _dio.get('/stop');
      return response.statusCode == 200;
    } catch (e) {
      // Log error if needed
      return false;
    }
  }

  /// Send custom event during recording
  Future<bool> sendEvent(String eventType, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/event', data: {
        'type': eventType,
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
      return response.statusCode == 200;
    } catch (e) {
      // Log error if needed
      return false;
    }
  }

  /// Check if recording server is available
  Future<bool> isAvailable() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
