import 'package:group_list_view/group_list_view.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';

import 'dart:async';

import 'book_model.dart';
import 'globals.dart';

class EbookModel extends BookModel {
  @override
  late String code;

  @override
  late BookContentType contentType;

  @override
  late String title;

  @override
  late String? author;

  @override
  late String lang;

  @override
  bool get hasChapters => false;

  @override
  late Future initFuture;

  late Database db;

  EbookModel(String filename) {
    initFuture = loadBook(filename);
  }

  Future loadBook(String filename) async {
    db = await DB.open(filename);

    code = (await loadString("code"))!;
    title = (await loadString("title"))!;
    author = (await loadString("author"));
    lang = (await loadString("lang")) ?? "en";

    contentType = BookContentType.values[Sqflite.firstIntValue(
        await db.query("data", columns: ["value"], where: "key='contentType'"))!];
  }

  Future<String?> loadString(String key) async =>
      SqfliteExt.firstStringValue(await db.query("data", columns: ["value"], where: "key='$key'"));

  @override
  Future<List<String>> getSections() async {
    List<Map<String, Object?>> result =
        await db.query("sections", columns: ["title"], orderBy: "id");

    return result.map<String>((e) => e["title"] as String).toList();
  }

  @override
  Future<String> getTitle(BookPosition pos) async =>
      SqfliteExt.firstStringValue(await db.query("content",
          columns: ["title"],
          where: "section=? AND item=?",
          whereArgs: [pos.index!.section, pos.index!.index]))!;

  @override
  Future getContent(BookPosition pos) async => SqfliteExt.firstStringValue(await db.query("content",
      columns: ["text"],
      where: "section=? AND item=?",
      whereArgs: [pos.index!.section, pos.index!.index]));

  @override
  Future<List<String>> getItems(int section) async {
    List<Map<String, Object?>> result = await db.query("content",
        columns: ["title"], where: "section=?", whereArgs: [section], orderBy: "item");

    return result.map<String>((e) => e["title"] as String).toList();
  }

  @override
  Future<String?> getComment(int commentId) async => SqfliteExt.firstStringValue(
      await db.query("comments", columns: ["text"], where: "id=?", whereArgs: [commentId]));

  @override
  Future<int> getNumChapters(IndexPath index) async =>
      Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(DISTINCT title) FROM content'))!;
}
