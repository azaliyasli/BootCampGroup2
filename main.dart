import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const StockList(),
    );
  }
}

class StockList extends StatefulWidget {
  const StockList({super.key});

  @override
  _StockListState createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  late Future<Map<String, dynamic>> futureData;
  Timer? _timer;

  Future<List<List<String>>> getWebsiteData() async {
    final url = Uri.parse('https://www.getmidas.com/canli-borsa/xu100-bist-100-hisseleri');
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

  Future<List<List<String>>> getCurrencyAndGoldData() async {
    final url = Uri.parse('https://www.qnbfinansbank.enpara.com/hesaplar/doviz-ve-altin-kurlari');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      List<List<String>> currencyData = [];

      final rows = document.querySelectorAll('.table tbody tr');

      for (var row in rows) {
        final cells = row.querySelectorAll('td');
        List<String> rowData = cells.map((cell) => cell.text.trim()).toList();
        currencyData.add(rowData);
      }

      return currencyData;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> fetchData() async {
    List<List<String>> stockData = await getWebsiteData();
    List<List<String>> currencyData = await getCurrencyAndGoldData();
    return {
      'stockData': stockData,
      'currencyData': currencyData,
    };
  }

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        futureData = fetchData();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock List'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data found'));
          } else {
            var stockData = snapshot.data!['stockData'] as List<List<String>>;
            var stockColumns = [
              'Hisse', 'Son', 'Alış', 'Satış', 'Fark', 'En Düşük', 'En Yüksek', 'AOF', 'Hacim TL', 'Hacim Lot'
            ];
            var currencyData = snapshot.data!['currencyData'] as List<List<String>>;
            var currencyColumns = ['Döviz/Altın', 'Alış', 'Satış'];

            return SingleChildScrollView(
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: stockColumns
                            .map((column) => DataColumn(
                          label: Text(column),
                        ))
                            .toList(),
                        rows: stockData
                            .map((row) => DataRow(
                          cells: row
                              .map((cell) => DataCell(
                            Text(cell),
                          ))
                              .toList(),
                        ))
                            .toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Currency and Gold Data', style: Theme.of(context).textTheme.headline6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columns: currencyColumns
                            .map((column) => DataColumn(
                          label: Text(column),
                        ))
                            .toList(),
                        rows: currencyData
                            .map((row) => DataRow(
                          cells: row
                              .map((cell) => DataCell(
                            Text(cell),
                          ))
                              .toList(),
                        ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            onPressed: () {
              futureData.then((data) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TextGenerationPage(stockData: data['stockData'], currencyData: data['currencyData'])),
                );
              });
            },
            child: Icon(Icons.message_outlined),
          );
        },
      ),
    );
  }
}

class TextGenerationPage extends StatefulWidget {
  final List<List<String>> stockData;
  final List<List<String>> currencyData;

  TextGenerationPage({required this.stockData, required this.currencyData});

  @override
  _TextGenerationPageState createState() => _TextGenerationPageState();
}

class _TextGenerationPageState extends State<TextGenerationPage> {
  final TextEditingController _controller = TextEditingController();
  String _generatedText = '';
  bool _isLoading = false;

  Future<void> _generateText() async {
    setState(() {
      _isLoading = true;
    });

    // Convert data to a readable format
    String stockDataString = widget.stockData.map((row) => row.join(', ')).join('\n');
    String currencyDataString = widget.currencyData.map((row) => row.join(', ')).join('\n');
    String prompt = 'Based on the following stock data:\n$stockDataString\n\nAnd the following currency and gold data:\n$currencyDataString\n\n${_controller.text}';

    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: 'AIzaSyAcosoCfjRV4dIb2rwhgdMppWOPuZcxXVk');
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    setState(() {
      _generatedText = response.text!;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Text Generation Page'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Enter a prompt for financial advice',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _generateText,
                child: const Text('Generate Advice'),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator(),
              if (_generatedText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _generatedText,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generateText,
        tooltip: 'Generate',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}