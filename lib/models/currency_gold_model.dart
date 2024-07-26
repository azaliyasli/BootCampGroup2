class CurrencyGold {
  final String code;
  final String shortName;
  final String fullName;
  final double buying;
  final double selling;
  final double latest;
  final double changeRate;
  final double dayMin;
  final double dayMax;
  final String lastUpdate;

  CurrencyGold({
    required this.code,
    required this.shortName,
    required this.fullName,
    required this.buying,
    required this.selling,
    required this.latest,
    required this.changeRate,
    required this.dayMin,
    required this.dayMax,
    required this.lastUpdate,
  });

  factory CurrencyGold.fromJson(Map<String, dynamic> json) {
    return CurrencyGold(
      code: json['code'],
      shortName: json['ShortName'],
      fullName: json['FullName'],
      buying: json['buying'].toDouble(),
      selling: json['selling'].toDouble(),
      latest: json['latest'].toDouble(),
      changeRate: json['changeRate'].toDouble(),
      dayMin: json['dayMin'].toDouble(),
      dayMax: json['dayMax'].toDouble(),
      lastUpdate: json['lastupdate'],
    );
  }
}