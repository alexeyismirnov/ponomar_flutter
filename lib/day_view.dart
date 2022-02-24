import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'church_day.dart';
import 'church_calendar.dart';
import 'globals.dart';

class DayView extends StatefulWidget {
  final DateTime date, dateOld;

  DayView({Key? key, required this.date})
      : dateOld = date.subtract(const Duration(days: 13)),
        super(key: key);

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  DateTime get date => widget.date;
  DateTime get dateOld => widget.dateOld;

  late Cal cal;

  @override
  void initState() {
    super.initState();
    cal = Cal.fromDate(date);
  }

  Widget getDate() {
    final df1 = DateFormat.yMMMMEEEEd(context.languageCode);
    final df2 = DateFormat.yMMMMd(context.languageCode);

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
                    AutoSizeText(df1.format(date).capitalize(),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        minFontSize: 5,
                        style: Theme.of(context).textTheme.headline6),
                    AutoSizeText(df2.format(dateOld) + " " + "old_style".tr(),
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        minFontSize: 5,
                        style: Theme.of(context).textTheme.subtitle1),
                  ]))
            ]),
        onTap: () => showDatePicker(
                    context: context,
                    initialDate: date,
                    locale: Locale(context.languageCode),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100))
                .then((newDate) {
              if (newDate != null) {
                DateChangedNotification(newDate).dispatch(context);
              }
            }));

    return dateWidget;
  }

  Widget getFeastWidget(ChurchDay d) {
    if (d.type == FeastType.great) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          child: Row(children: [
            SvgPicture.asset("assets/images/great.svg", height: 30),
            const SizedBox(width: 10),
            Expanded(
                child: Text(d.name.tr(),
                    style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.red)))
          ]));
    } else {
      if (d.type.name != "none") {
        return RichText(
            text: TextSpan(children: [
          WidgetSpan(
              child:
                  SvgPicture.asset("assets/images/${d.type.name.toLowerCase()}.svg", height: 15)),
          TextSpan(text: d.name.tr(), style: Theme.of(context).textTheme.titleMedium)
        ]));
      } else {
        return Text(d.name.tr(), style: Theme.of(context).textTheme.titleMedium);
      }
    }
  }

  Widget getDescription() {
    var list = [cal.getWeekDescription(date), cal.getToneDescription(date)];
    var weekDescr = list.whereType<String>().join('; ');
    var dayDescr = cal.getDayDescription(date);
    var greatFeasts = Cal.getGreatFeast(date);

    List<Widget> feastWidgets = [];

    if (greatFeasts.isNotEmpty) {
      feastWidgets = greatFeasts.map((d) => getFeastWidget(d)).toList();
    } else {
      feastWidgets = dayDescr.map((d) => getFeastWidget(d)).toList();
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (weekDescr.isNotEmpty
                ? <Widget>[Text(weekDescr, style: Theme.of(context).textTheme.titleMedium)]
                : <Widget>[]) +
            feastWidgets);
  }

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 10);
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [getDate(), space, getDescription()]);
  }
}
