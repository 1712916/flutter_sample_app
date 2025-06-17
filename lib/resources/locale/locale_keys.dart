import 'dart:ui';

abstract class LocaleUtils {
  static const List<Locale> locales = const [
    english,
    vietnamese,
  ];

  static const vietnamese = Locale('vi', 'VN');

  static const english = Locale('en', 'US');

  static Map<String, String> get lKeys => {
        'en': 'english',
        'vi': 'vietnamese',
      };

  static String path = 'assets/locales';
}

class LKey {
  static const String appName = 'appName';
  static const String devInformation = 'devInformation';

  //english, vietnamese
  static const String english = 'English';
  static const String vietnamese = 'Vietnamese';
  static const String title = 'title';
  static const String saveToPhone = 'saveToPhone';
  static const String haveAnError = 'haveAnError';
  static const String haveAnErrorDetail = 'haveAnErrorDetail';
  static const String retry = 'retry';
  static const String meowTitle = 'meowTitle';
  static const String dogTitle = 'dogTitle';
  static const String downLoadThisImage = 'downLoadThisImage';
  static const String catOrDog = 'catOrDog';
  static const String settings = 'settings';
  static const String orderSearch = 'orderSearch';
  static const String imageType = 'imageType';
  static const String savedSettings = 'savedSettings';
  static const String savedSettingsFailure = 'savedSettingsFailure';
  static const String yes = 'yes';
  static const String no = 'no';
  static const String doYouWantToSaveChanged = 'doYouWantToSaveChanged';
  static const String changeDetection = 'changeDetection';
  static const String downloadPath = 'downloadPath';
  static const String errorWhenTryShare = 'errorWhenTryShare';
  static const String waitToShare = 'waitToShare';
  static const String shareTo = 'shareTo';
  static const String original = 'original';
  static const String download = 'download';
  static const String share = 'share';
  static const String save = 'save';
  static const String delete = 'delete';
  static const String message = 'message';
  static const String instagram = 'instagram';
  static const String telegram = 'telegram';
  static const String saveSuccess = 'saveSuccess';
  static const String shareFile = 'shareFile';
  static const String checkInternetAccess = 'checkInternetAccess';
  static const String timeOutMessage = 'timeOutMessage';
  static const String presentationPattern = 'presentationPattern';
  static const String importImageOption = 'importImageOption';
  static const String reScrambleImage = 'reScrambleImage';
  static const String takeAPhoto = 'takeAPhoto';
  static const String importFromPhoto = 'importFromPhoto';
  static const String version = 'version';
  static const String description = 'description';
  static const String descriptionDetail = 'descriptionDetail';
  static const String function = 'function';
  static const String functionDetail = 'functionDetail';
  static const String contact = 'contact';
  static const String currentPattern = 'currentPattern';
  static const String editImage = 'editImage';
  static const String source = 'source';
  static const String language = 'language';
  static const String darkMode = 'darkMode';
  static const String storagePath = 'storagePath';
  static const String camera = 'camera';
  static const String gallery = 'gallery';
  static const String cropImage = 'cropImage';

  ///show case
  static const String switchViewTitle = 'showcase.switchViewTitle';
  static const String switchViewDescription = 'showcase.switchViewDescription';

  static const String gridViewTitle = 'showcase.gridViewTitle';
  static const String gridViewDescription = 'showcase.gridViewDescription';

  static const String shareViewTitle = 'showcase.shareViewTitle';
  static const String shareViewDescription = 'showcase.shareViewDescription';

  static const String gameBoardTitle = 'showcase.gameBoardTitle';
  static const String gameBoardDescription = 'showcase.gameBoardDescription';

  static const String enjoyAppDescription = 'enjoyAppDescription';

  ///favourite
  static const String favourite = 'favourite';
  static const String choose = 'choose';
  static const String noFavourite = 'noFavourite';
  static const String selected = 'selected';

  ///game complete
  static const String gameCompleteTitle = 'gameCompleteTitle';
  static const String gameCompleteDescription = 'gameCompleteDescription';
  static const String playAgain = 'playAgain';
  static const String exit = 'exit';

  static const String gameController = 'gameController';
  static const String emptyBoxFocus = 'emptyBoxFocus';
  static const String shareGameDescription = 'shareGameDescription';

  static const String reviewApp = 'reviewApp';
  static const String playGame = 'playGame';
  static const String play = 'play';
  static const String clear = 'clear';
  static const String gameMenu = 'gameMenu';
  static const String sortGame = 'sortGame';
  static const String memoryGame = 'memoryGame';
  static const String requireSelectImageDescription = 'requireSelectImageDescription';
  static const String maximumSelectImageDescription = 'maximumSelectImageDescription';
  static const String selectedTitle = 'selectedTitle';
  static const String startGame = 'startGame';

  static const String sticker = 'sticker';
  static const String emptyData = 'emptyData';
  static const String refreshData = 'refreshData';

  static const String guide = 'guide';
  static const String autoPlay = 'autoPlay';
  static const String autoPlayDescription = 'autoPlayDescription';
  static const String autoPlayMode = 'autoPlayMode';
  static const String soundEffects = 'soundEffects';
  static const String backgroundMusic = 'backgroundMusic';
  static const String chooseMusicTrack = 'chooseMusicTrack';
  static const String gameControls = 'gameControls';
  static const String soundSettings = 'soundSettings';
}
