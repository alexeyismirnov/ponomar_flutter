import 'package:flutter/material.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:ponomar/globals.dart';

import 'calendar_appbar.dart';
import 'day_view.dart';

// O. S. : 舊式日期

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

  void postInit() {
    if (!ConfigParam.langSelected.val()) {
      ConfigParam.langSelected.set(true);
      AppLangDialog(
        labels: const ["English", "Русский"],
      ).show(context, canDismiss: false);
    }
  }

  void setDate(DateTime d) {
    setState(() {
      date = DateTime(d.year, d.month, d.day);
      if (_controller.hasClients) {
        initialPage = _controller.page!.round();
      }
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: NestedScrollView(
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
                      [CalendarAppbar()],
                  body: Padding(
                      padding: const EdgeInsets.all(15),
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
                      ))))));
}
