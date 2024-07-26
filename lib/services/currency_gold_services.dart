import 'dart:convert';

import 'package:hesapp/models/currency_gold_model.dart';
import 'package:http/http.dart' as http;


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