import 'package:flutter/material.dart';
import 'package:hesapp/models/currency_gold_model.dart';
import 'package:hesapp/services/currency_gold_services.dart';

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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
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