import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:after_init/after_init.dart';

import 'dart:developer';

import 'church_day.dart';
import 'church_calendar.dart';
import 'church_fasting.dart';
import 'church_reading.dart';
import 'globals.dart';
import 'pericope.dart';
import 'saint_model.dart';
import 'custom_list_tile.dart';

class _FeastWidget extends StatelessWidget {
  final ChurchDay d;
  final TextStyle? style;

  const _FeastWidget(this.d, {this.style});

  @override
  Widget build(BuildContext context) {
    if (d.type == FeastType.great) {
      return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(children: [
            SvgPicture.asset("assets/images/great.svg", height: 30),
            const SizedBox(width: 10),
            Expanded(
                child: Text(d.name.tr(),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.red)))
          ]));
    } else {
      var textStyle =
          style ?? Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500);

      if (d.type.name != "none") {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
            child: RichText(
                text: TextSpan(children: [
              WidgetSpan(
                  child: SvgPicture.asset("assets/images/${d.type.name.toLowerCase()}.svg",
                      height: 15)),
              TextSpan(text: d.name.tr(), style: textStyle)
            ])));
      } else {
        return Padding(
            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 0),
            child: Text(d.name.tr(), style: textStyle));
      }
    }
  }
}

class CardWithTitle extends StatelessWidget {
  final String title;
  final Widget content;

  const CardWithTitle({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) => Card(
      elevation: 10.0,
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: (title.isEmpty)
              ? content
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                  GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Row(children: [
                        Flexible(
                            fit: FlexFit.tight,
                            child: AutoSizeText(title.tr().toUpperCase(),
                                maxLines: 1,
                                minFontSize: 5,
                                style: Theme.of(context).textTheme.button)),
                      ])),
                  const Divider(color: Colors.black),
                  content
                ])));
}

class DayView extends StatefulWidget {
  final DateTime date, dateOld;

  DayView({Key? key, required this.date})
      : dateOld = date.subtract(const Duration(days: 13)),
        super(key: key);

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> with AfterInitMixin<DayView> {
  DateTime get date => widget.date;
  DateTime get dateOld => widget.dateOld;

  late Cal cal;
  late SaintModel saints;

  @override
  void initState() {
    super.initState();
    cal = Cal.fromDate(date);
  }

  @override
  void didInitState() async {
    saints = SaintModel(context.languageCode);
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
                        style: Theme.of(context).textTheme.titleLarge),
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

  Widget getDescription() {
    var list = [cal.getWeekDescription(date), cal.getToneDescription(date)];
    var weekDescr = list.whereType<String>().join('; ');
    var dayDescr = cal.getDayDescription(date);
    var greatFeasts = Cal.getGreatFeast(date);

    List<Widget> feastWidgets = [];

    if (greatFeasts.isNotEmpty) {
      feastWidgets = greatFeasts.map((d) => _FeastWidget(d)).toList();
    } else {
      feastWidgets = dayDescr.map((d) => _FeastWidget(d)).toList();
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: (weekDescr.isNotEmpty
                ? <Widget>[Text(weekDescr, style: Theme.of(context).textTheme.titleMedium)]
                : <Widget>[]) +
            feastWidgets);
  }

  Widget getFasting() {
    final fasting = ChurchFasting.forDate(date);

    return Row(children: [
      SvgPicture.asset("assets/images/${fasting.type.icon}", height: 30),
      const SizedBox(width: 10),
      Expanded(
          child: Text(fasting.description.tr(), style: Theme.of(context).textTheme.titleMedium))
    ]);
  }

  Widget getReading() {
    final reading = ChurchReading.forDate(date);
    List<Widget> content = [];

    for (final r in reading) {
      final currentReading = r.split("#");
      var title = currentReading[0];
      var subtitle = currentReading.length > 1 ? currentReading[1].trim().tr() : null;

      title = JSON.bibleTrans[context.languageCode]!.entries
          .fold(title, (String prev, e) => prev.replaceAll(e.key, e.value));

      content.add(CustomListTile(
          title: title,
          subtitle: subtitle,
          onTap: () => PericopeView(currentReading[0]).push(context)));
    }

    return CardWithTitle(
        title: "Gospel of the day",
        content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: content));
  }

  Widget getSaints() => FutureBuilder<List<Saint>>(
      future: saints.fetch(date),
      builder: (BuildContext context, AsyncSnapshot<List<Saint>> snapshot) {
        if (snapshot.hasData) {
          return CardWithTitle(
              title: "Memory of saints",
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List<ChurchDay>.from(snapshot.data!)
                      .map((s) => _FeastWidget(s, style: Theme.of(context).textTheme.titleMedium))
                      .toList()));

          // log(snapshot.data.toString());

        } else {
          return Container();
        }
      });

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 10);
    return SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          CardWithTitle(
              title: "",
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getDate(),
                    space,
                    getDescription(),
                    space,
                    getFasting(),
                  ])),
          space,
          getReading(),
          space,
          getSaints()
        ]));
  }
}
