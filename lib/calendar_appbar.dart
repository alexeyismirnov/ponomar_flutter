import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

class CalendarAppbar extends StatelessWidget {
  final bool showActions;
  final String title;

  CalendarAppbar({this.showActions = true, this.title = "title"});

  Widget _getActions(BuildContext context) {
    List<PopupMenuEntry> contextMenu = [
      PopupMenuItem(
          child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                AppLangDialog(
                  labels: const ["English", "Русский"],
                ).show(context);
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
                  title: const Text('bg_color').tr())))
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
      title:
          Text(title.tr(), textAlign: TextAlign.left, style: Theme.of(context).textTheme.headline6),
      centerTitle: false,
      actions: showActions
          ? [
              IconButton(
                  icon: const Icon(Icons.rate_review_outlined, size: 30.0), onPressed: () {}),
              _getActions(context)
            ]
          : []);
}
