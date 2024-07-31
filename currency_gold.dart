import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyAndGold extends StatefulWidget {
  const CurrencyAndGold({super.key});

  @override
  State<CurrencyAndGold> createState() => _CurrencyAndGoldState();
}

class _CurrencyAndGoldState extends State<CurrencyAndGold> {
  @override
  Widget build(BuildContext context) {
    final currencyGoldService = CurrencyGoldService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Currency and Gold Prices'),
      ),
      body: FutureBuilder<List<CurrencyGold>>(
        future: currencyGoldService.fetchCurrencyGold(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                CurrencyGold item = snapshot.data![index];
                return ListTile(
                  title: Text(item.shortName),
                  subtitle: Text('Latest: ${item.latest}'),
                );
              },
            );
          }
        },
      ),
    );
  }
}

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

class CurrencyGoldService {
  Future<List<CurrencyGold>> fetchCurrencyGold() async {
    final response = await http.get(
      Uri.parse(
          'https://currency-and-gold-prices-api-in-turkish-lira.p.rapidapi.com/economy/currency/exchange-rate?code=USD%2Cgram-altin%2CEUR'),
      headers: {
        'x-rapidapi-host':
            'currency-and-gold-prices-api-in-turkish-lira.p.rapidapi.com',
        'x-rapidapi-key': '9ffd5196d9mshb9e55f46cb6c496p16171fjsn37705fb0c4b1',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((item) => CurrencyGold.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load currency and gold data');
    }
  }
}
