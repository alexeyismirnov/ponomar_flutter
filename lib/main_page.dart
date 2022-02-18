import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:supercharged/supercharged.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'calendar_appbar.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  DateTime date;
  DateTime savedDate;

  @override
  void initState() {
    super.initState();

    setDate(DateTime.now());
    savedDate = date;

    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () => postInit());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        final dt = DateTime.now();

        if (savedDate != DateTime(dt.year, dt.month, dt.day)) {
          setDate(dt);
          savedDate = date;
        }

        break;
      default:
        break;
    }
  }

  void postInit() {
    if (!ConfigParam.langSelected.val()) {
      ConfigParam.langSelected.set(true);
      AppLangDialog(
        labels: const ["English", "Русский"],
      ).show(context, canDismiss: false);
    }
  }

  void setDate(DateTime d) {
    if (d == null) return;

    date = DateTime(d.year, d.month, d.day);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: NestedScrollView(
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxIsScrolled) =>
                          [CalendarAppbar()],
                  body: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Center(child: Text("main page")))))));
}
