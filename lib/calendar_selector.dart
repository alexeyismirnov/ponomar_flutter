import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'month_container.dart';
import 'year_calendar.dart';

class CalendarSelector extends StatelessWidget {
  final DateTime date;
  CalendarSelector(this.date);

  @override
  Widget build(BuildContext context) => SelectorDialog(title: 'calendar', content: [
        ListTile(
            dense: true,
            title: Text('today'.tr(),
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            onTap: () {
              final d = DateTime.now();
              Navigator.pop(context, DateTime(d.year, d.month, d.day));
            }),
        ListTile(
            dense: true,
            title: Text('monthly'.tr(),
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            onTap: () {
              MonthContainer(date).show(context).then((date) => Navigator.pop(context, date));
            }),
        ListTile(
            dense: true,
            title: Text('yearly'.tr(),
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            onTap: () {
              YearCalendarView(date).push(context).then((date) => Navigator.pop(context, date));
            })
      ]);
}
