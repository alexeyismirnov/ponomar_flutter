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
import 'church_page.dart';
import 'firebase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await GlobalPath.ensureInitialized();

  await FirebaseConfig.setup();

  await ConfigParam.initSharedParams(initFontSize: 22);
  ConfigParamExt.fastingLevel = ConfigParam<int>('fastingLevel', initValue: 0);
  ChurchFasting.fastingLevel = FastingLevel.values[ConfigParamExt.fastingLevel.val()];
  ConfigParamExt.notifications = ConfigParam<List<String>>('notifications', initValue: []);

  await JSON.load();

  await SaintModel("en").prepare();
  await SaintModel("ru").prepare();
  await SaintModel("cn").prepare();
  await SaintModel("hk").prepare();

  await rateMyApp.init();

  [
    "troparion.sqlite",
    "feofan.sqlite",
    "prayerbook_en.sqlite",
    "prayerbook_ru.sqlite",
    "prayerbook_cn.sqlite",
    "prayerbook_hk.sqlite",
    "canons.sqlite",
    "vigil_en.sqlite",
    "liturgy_en.sqlite",
    "vigil_ru.sqlite",
    "liturgy_ru.sqlite",
    "vigil_cn.sqlite",
    "liturgy_cn.sqlite",
    "vigil_hk.sqlite",
    "liturgy_hk.sqlite",
    "new_testament_overview.sqlite",
    "old_testament_overview.sqlite",
    "synaxarion_en.sqlite",
    "synaxarion_ru.sqlite",
    "synaxarion_cn.sqlite",
    "synaxarion_hk.sqlite",
    "typika_en.sqlite",
    "typika_ru.sqlite",
    "typika_cn.sqlite",
    "typika_hk.sqlite",
    "zvezdinsky.sqlite",
    "zerna.sqlite",
    "great_lent.db"
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
        Locale('zh', 'HK'),
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
        AnimatedTab(
            icon: const ImageIcon(
              AssetImage('assets/images/cross.png'),
            ),
            title: 'about_us',
            content: ChurchPage()),
      ]))));
}
