import 'package:sqflite/sqflite.dart';
import 'package:flutter_toolkit/flutter_toolkit.dart';
import 'package:supercharged/supercharged.dart';

class Troparion {
  String title = "";
  String content = "";
  String? glas;
  String? url;

  Troparion.fromMap(Map<String, Object?> data) {
    title = data["title"] as String;
    content = data["content"] as String;
    glas = data["glas"] as String;
  }
}

