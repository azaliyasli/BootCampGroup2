import 'dart:async';
import 'package:hesapp/services/stock_data_fetcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:flutter/material.dart';

class StockMarketScreen extends StatefulWidget {
  const StockMarketScreen({super.key});

  @override
  _StockMarketScreenState createState() => _StockMarketScreenState();
}

class _StockMarketScreenState extends State<StockMarketScreen>
    with SingleTickerProviderStateMixin {
  late Future<Map<String, dynamic>> futureData;
  Timer? _timer;
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(text: 'Stocks'),
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
        ],
      ),
    );
  }
}
