// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'main_page.dart';
import 'library_page.dart';
import 'globals.dart';
import 'church_fasting.dart';
import 'saint_model.dart';
import 'icon_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await GlobalPath.ensureInitialized();

  await ConfigParam.initSharedParams(initFontSize: 22);
  ConfigParamExt.fastingLevel = ConfigParam<int>('fastingLevel', initValue: 0);
  ChurchFasting.fastingLevel = FastingLevel.values[ConfigParamExt.fastingLevel.val()];

  await JSON.load();

  await SaintModel("en").prepare();
  await SaintModel("ru").prepare();
  await SaintModel("cn").prepare();

  [
    "troparion.sqlite",
    "feofan.sqlite",
    "liturgy.sqlite",
    "new_testament_overview.sqlite",
    "old_testament_overview.sqlite",
    "synaxarion.sqlite",
    "typika.sqlite",
    "vigil.sqlite",
    "zvezdinsky.sqlite"
  ].forEach((f) async => await DB.prepare(basename: "assets/books", filename: f));

  await IconModel.prepare();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(EasyLocalization(
      supportedLocales: const [
        Locale('en', ''),
        Locale('ru', ''),
        Locale('zh', 'CN'),
      ],
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
