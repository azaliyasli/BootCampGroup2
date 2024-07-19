import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'dart:convert';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WalletProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lime,
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

class _StockListState extends State<StockList> with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> futureData;
  Timer? _timer;
  int _selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        futureData = fetchData();
      });
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

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

  Future<Map<String, dynamic>> fetchData() async {
    List<List<String>> stockData = await getWebsiteData();
    return {
      'stockData': stockData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock List'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Stocks'),
            Tab(text: 'Currency & Gold'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<Map<String, dynamic>>(
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
                    ],
                  ),
                );
              }
            },
          ),
          CurrencyAndGold(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Generate Advice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_outlined),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Color.fromARGB(255, 77, 226, 27),
        unselectedItemColor: Color.fromARGB(255, 127, 245, 17),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (_selectedIndex == 0) {
              // Do nothing, already on StockList page
            } else if (_selectedIndex == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewsPage()),
              ).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            } else if (_selectedIndex == 2) {
              futureData.then((data) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TextGenerationPage(stockData: data['stockData'])),
                ).then((_) {
                  setState(() {
                    _selectedIndex = 0;
                  });
                });
              });
            } else if (_selectedIndex == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WalletPage()),
              ).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            } else if (_selectedIndex == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              ).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            }
          });
        },
      ),
    );
  }
}

class CurrencyAndGold extends StatefulWidget {
  @override
  State<CurrencyAndGold> createState() => _CurrencyAndGoldState();
}

