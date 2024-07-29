import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hesapp/models/transaction_model.dart';
import 'package:hesapp/screens/top_up_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      Provider.of<WalletProvider>(context, listen: false)
          .addRandomTransaction();
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${walletProvider.walletBalance.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToTopUpPage(context),
                        child: const Text('Add money'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Transactions',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: walletProvider.transactions.length,
                      itemBuilder: (context, index) {
                        Transaction transaction =
                        walletProvider.transactions[index];
                        return ListTile(
                          leading: Icon(
                            transaction.type == TransactionType.paid
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: transaction.type == TransactionType.paid
                                ? Colors.red
                                : Colors.green,
                          ),
                          title: Text(transaction.type == TransactionType.paid
                              ? 'Paid'
                              : 'Received'),
                          subtitle:
                          Text('₹${transaction.amount.toStringAsFixed(2)}'),
                          trailing: Text(
                              '${DateFormat('dd/MM/yyyy').format(transaction.date)}'),
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