import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:after_init/after_init.dart';

import 'dart:developer';
import 'dart:math';

import 'church_day.dart';
import 'church_calendar.dart';
import 'church_fasting.dart';
import 'church_reading.dart';
import 'globals.dart';
import 'pericope.dart';
import 'saint_model.dart';
import 'icon_model.dart';
import 'custom_list_tile.dart';
import 'month_container.dart';
import 'troparion_model.dart';
import 'troparion_day.dart';
import 'troparion_feast.dart';
import 'feofan.dart';
import 'synaxarion.dart';

class _FeastWidget extends StatelessWidget {
  final ChurchDay d;
  final TextStyle? style;
  final bool translate;

  const _FeastWidget(this.d, {this.style, this.translate = true});

  @override
  Widget build(BuildContext context) {
    if (d.type == FeastType.great) {
      return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(children: [
            SvgPicture.asset("assets/images/great.svg", height: 30),
            const SizedBox(width: 10),
            Expanded(
                child: Text(translate ? d.name.tr() : d.name,
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
              TextSpan(text: translate ? d.name.tr() : d.name, style: textStyle)
            ])));
      } else {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 0),
            child: Text(translate ? d.name.tr() : d.name, style: textStyle));
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

  late List<SaintIcon> icons = [];
  late List<Troparion> troparia = [];

  late int pageSize;
  late PageController _controller;

  final space10 = const SizedBox(height: 10);
  final space5 = const SizedBox(height: 5);

  @override
  void initState() {
    super.initState();
    cal = Cal.fromDate(date);
    _controller = PageController(initialPage: 0);
  }

  @override
  void didInitState() async {
    saints = SaintModel(context.countryCode);

    const itemWidth = 100;
    const padding = 10;

    pageSize = (MediaQuery.of(context).size.width - 4 * padding) ~/ (itemWidth + 10);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        onTap: () {
          MonthContainer(date).show(context).then((newDate) {
            if (newDate != null) {
              DateChangedNotification(newDate).dispatch(context);
            }
          });
        });

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

  Widget getIcons() => FutureBuilder<List<SaintIcon>>(
      future: IconModel.fetch(date),
      builder: (BuildContext context, AsyncSnapshot<List<SaintIcon>> snapshot) {
        if (snapshot.hasData) {
          if (icons.isEmpty) {
            icons = List<SaintIcon>.from(snapshot.data!);
          }

          Widget _iconPage(int page) {
            final newItems =
                icons.sublist(page * pageSize, min((page + 1) * pageSize, icons.length));

            final pageNotFull = page > 0 && (page + 1) * pageSize > icons.length;

            return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment:
                    pageNotFull ? MainAxisAlignment.start : MainAxisAlignment.spaceAround,
                children: [
                  if (!pageNotFull) ...[const Spacer()],
                  ...newItems
                      .map<Widget>((s) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                          child: Image.asset(
                            'assets/icons/${s.id}.jpg',
                            height: 110.0,
                            fit: BoxFit.contain,
                          )))
                      .toList(),
                  if (!pageNotFull) ...[const Spacer()],
                ]);
          }

          return Container(
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              height: 120.0,
              child: PageView.builder(
                  controller: _controller,
                  itemCount: (icons.length - 1) ~/ pageSize + 1,
                  itemBuilder: (BuildContext context, int index) => _iconPage(index)));
        } else {
          return Container();
        }
      });

  Widget getReading() {
    final reading = ChurchReading.forDate(date);
    List<Widget> content = [];

    for (final r in reading) {
      final currentReading = r.split("#");
      var title = currentReading[0];
      var subtitle = currentReading.length > 1 ? currentReading[1].trim().tr() : null;

      title = JSON.bibleTrans[context.countryCode]!.entries
          .fold(title, (String prev, e) => prev.replaceAll(e.key, e.value));

      content.add(CustomListTile(
          title: title,
          subtitle: subtitle,
          onTap: () => PericopeView(currentReading[0]).push(context)));

      content.add(space5);
    }

    if (context.languageCode == "ru") {
      content.add(FeofanView(date));
      content.add(SynaxarionView(date));

      content.add(const SizedBox(height: 10));
      content.add(SaintTroparion(date));
      content.add(TroparionOfDay(date));
      content.add(TroparionOfFeast(date));
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
                      .map((s) => _FeastWidget(s,
                          style: Theme.of(context).textTheme.titleMedium, translate: false))
                      .toList()));

          // log(snapshot.data.toString());

        } else {
          return Container();
        }
      });

  @override
  Widget build(BuildContext context) {
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
                    space10,
                    getDescription(),
                    space10,
                    getFasting(),
                    space10,
                    getIcons()
                  ])),
          space10,
          getReading(),
          space10,
          getSaints()
        ]));
  }
}