class _CurrencyAndGoldState extends State<CurrencyAndGold> {
  @override
  Widget build(BuildContext context) {
    final currencyGoldService = CurrencyGoldService();

    return FutureBuilder<List<CurrencyGold>>(
      future: currencyGoldService.fetchCurrencyGold(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
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

class News {
  final String uuid;
  final String title;
  final String description;
  final String keywords;
  final String snippet;
  final String url;
  final String urlToImage;
  final String language;
  final String publishedAt;
  final String source;
  // Consider creating another class for entities if you need to use them
  // final List<Entity> entities;

  News({
    required this.uuid,
    required this.title,
    required this.description,
    required this.keywords,
    required this.snippet,
    required this.url,
    required this.urlToImage,
    required this.language,
    required this.publishedAt,
    required this.source,
    // this.entities,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      uuid: json['uuid'],
      title: json['title'],
      description: json['description'],
      keywords: json['keywords'] ?? '',
      snippet: json['snippet'] ?? '',
      url: json['url'],
      urlToImage: json['image_url'] ?? '',
      language: json['language'] ?? 'en',
      publishedAt: json['published_at'],
      source: json['source'] ?? 'Unknown',
      // entities: (json['entities'] as List).map((e) => Entity.fromJson(e)).toList(),
    );
  }
}

// Fetch news from API
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

class NewsPage extends StatelessWidget {
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Latest News'),
      ),
      body: FutureBuilder<List<News>>(
        future: fetchNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].title),
                  subtitle: Text(snapshot.data![index].description),
                  leading: snapshot.data![index].urlToImage.isNotEmpty
                      ? Image.network(snapshot.data![index].urlToImage)
                      : null,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class TextGenerationPage extends StatefulWidget {
  final List<List<String>> stockData;

  TextGenerationPage({required this.stockData});

  @override
  _TextGenerationPageState createState() => _TextGenerationPageState();
}

class _TextGenerationPageState extends State<TextGenerationPage> {
  final TextEditingController _controller = TextEditingController();
  String _generatedText = '';
  bool _isLoading = false;
  late Future<List<CurrencyGold>> _currencyGoldFuture;

  @override
  void initState() {
    super.initState();
    _currencyGoldFuture = CurrencyGoldService().fetchCurrencyGold();
  }

  Future<void> _generateText() async {
    setState(() {
      _isLoading = true;
    });

    // Convert stock data to a readable format
    String stockDataString = widget.stockData.map((row) => row.join(', ')).join('\n');

    // Fetch currency and gold data
    List<CurrencyGold> currencyGoldData = await _currencyGoldFuture;
    String currencyGoldDataString = currencyGoldData.map((item) =>
      '${item.shortName}: ${item.latest} (${item.changeRate}%)').join('\n');

    // Create the prompt including both stock and currency/gold data
    String prompt = 'Based on the following stock data:\n$stockDataString\n\n'
        'And the following currency and gold data:\n$currencyGoldDataString\n\n'
        '${_controller.text}';

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
                decoration: InputDecoration(
                  hintText: 'Enter prompt',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _generateText,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Generate Text'),
              ),
              const SizedBox(height: 20),
              Text(
                _generatedText,
                style: Theme.of(context).textTheme.bodyText1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      Provider.of<WalletProvider>(context, listen: false).addRandomTransaction();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _navigateToTopUpPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TopUpPage()),
    );

    if (result != null) {
      double enteredAmount = result;
      Provider.of<WalletProvider>(context, listen: false).addTransaction(
        Transaction(type: TransactionType.paid, amount: enteredAmount),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Wallet'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<WalletProvider>(
            builder: (context, walletProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Balance',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${walletProvider.walletBalance.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToTopUpPage(context),
                        child: Text('Add money'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Transactions',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: walletProvider.transactions.length,
                      itemBuilder: (context, index) {
                        Transaction transaction = walletProvider.transactions[index];
                        return ListTile(
                          leading: Icon(
                            transaction.type == TransactionType.paid
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: transaction.type == TransactionType.paid
                                ? Colors.red
                                : Colors.green,
                          ),
                          title: Text(transaction.type == TransactionType.paid ? 'Paid' : 'Received'),
                          subtitle: Text('₹${transaction.amount.toStringAsFixed(2)}'),
                          trailing: Text('${DateFormat('dd/MM/yyyy').format(transaction.date)}'),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class TopUpPage extends StatefulWidget {
  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  TextEditingController _amountController = TextEditingController();

  void _setAmount(String amount) {
    setState(() {
      _amountController.text = amount;
    });
  }

  void _proceedToPayment(BuildContext context) {
    if (_amountController.text.isNotEmpty) {
      double enteredAmount = double.tryParse(_amountController.text) ?? 0.0;
      Navigator.pop(context, enteredAmount);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter an amount.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topup Wallet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Topup Wallet',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Enter Amount',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _setAmount('100'),
                  child: Text('₹100'),
                ),
                ElevatedButton(
                  onPressed: () => _setAmount('200'),
                  child: Text('₹200'),
                ),
                ElevatedButton(
                  onPressed: () => _setAmount('500'),
                  child: Text('₹500'),
                ),
                ElevatedButton(
                  onPressed: () => _setAmount('1000'),
                  child: Text('₹1000'),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: 'Apply promo code',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _proceedToPayment(context),
              child: Text('Proceed to payment'),
            ),
          ],
        ),
      ),
    );
  }
}

enum TransactionType { paid, received }

class Transaction {
  final TransactionType type;
  final double amount;
  final DateTime date;

  Transaction({
    required this.type,
    required this.amount,
  }) : date = DateTime.now();
}

class WalletProvider with ChangeNotifier {
  double _walletBalance = 50.0;
  List<Transaction> _transactions = [];

  double get walletBalance => _walletBalance;
  List<Transaction> get transactions => _transactions;

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    if (transaction.type == TransactionType.paid) {
      _walletBalance += transaction.amount;
    } else {
      _walletBalance -= transaction.amount;
    }
    notifyListeners();
  }

  void addRandomTransaction() {
    Random random = Random();
    double receivedAmount = random.nextDouble() * 1500;
    Transaction transaction = Transaction(
      type: TransactionType.received,
      amount: receivedAmount,
    );
    addTransaction(transaction);
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Text(
          'Profile Content Here',
          style: Theme.of(context).textTheme.headline4,
        ),
      ),
    );
  }
}
