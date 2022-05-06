import 'package:flutter/material.dart';

import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:after_init/after_init.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import 'month_view.dart';
import 'globals.dart';
import 'church_fasting.dart';

import 'dart:io';
import 'dart:core';
import 'dart:ui' as ui;
import 'dart:typed_data';

class YearCalendarView extends StatefulWidget {
  final DateTime date;
  const YearCalendarView(this.date);

  @override
  _YearCalendarViewState createState() => _YearCalendarViewState();
}

class _YearCalendarViewState extends State<YearCalendarView> with AfterInitMixin<YearCalendarView> {
  static const initialPage = 100000;
  late int initialYear;

  late String title;
  late double cellWidth, containerWidth;
  late PageController _controller;

  Map<int, GlobalKey> keys = {};
  late int currentPage;

  @override
  void initState() {
    super.initState();

    initialYear = widget.date.year;

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
    currentPage = index;
    setState(() {
      title = "year_calendar".tr().format([index - initialPage + initialYear]);
    });
  }

  Widget getAppbar() => SliverAppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        floating: false,
        pinned: false,
        toolbarHeight: 50.0,
        actions: [
          IconButton(
              icon: const Icon(Icons.share_outlined, size: 30.0),
              onPressed: () async {
                var path = p.join(GlobalPath.documents, 'screenshot.png');
                print(path);

                RenderRepaintBoundary boundary =
                    keys[currentPage]!.currentContext!.findRenderObject() as RenderRepaintBoundary;
                ui.Image image = await boundary.toImage(pixelRatio: 3.0);
                ByteData byteData = (await image.toByteData(format: ui.ImageByteFormat.png))!;
                Uint8List pngBytes = byteData.buffer.asUint8List();

                final file = File(path);
                await file.writeAsBytes(pngBytes, flush: true);

                await Share.shareFiles([path]);
              }),
        ],
        title: AutoSizeText(title,
            maxLines: 1,
            minFontSize: 5,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headline6),
      );

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
                child: NestedScrollView(
                    headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) =>
                        [getAppbar()],
                    body: PageView.builder(
                        controller: _controller,
                        onPageChanged: (page) => updateTitle(page),
                        itemBuilder: (BuildContext context, int index) {
                          if (!keys.containsKey(index)) {
                            keys[index] = GlobalKey();
                          }

                          return SingleChildScrollView(
                              child: RepaintBoundary(
                                  key: keys[index],
                                  child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                                      child: Column(mainAxisSize: MainAxisSize.max, children: [
                                        GridView.count(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            crossAxisSpacing: 10,
                                            mainAxisSpacing: 10,
                                            crossAxisCount: 3,
                                            childAspectRatio: 1.0,
                                            children: List<int>.generate(12, (i) => i)
                                                .map<Widget>((i) => getMonthView(DateTime(
                                                    index - initialPage + initialYear, i + 1, 1)))
                                                .toList()),
                                        const SizedBox(height: 20),
                                        GridView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 10,
                                              mainAxisSpacing: 10,
                                              mainAxisExtent: 50, // here set custom Height You Want
                                            ),
                                            itemCount: FastingModel.types.length,
                                            itemBuilder: (BuildContext context, int i) {
                                              final t = FastingModel.types[i];

                                              return Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                        width: 20, height: 20, color: t.color),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                        child: AutoSizeText(t.description.tr(),
                                                            maxLines: 2,
                                                            minFontSize: 5,
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .subtitle1))
                                                  ]);
                                            })
                                      ]))));
                        })))));
  }
}
