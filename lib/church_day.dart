import 'package:json_annotation/json_annotation.dart';
import 'globals.dart';

part 'church_day.g.dart';

enum FeastType {
  @JsonValue("none")
  none,
  @JsonValue("noSign")
  noSign,
  @JsonValue("sixVerse")
  sixVerse,
  @JsonValue("doxology")
  doxology,
  @JsonValue("polyeleos")
  polyeleos,
  @JsonValue("vigil")
  vigil,
  @JsonValue("great")
  great
}

extension FeastTypeExt on FeastType {
  String get name => [
        "none",
        "noSign",
        "sixVerse",
        "doxology",
        "polyeleos",
        "vigil",
        "great"
      ][index];
}

@JsonSerializable()
class ChurchDay {
  @JsonKey(name: 'feastName')
  final String name;

  @JsonKey(name: 'feastType')
  final FeastType type;

  @JsonKey(fromJson: _fromJson)
  final DateTime? date;

  @JsonKey(name: 'reading')
  final String? reading;

  @JsonKey(name: 'saint')
  final String? comment;

  factory ChurchDay.fromJson(Map<String, dynamic> json) =>
      _$ChurchDayFromJson(json);

  ChurchDay(this.name, this.type, this.date, this.reading, this.comment);

  @override
  String toString() {
    return "name: $name type ${type.name} date ${date ?? ""} reading $reading, comment ${comment ?? ""} \n";
  }
}

DateTime _fromJson(String date) => JSON.dateParser(date);