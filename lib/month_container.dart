import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:after_init/after_init.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'month_view.dart';
import 'globals.dart';

class MonthContainer extends StatefulWidget {
  final DateTime initialDate;
  const MonthContainer(this.initialDate);

  @override
  _MonthContainerState createState() => _MonthContainerState();
}

class _MonthContainerState extends State<MonthContainer> with AfterInitMixin<MonthContainer> {
  static const initialPage = 100000;
  late PageController _controller;

  late String title;
  late List<String> weekdays;
  late double cellWidth, containerWidth;

  @override
  void initState() {
    super.initState();

    _controller = PageController(initialPage: initialPage);
    updateTitle();
  }

  @override
  void didInitState() {
    if (context.languageCode == 'en') {
      weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    } else if (context.languageCode == 'ru') {
      weekdays = ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"];
    }

    if (context.screenWidth > 500) {
      cellWidth = 70.0;
      containerWidth = 510.0;
    } else {
      cellWidth = 40.0;
      containerWidth = 300.0;
    }
  }

  void updateTitle([int index = initialPage]) {
    final currentDate = Jiffy(widget.initialDate).add(months: index - initialPage);

    setState(() {
      title = currentDate.format("LLLL yyyy").capitalize();
    });
  }

  @override
  Widget build(BuildContext context) {
    const spacer = SizedBox(height: 10);

    return AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: const EdgeInsets.all(5.0),
        content: Container(
            width: 300.0,
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(title, style: Theme.of(context).textTheme.titleLarge)
                      ]),
                  spacer,
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: weekdays
                          .map<Widget>((d) => Container(
                              width: cellWidth,
                              child: AutoSizeText(d.toUpperCase(),
                                  maxLines: 1,
                                  minFontSize: 5,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .copyWith(color: Theme.of(context).secondaryHeaderColor))))
                          .toList()),
                  spacer,
                  SizedBox(
                      width: containerWidth,
                      height: cellWidth * 6,
                      child: PageView.builder(
                          controller: _controller,
                          onPageChanged: (page) => updateTitle(page),
                          itemBuilder: (BuildContext context, int index) {
                            final currentDate =
                                Jiffy(widget.initialDate).add(months: index - initialPage).dateTime;
                            return Align(
                                alignment: Alignment.topCenter, child: MonthView(currentDate));
                          }))
                ])));
  }
}
