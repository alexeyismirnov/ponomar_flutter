// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'main_page.dart';
import 'library_page.dart';
import 'globals.dart';
import 'church_fasting.dart';
import 'bible_model.dart';
import 'saint_model.dart';
import 'icon_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await ConfigParam.initSharedParams(initFontSize: 18);
  ConfigParamExt.fastingLevel = ConfigParam<int>('fastingLevel', initValue: 0);
  ChurchFasting.fastingLevel = FastingLevel.values[ConfigParamExt.fastingLevel.val()];

  await JSON.load();

  await OldTestamentModel("en").prepare();
  await OldTestamentModel("ru").prepare();
  await NewTestamentModel("en").prepare();
  await NewTestamentModel("ru").prepare();

  await SaintModel("en").prepare();
  await SaintModel("ru").prepare();

  await IconModel.prepare();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(EasyLocalization(
      supportedLocales: const [Locale('en', ''), Locale('ru', '')],
      path: 'ui,cal,reading,library',
      assetLoader: DirectoryAssetLoader(basePath: "assets/translations"),
      fallbackLocale: const Locale('en', ''),
      startLocale: const Locale('en', ''),
      child: RestartWidget(ContainerPage(tabs: [
        AnimatedTab(icon: const Icon(Icons.home), title: 'homepage', content: MainPage()),
        AnimatedTab(
            icon: const ImageIcon(
              AssetImage('assets/images/library.png'),
            ),
            title: 'library',
            content: LibraryPage()),
      ]))));
}
