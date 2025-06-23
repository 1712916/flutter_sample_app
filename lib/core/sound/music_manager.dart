import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Class to manage downloading and caching of music files
class MusicManager {
  // Singleton instance
  static final MusicManager _instance = MusicManager._internal();

  factory MusicManager() => _instance;

  MusicManager._internal();

  final Dio _dio = Dio();

  // Music URLs
  static const String nightHappinessUrl = 'https://raw.githubusercontent.com/bossxomlut/assets/main/music/night-happiness.mp3';
  static const String justRelaxUrl = 'https://raw.githubusercontent.com/bossxomlut/assets/main/music/just-relax.mp3';

  // Default music filename
  static const String defaultMusic = 'night-happiness.mp3';

  // Map of music URLs to local file paths
  final Map<String, String> _musicFiles = {
    'night-happiness.mp3': nightHappinessUrl,
    'just-relax.mp3': justRelaxUrl,
  };

  // Keys for SharedPreferences
  static const String _musicDownloadedKey = 'music_downloaded_key';

  /// Initialize and check for music files
  Future<void> initialize() async {
    try {
      // Check if we've already downloaded the music files
      final prefs = await SharedPreferences.getInstance();
      final downloaded = prefs.getBool(_musicDownloadedKey) ?? false;

      if (!downloaded) {
        // Download all music files
        await downloadAllMusic();

        // Mark as downloaded
        await prefs.setBool(_musicDownloadedKey, true);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing music manager: $e');
      }
    }
  }



  /// Download all music files to local storage using isolate
  Future<void> downloadAllMusic() async {
    try {
      final dir = await _getMusicDirectory();
      final musicDirPath = dir.path;
      
      // Use compute to run the function in a separate isolate
      await compute(
        (Map<String, dynamic> params) async {
          final musicFiles = params['musicFiles'] as Map<String, String>;
          final musicDir = params['musicDir'] as String;
          final dio = Dio();
          
          for (final entry in musicFiles.entries) {
            final filename = entry.key;
            final url = entry.value;
            final filePath = '$musicDir/$filename';

            // Skip if file already exists
            if (await File(filePath).exists()) {
              continue;
            }

            // Download file
            try {
              await dio.download(
                url,
                filePath,
                onReceiveProgress: (received, total) {
                  if (kDebugMode && total != -1) {
                    print('Download $filename: ${(received / total * 100).toStringAsFixed(0)}%');
                  }
                },
              );

              if (kDebugMode) {
                print('Downloaded $filename to $filePath');
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error downloading $filename: $e');
              }
            }
          }
        },
        {
          'musicFiles': _musicFiles,
          'musicDir': musicDirPath,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading all music: $e');
      }
    }
  }

  /// Download a single music file
  Future<void> _downloadMusic(String filename, String url) async {
    try {
      final dir = await _getMusicDirectory();
      final filePath = '${dir.path}/$filename';

      // Skip if file already exists
      if (await File(filePath).exists()) {
        return;
      }

      // Download file
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (kDebugMode && total != -1) {
            print('Download $filename: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      if (kDebugMode) {
        print('Downloaded $filename to $filePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading $filename: $e');
      }
    }
  }

  /// Get the directory where music files are stored
  Future<Directory> _getMusicDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final musicDir = Directory('${appDir.path}/music');

    // Create directory if it doesn't exist
    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }

    return musicDir;
  }

  /// Get the path to a music file
  Future<String?> getMusicFilePath(String filename) async {
    try {
      final dir = await _getMusicDirectory();
      final filePath = '${dir.path}/$filename';

      // Check if file exists
      if (await File(filePath).exists()) {
        return filePath;
      } else {
        // Try to download if it doesn't exist
        final url = _musicFiles[filename];
        if (url != null) {
          await _downloadMusic(filename, url);

          // Check again after download
          if (await File(filePath).exists()) {
            return filePath;
          }
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting music file path: $e');
      }
      return null;
    }
  }

  /// Get the path to the default music file
  Future<String?> getDefaultMusicPath() async {
    return getMusicFilePath(defaultMusic);
  }

  /// List all available music files
  Future<List<String>> getAvailableMusicFiles() async {
    try {
      final dir = await _getMusicDirectory();
      final files = dir.listSync().whereType<File>().map((file) => file.path.split('/').last).toList();
      return files;
    } catch (e) {
      if (kDebugMode) {
        print('Error listing music files: $e');
      }
      return [];
    }
  }
}
