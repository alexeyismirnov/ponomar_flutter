import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:after_init/after_init.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:quiver/time.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'globals.dart';
import 'church_fasting.dart';
import 'church_calendar.dart';

class WeekdaysView extends StatefulWidget {
  final bool short;
  WeekdaysView({this.short = false});

  @override
  _WeekdaysViewState createState() => _WeekdaysViewState();
}

class _WeekdaysViewState extends State<WeekdaysView> with AfterInitMixin<WeekdaysView> {
  late List<String> weekdays;
  late double cellWidth;

  @override
  void didInitState() {
    if (context.languageCode == 'en') {
      weekdays = widget.short
          ? ["S", "M", "T", "W", "T", "F", "S"]
          : ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
    } else if (context.languageCode == 'ru') {
      weekdays = widget.short
          ? ["П", "В", "С", "Ч", "П", "С", "В"]
          : ["ПН", "ВТ", "СР", "ЧТ", "ПТ", "СБ", "ВС"];
    } else if (context.languageCode == 'zh') {
      weekdays = ["日", "一", "二", "三", "四", "五", "六"];
    }

    cellWidth = (context.isTablet) ? 70.0 : 40.0;
  }

  @override
  Widget build(BuildContext context) => Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: weekdays
          .map<Widget>((d) => SizedBox(
              width: cellWidth,
              height: 30,
              child: AutoSizeText(d.toUpperCase(),
                  maxLines: 1,
                  minFontSize: 5,
                  textAlign: TextAlign.center,
                  style: widget.short
                      ? Theme.of(context).textTheme.titleLarge!
                      : Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: Theme.of(context).secondaryHeaderColor))))
          .toList());
}

class MonthView extends StatefulWidget {
  final DateTime date;
  final bool highlightToday;
  const MonthView(this.date, {this.highlightToday = true});

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> with AfterInitMixin<MonthView> {
  DateTime get date => widget.date;
  late DateTime today;

  late double cellWidth, cellHeight;
  late int firstDayOfWeek;
  late int startGap;
  late int totalDays;

  @override
  void didInitState() {
    cellWidth = context.isTablet ? 70.0 : 40.0;
    cellHeight = cellWidth;

    firstDayOfWeek = DateFormat.EEEE(context.languageCode).dateSymbols.FIRSTDAYOFWEEK + 1;

    final monthStart = DateTime(date.year, date.month, 1);
    startGap = (monthStart.weekday < firstDayOfWeek)
        ? 7 - (firstDayOfWeek - monthStart.weekday)
        : monthStart.weekday - firstDayOfWeek;

    totalDays = daysInMonth(date.year, date.month);

    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) => Wrap(
      children:
          List<Widget>.generate(startGap, (_) => SizedBox(width: cellWidth, height: cellHeight)) +
              List<Widget>.generate(
                  totalDays,
                  (i) => FutureBuilder<FastingModel>(
                      future: ChurchFasting.forDate(
                          DateTime(date.year, date.month, i + 1), context.countryCode),
                      builder: (BuildContext context, AsyncSnapshot<FastingModel> snapshot) {
                        if (!snapshot.hasData) return Container();

                        final fasting = snapshot.data!;
                        final currentDate = DateTime(date.year, date.month, i + 1);

                        Color? textColor;
                        FontWeight fontWeight;

                        if (Cal.getGreatFeast(currentDate).isNotEmpty) {
                          fontWeight = FontWeight.bold;
                          textColor = Colors.red;
                        } else {
                          fontWeight = FontWeight.normal;

                          textColor = fasting.type == FastingType.noFast ||
                                  fasting.type == FastingType.noFastMonastic
                              ? Theme.of(context).textTheme.titleLarge!.color
                              : Colors.black;
                        }

                        if (currentDate == today) {
                          textColor = Colors.white;
                        }

                        Widget content = Center(
                            child: AutoSizeText("${i + 1}",
                                maxLines: 1,
                                minFontSize: 5,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontWeight: fontWeight, color: textColor)));

                        Widget wrapper;

                        if (currentDate == today && widget.highlightToday) {
                          wrapper = Container(
                              width: cellWidth,
                              height: cellHeight,
                              color: fasting.type.color,
                              child: Container(
                                  width: cellWidth,
                                  height: cellHeight,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red,
                                  ),
                                  child: content));
                        } else {
                          wrapper = Container(
                              width: cellWidth,
                              height: cellHeight,
                              color: fasting.type.color,
                              child: content);
                        }

                        return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.pop(context, currentDate);
                            },
                            child: wrapper);
                      })));
}
