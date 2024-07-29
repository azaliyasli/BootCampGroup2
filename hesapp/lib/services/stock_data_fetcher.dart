
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class DataFetcher{
  Future<List<List<String>>> getWebsiteData() async {
    final url = Uri.parse(
        'https://www.getmidas.com/canli-borsa/xu100-bist-100-hisseleri');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      List<List<String>> stockData = [];

      final rows = document.querySelectorAll(
          'body > div.container-fluid.stocks-page.stock-based-page > div > div > div > div.row.my-3.m-0.stock-table-container > table > tbody > tr');

      for (var row in rows) {
        final cells = row.querySelectorAll('td');
        List<String> rowData = cells.map((cell) => cell.text.trim()).toList();
        stockData.add(rowData);
      }

      return stockData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> fetchData() async {
    List<List<String>> stockData = await getWebsiteData();
    return {
      'stockData': stockData,
    };
  }
}