import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'calendar_appbar.dart';
import 'church_calendar.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  late DateTime date;
  late ChurchCalendar cal;
  late int initialPage;
  late PageController _controller;

  @override
  void initState() {
    super.initState();

    setDate(DateTime.now());

    initialPage = 100000;
    _controller = PageController(initialPage: initialPage);

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
    if (d == null) return;

    date = DateTime(d.year, d.month, d.day);
    cal = ChurchCalendar.fromDate(date);
  }

  Widget _buildPage(int index) {
    final currentDate = date.add(Duration(days: index - initialPage));
    final currentDateOld = currentDate.subtract(Duration(days: 13));

    final df1 = DateFormat.yMMMMEEEEd('ru');
    final df2 = DateFormat.yMMMMd('ru');

    var dateWidget = GestureDetector(
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.calendar_today, size: 30.0),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                    AutoSizeText(df1.format(currentDate).capitalize(),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        minFontSize: 5,
                        style: Theme.of(context).textTheme.headline6),
                    AutoSizeText(df2.format(currentDateOld) + ' (ст. ст.)',
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        minFontSize: 5,
                        style: Theme.of(context).textTheme.subtitle1),
                  ]))
            ]),
        onTap: () {});

    return dateWidget;
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
                  body: Padding(
                      padding: const EdgeInsets.all(15),
                      child: PageView.builder(
                        controller: _controller,
                        itemBuilder: (BuildContext context, int index) {
                          return ListView(children: [_buildPage(index)]);
                        },
                      ))))));
}
