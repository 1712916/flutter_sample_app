import 'dart:developer';

import '../../core/index.dart';
import 'models/cell_content_factory.dart';

class PikachuGameLoader {
  Future loadGame() async {
    final stopwatch = Stopwatch()..start();
    await Future.wait([
      Future(() async {
        final downloaderMeow = DownloadFromGithubUtil.pikachuMeow;
        await downloaderMeow.initialize();

        final meowPaths = await downloaderMeow.getAvailableFilePaths();
        CellContentFactory.setMeowImagePaths(meowPaths);
      }),
      Future(() async {
        //downloaderGaow
        final downloaderGaow = DownloadFromGithubUtil.pikachuGaow;
        await downloaderGaow.initialize();

        final gaowPaths = await downloaderGaow.getAvailableFilePaths();
        CellContentFactory.setGaowImagePaths(gaowPaths);
      }),
    ]);
    stopwatch.stop();
    log('Pikachu game assets loaded in ${stopwatch.elapsedMilliseconds} ms', name: 'PikachuGameLoader');
  }
}
