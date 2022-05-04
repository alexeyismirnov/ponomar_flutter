import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:after_init/after_init.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'month_view.dart';
import 'church_fasting.dart';

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
  late double cellWidth, containerWidth;
  bool showInfo = false;

  @override
  void initState() {
    super.initState();

    _controller = PageController(initialPage: initialPage);
    updateTitle();
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
        insetPadding: const EdgeInsets.all(0.0),
        content: Container(
            width: containerWidth,
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const SizedBox(width: 40),
                        Text(showInfo ? "info".tr() : title,
                            style: Theme.of(context).textTheme.titleLarge),
                        showInfo
                            ? IconButton(
                                onPressed: () => setState(() => showInfo = false),
                                iconSize: 30.0,
                                icon: const Icon(Icons.close_sharp))
                            : IconButton(
                                onPressed: () => setState(() => showInfo = true),
                                iconSize: 30.0,
                                icon: const Icon(Icons.help_outline)),
                      ]),
                  if (!showInfo) ...[WeekdaysView()],
                  spacer,
                  SizedBox(
                      width: containerWidth,
                      height: cellWidth * 6,
                      child: showInfo
                          ? SingleChildScrollView(
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: FastingModel.types
                                          .map<Widget>((t) => Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 0, vertical: 3),
                                              child: Row(children: [
                                                Container(width: 30, height: 30, color: t.color),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                    child: Text(t.description.tr(),
                                                        style:
                                                            Theme.of(context).textTheme.titleLarge))
                                              ])))
                                          .toList())))
                          : PageView.builder(
                              controller: _controller,
                              onPageChanged: (page) => updateTitle(page),
                              itemBuilder: (BuildContext context, int index) {
                                final currentDate = Jiffy(widget.initialDate)
                                    .add(months: index - initialPage)
                                    .dateTime;
                                return Align(
                                    alignment: Alignment.topCenter, child: MonthView(currentDate));
                              })),
                  if (showInfo) ...[const SizedBox(height: 20)]
                ])));
  }
}
