import 'package:flutter/material.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:jiffy/jiffy.dart';

import 'globals.dart';
import 'calendar_appbar.dart';
import 'day_view.dart';
import 'bible_model.dart';
import 'firebase_config.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int initialPage = 100000;

  late DateTime date;
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    _controller = PageController(initialPage: initialPage);
    setDate(DateTime.now());

    WidgetsBinding.instance?.addObserver(this);

    Future.delayed(Duration.zero, () => postInit());
  }

  void postInit() async {
    if (!ConfigParam.langSelected.val()) {
      ConfigParam.langSelected.set(true);
      AppLangDialog(
        labels: const ["English", "Русский", "简体中文", "繁體中文"],
      ).show(context, canDismiss: false);
    } else {
      await OldTestamentModel(context.countryCode).prepare();
      await NewTestamentModel(context.countryCode).prepare();

      await FirebaseConfig.requestPermissions();
    }

    await Jiffy.locale(context.languageCode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        final dt = DateTime.now();

        if (date != DateTime(dt.year, dt.month, dt.day)) {
          setDate(dt);
        }

        break;
      default:
        break;
    }
  }

  void setDate(DateTime d) {
    if (rateMyApp.shouldOpenDialog) {
      rateMyApp.showRateDialog(context, title: "title".tr(), message: "please_rate".tr());
    }

    setState(() {
      date = DateTime(d.year, d.month, d.day);
      if (_controller.hasClients) {
        initialPage = _controller.page!.round();
      }
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
              [CalendarAppbar()],
          body: Padding(
              padding: const EdgeInsets.all(10),
              child: PageView.builder(
                controller: _controller,
                itemBuilder: (BuildContext context, int index) {
                  final currentDate = date.add(Duration(days: index - initialPage));
                  return NotificationListener<Notification>(
                      onNotification: (n) {
                        if (n is DateChangedNotification) setDate(n.newDate);
                        return true;
                      },
                      child: DayView(key: ValueKey(currentDate), date: currentDate));
                },
              ))));
}
