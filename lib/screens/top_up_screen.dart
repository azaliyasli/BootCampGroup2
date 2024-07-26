import 'package:flutter/material.dart';

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
        const SnackBar(
          content: Text('Please enter an amount.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topup Wallet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Topup Wallet',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Enter Amount',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _setAmount('100'),
                  child: const Text('₹100'),
                ),
                ElevatedButton(
                  onPressed: () => _setAmount('200'),
                  child: const Text('₹200'),
                ),
                ElevatedButton(
                  onPressed: () => _setAmount('500'),
                  child: const Text('₹500'),
                ),
                ElevatedButton(
                  onPressed: () => _setAmount('1000'),
                  child: const Text('₹1000'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Apply promo code',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _proceedToPayment(context),
              child: const Text('Proceed to payment'),
            ),
          ],
        ),
      ),
    );
  }
}