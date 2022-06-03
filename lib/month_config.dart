import 'package:flutter/material.dart';
import 'package:after_init/after_init.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';

class MonthViewConfig extends StatefulWidget {
  final bool shortLabels;
  final bool sharing;
  final String lang;
  final bool highlightToday;
  final Widget child;

  late MonthViewConfigState myState;

  MonthViewConfig(
      {required this.lang,
      required this.child,
      this.shortLabels = false,
      this.sharing = false,
      this.highlightToday = true});

  @override
  MonthViewConfigState createState() {
    myState = MonthViewConfigState();
    return myState;
  }

  static MonthViewConfigState? of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<MonthViewConfig>()?.myState;
}

class MonthViewConfigState extends State<MonthViewConfig> with AfterInitMixin<MonthViewConfig> {
  late double cellWidth, cellHeight, containerWidth;
  bool get shortLabels => widget.shortLabels;
  String get lang => widget.lang;
  bool get highlightToday => widget.highlightToday;

  late bool sharing;

  @override
  void initState() {
    super.initState();
    sharing = widget.sharing;
  }

  @override
  void didInitState() {
    final isTablet = widget.sharing ? false : context.isTablet;

    if (isTablet) {
      cellWidth = 70.0;
      containerWidth = 510.0;
    } else {
      cellWidth = 40.0;
      containerWidth = 300.0;
    }

    cellHeight = cellWidth;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
