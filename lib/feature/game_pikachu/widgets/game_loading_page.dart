import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:meow_app/resources/theme/theme_data.dart';

import '../../../core/util/download_helper.dart';
import '../../../routers/route.dart';
import '../../../widgets/app_bar.dart';

class GameLoadingPage extends StatefulWidget {
  const GameLoadingPage({super.key});

  @override
  State<GameLoadingPage> createState() => _GameLoadingPageState();
}

class _GameLoadingPageState extends State<GameLoadingPage> with TickerProviderStateMixin {
  bool isLoadingRealData = true;
  bool isFakeProgressStarted = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  late Timer _iconTimer;
  int _currentIconIndex = 0;

  final List<IconData> _gameIcons = [
    Icons.sports_esports,
    HugeIcons.strokeRoundedGameController01,
    HugeIcons.strokeRoundedGameController02,
    HugeIcons.strokeRoundedGameController03,
  ];

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _gameIcons.shuffle();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(_fadeController);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    );

    _progressAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        goToGame();
      }
    });

    _iconTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      setState(() {
        _currentIconIndex = (_currentIconIndex + 1) % _gameIcons.length;
      });
    });

    _startRealLoading();
  }

  Future<void> _startRealLoading() async {
    await Future.delayed(const Duration(milliseconds: 800)); // giả lập delay
    final downloader = DownloadFromGithubUtil.pikachu;
    await downloader.initialize();

    // Khi load xong dữ liệu thật
    setState(() {
      isLoadingRealData = false;
      isFakeProgressStarted = true;
    });

    _progressController.forward(); // Bắt đầu chạy từ 0 → 1
  }

  void goToGame() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(RouteManager.pikachuGamePage);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    _iconTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Background icon
          Positioned.fill(
            child: Icon(
              _gameIcons[_currentIconIndex],
              color: theme.iconColor.withOpacity(0.08),
              size: 400,
            ),
          ),

          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Image.asset('assets/icon/icon.png'),
                ),
                const SizedBox(height: 14),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    isLoadingRealData ? 'Đang tải trò chơi...' : 'Chuẩn bị khởi động...',
                    style: textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 14),
                FractionallySizedBox(
                  widthFactor: 0.2,
                  child: isLoadingRealData
                      ? LinearProgressIndicator(
                          minHeight: 4.0,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.highlightColor2),
                          backgroundColor: theme.scaffoldBackgroundColor2,
                        )
                      : AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: _progressAnimation.value,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.highlightColor2),
                              backgroundColor: theme.scaffoldBackgroundColor2,
                              minHeight: 4.0,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircleAppBackButton(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
