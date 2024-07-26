import 'dart:async';
import 'package:hesapp/screens/ai_screen.dart';
import 'package:hesapp/screens/currency_gold_screen.dart';
import 'package:hesapp/screens/news_screen.dart';
import 'package:hesapp/screens/profile_screen.dart';
import 'package:hesapp/screens/text_generation_screen.dart';
import 'package:hesapp/screens/wallet_screen.dart';
import 'package:hesapp/services/google_auth.dart';
import 'package:hesapp/screens/user_login_screen.dart';
import 'package:hesapp/services/stock_data_fetcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';

class StockList extends StatefulWidget {
  const StockList({super.key});

  @override
  _StockListState createState() => _StockListState();
}

class _StockListState extends State<StockList>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> futureData;
  Timer? _timer;
  int _selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    futureData = DataFetcher().fetchData();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      setState(() {
        futureData = DataFetcher().fetchData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock List'),
        actions: [
          IconButton(
              onPressed: () async {
                FirebaseServices().googleSignOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => UserLoginScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.power_settings_new)),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
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
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data found'));
              } else {
                var stockData =
                    snapshot.data!['stockData'] as List<List<String>>;
                var stockColumns = [
                  'Hisse',
                  'Son',
                  'Alış',
                  'Satış',
                  'Fark',
                  'En Düşük',
                  'En Yüksek',
                  'AOF',
                  'Hacim TL',
                  'Hacim Lot'
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
        selectedItemColor: const Color.fromARGB(255, 77, 226, 27),
        unselectedItemColor: const Color.fromARGB(255, 127, 245, 17),
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
                  MaterialPageRoute(
                      builder: (context) =>
                          AiScreen()),
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
























