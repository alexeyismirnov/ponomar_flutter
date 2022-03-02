import 'package:flutter/material.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

class BookPageSingle extends StatefulWidget {
  final String title;
  final Widget content;

  const BookPageSingle(this.title, this.content);

  @override
  _BookPageSingleState createState() => _BookPageSingleState();
}

class _BookPageSingleState extends State<BookPageSingle> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: SafeArea(
                bottom: false,
                child: Scrollbar(
                    controller: _scrollController,
                    child: Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: AppTheme.bg_decor_2() ??
                            BoxDecoration(color: Theme.of(context).canvasColor),
                        child: SafeArea(
                            bottom: true,
                            child: CustomScrollView(
                                controller: _scrollController,
                                physics: const ClampingScrollPhysics(),
                                slivers: [
                                  SliverAppBar(
                                    elevation: 0.0,
                                    floating: true,
                                    toolbarHeight: 50.0,
                                    pinned: false,
                                    title: Text(widget.title,
                                        textAlign: TextAlign.left,
                                        style: Theme.of(context).textTheme.headline6),
                                  ),

                                  SliverToBoxAdapter(
                                      child: Padding(
                                          padding: const EdgeInsets.all(15), child: widget.content))
                                  //    Padding(padding: const EdgeInsets.all(15), child: getContent())
                                ])))))));
  }
}
