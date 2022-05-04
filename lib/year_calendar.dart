import 'package:flutter/material.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:after_init/after_init.dart';
import 'package:easy_localization/easy_localization.dart';

import 'month_view.dart';

class YearCalendarView extends StatefulWidget {
  final DateTime date;
  const YearCalendarView(this.date);

  @override
  _YearCalendarViewState createState() => _YearCalendarViewState();
}

class _YearCalendarViewState extends State<YearCalendarView> with AfterInitMixin<YearCalendarView> {
  late String title;
  late int initialYear;

  late double cellWidth, containerWidth;

  @override
  void initState() {
    super.initState();

    initialYear = widget.date.year;
    title = "Календарь на 2022 г.";
  }

  @override
  void didInitState() {
    if (context.isTablet) {
      cellWidth = 70.0;
      containerWidth = 510.0;
    } else {
      cellWidth = 40.0;
      containerWidth = 300.0;
    }
  }

  Widget getMonthView(DateTime d) => FittedBox(
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(DateFormat("LLLL").format(d).capitalize(),
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 10),
        SizedBox(width: containerWidth, child: WeekdaysView(short: true)),
        SizedBox(
            width: containerWidth,
            height: cellWidth * 6,
            child:
                Align(alignment: Alignment.topCenter, child: MonthView(d, highlightToday: false)))
      ]));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            decoration:
                AppTheme.bg_decor_2() ?? BoxDecoration(color: Theme.of(context).canvasColor),
            child: SafeArea(
                child: CustomScrollView(physics: const ClampingScrollPhysics(), slivers: [
              SliverAppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                floating: false,
                pinned: false,
                toolbarHeight: 50.0,
                // actions: [],
                title: AutoSizeText(title,
                    maxLines: 1,
                    minFontSize: 5,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline6),
              ),
              SliverPadding(
                  padding: const EdgeInsets.all(5),
                  sliver: SliverGrid.count(
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 3,
                      childAspectRatio: 1.0,
                      children: List<int>.generate(12, (i) => i)
                          .map<Widget>((i) => getMonthView(DateTime(initialYear, i + 1, 1)))
                          .toList())),
            ]))));
  }
}
