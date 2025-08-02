import '../../core/index.dart';
import 'models/cell_content_factory.dart';

class PikachuGameLoader {
  Future loadGame() async {
    final downloaderMeow = DownloadFromGithubUtil.pikachuMeow;
    await downloaderMeow.initialize();

    final meowPaths = await downloaderMeow.getAvailableFilePaths();
    CellContentFactory.setMeowImagePaths(meowPaths);

    //downloaderGaow
    final downloaderGaow = DownloadFromGithubUtil.pikachuGaow;
    await downloaderGaow.initialize();

    final gaowPaths = await downloaderGaow.getAvailableFilePaths();
    CellContentFactory.setGaowImagePaths(gaowPaths);
  }
}
