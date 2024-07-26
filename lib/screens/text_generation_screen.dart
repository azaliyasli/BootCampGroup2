import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hesapp/models/currency_gold_model.dart';
import 'package:hesapp/services/currency_gold_services.dart';

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
    String stockDataString =
    widget.stockData.map((row) => row.join(', ')).join('\n');

    // Fetch currency and gold data
    List<CurrencyGold> currencyGoldData = await _currencyGoldFuture;
    String currencyGoldDataString = currencyGoldData
        .map(
            (item) => '${item.shortName}: ${item.latest} (${item.changeRate}%)')
        .join('\n');

    // Create the prompt including both stock and currency/gold data
    String prompt = 'Based on the following stock data:\n$stockDataString\n\n'
        'And the following currency and gold data:\n$currencyGoldDataString\n\n'
        '${_controller.text}';

    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyAcosoCfjRV4dIb2rwhgdMppWOPuZcxXVk');
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
                  hintText: 'Enter prompt',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _generateText,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Generate Text'),
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