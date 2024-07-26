// Fetch news from API
import 'dart:convert';

import 'package:hesapp/models/news_model.dart';
import 'package:http/http.dart' as http;

Future<List<News>> fetchNews() async {
  final String apiKey = 'NnipeUp9Uo3myinXPuM3zIf5uzZ4MzYzylPF3QPY';
  final String url =
      'https://api.marketaux.com/v1/news/all?countries=us&filter_entities=true&limit=10&published_after=2024-07-18T09:30&api_token=$apiKey';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body)['data'];
    return jsonResponse.map((news) => News.fromJson(news)).toList();
  } else {
    throw Exception('Failed to load news');
  }
}