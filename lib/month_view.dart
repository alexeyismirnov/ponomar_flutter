import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:after_init/after_init.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:quiver/time.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'globals.dart';
import 'church_fasting.dart';
import 'church_calendar.dart';

class MonthView extends StatefulWidget {
  final DateTime date;
  const MonthView(this.date);

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
    cellWidth = (context.screenWidth > 500) ? 70.0 : 40.0;
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
          List<Widget>.generate(startGap, (_) => Container(width: cellWidth, height: cellHeight)) +
              List<Widget>.generate(totalDays, (i) {
                final currentDate = DateTime(date.year, date.month, i + 1);
                final fasting = ChurchFasting.forDate(currentDate);

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

                if (currentDate == today) {
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
              }));
}
