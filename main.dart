import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:provider/provider.dart';

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
  int _selectedIndex = 0;

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        // Do nothing, already on StockList page
      } else if (_selectedIndex == 1) {
        futureData.then((data) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TextGenerationPage(stockData: data['stockData'], currencyData: data['currencyData'])),
          ).then((_) {
            setState(() {
              _selectedIndex = 0;
            });
          });
        });
      } else if (_selectedIndex == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WalletPage()),
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
      }
    });
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Generate Advice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_outlined),
            label: 'Wallet',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 64, 255, 0),
        onTap: _onItemTapped,
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
