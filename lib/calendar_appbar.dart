import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:launch_review/launch_review.dart';

import 'globals.dart';
import 'church_fasting.dart';
import 'firebase_config.dart';

class FastingLevelDialog extends StatelessWidget {
  final labels = ['laymen_fasting', 'monastic_fasting'];

  Widget _getListItem(BuildContext context, int index) {
    return CheckboxListTile(
        title: Text(labels[index]).tr(),
        value: ConfigParamExt.fastingLevel.val() == index,
        onChanged: (_) {
          ConfigParamExt.fastingLevel.set(index);
          ChurchFasting.fastingLevel = FastingLevel.values[index];
          RestartWidget.restartApp(context);
        });
  }

  @override
  Widget build(BuildContext context) => SelectorDialog(title: 'fasting_level', content: [
        _getListItem(context, 0),
        _getListItem(context, 1),
      ]);
}

class CalendarAppbar extends StatelessWidget {
  final bool showActions;
  final String title;

  CalendarAppbar({this.showActions = true, this.title = "title"});

  Widget _getActions(BuildContext context) {
    List<PopupMenuEntry> contextMenu = [
      PopupMenuItem(
          child: GestureDetector(
              onTap: () async {
                Navigator.pop(context);

                ConfigParamExt.notifications.set(<String>[]);
                await FirebaseConfig.cancel();

                AppLangDialog(
                  labels: const ["English", "Русский", "简体中文", "繁體中文"],
                ).show(context, canDismiss: false);
              },
              child: ListTile(
                  leading: const Icon(Icons.translate, size: 30.0),
                  title: const Text('language').tr()))),
      PopupMenuItem(
          child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                AppThemeDialog().show(context);
              },
              child: ListTile(
                  leading: const Icon(Icons.color_lens_outlined, size: 30.0),
                  title: const Text('bg_color').tr()))),
      PopupMenuItem(
          child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                FastingLevelDialog().show(context);
              },
              child: ListTile(
                  leading: const Icon(Icons.restaurant_menu_outlined, size: 30.0),
                  title: const Text('fasting_level').tr())))
    ];

    return PopupMenuButton(
      itemBuilder: (_) => contextMenu,
    );
  }

  @override
  Widget build(BuildContext context) => SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      toolbarHeight: 50.0,
      pinned: false,
      floating: true,
      title:
          Text(title.tr(), textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline6),
      centerTitle: false,
      actions: showActions
          ? [
              IconButton(
                  icon: const Icon(Icons.rate_review_outlined, size: 30.0),
                  onPressed: () => LaunchReview.launch(
                      androidAppId: "com.rlc.ponomar_ru", iOSAppId: "1095609748")),
              _getActions(context)
            ]
          : []);
}
