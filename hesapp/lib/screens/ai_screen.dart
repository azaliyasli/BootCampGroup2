import 'package:flutter/material.dart';
import 'package:hesapp/services/stock_data_fetcher.dart';
import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';



class AiScreen extends StatefulWidget {
  @override
  _AiScreenState createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  List<String> _dropdownItems = [];
  final List<String> _selectedItems = [];
  String? _selectedDropdownItem;
  bool _isLoading = true;
  bool _isDisabled = false;
  String _generatedText = '';
  bool _isLoadingAi = false;

  @override
  void initState() {
    super.initState();
    fetchStockData();
  }

  Future<void> fetchStockData() async {
    DataFetcher dataFetcher = DataFetcher();
    List<List<String>> stockData = await dataFetcher.getWebsiteData();
    setState(() {
      _dropdownItems = stockData.map((data) => data[0]).toList();
      _isLoading = false;
    });
  }

  Future<void> _generateText() async {
    setState(() {
      _isLoadingAi = true;
    });

    DataFetcher dataFetcher = DataFetcher();
    List<List<String>> stockData1 = await dataFetcher.getWebsiteData();

    // Convert stock data to a readable format
    String stockDataString = stockData1.map((row) => row.join(', ')).join('\n');

    // Create the prompt including both stock and currency/gold data
    String prompt = 'Based on the following stock data:\n$stockDataString\n\n'
        '${_selectedItems} Evaluate these selected stocks among themselves for a user who wants to invest. '
        'Write down the advantages and disadvantages of the stocks against each other. '
        'At the end of the message, state that this is not an investment recommendation '
        'and is shared for informational purposes only.';

    final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyAcosoCfjRV4dIb2rwhgdMppWOPuZcxXVk');
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    setState(() {
      _generatedText = response.text!;
      _isLoadingAi = false;
    });
  }

  void _addSelectedItem(String item) {
    setState(() {
      _selectedItems.add(item);
      _generatedText = ''; // Seçilen eleman eklendiğinde metni sıfırla
      if (_selectedItems.length >= 5) {
        _isDisabled = true;
      }
    });
  }

  void _removeSelectedItem(int index) {
    setState(() {
      _selectedItems.removeAt(index);
      _generatedText = ''; // Seçilen eleman silindiğinde metni sıfırla
      if (_selectedItems.length < 5) {
        _isDisabled = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Stock Comparison'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          DropdownButton<String>(
            hint: Text("Select a stock"),
            value: _selectedDropdownItem,
            onChanged: _isDisabled
                ? null
                : (newValue) {
              setState(() {
                if (newValue != null &&
                    !_selectedItems.contains(newValue)) {
                  _addSelectedItem(newValue);
                }
                _selectedDropdownItem =
                null; // Dropdown menüyü sıfırlamak için
              });
            },
            items: _dropdownItems.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedItems.length + 3,
              // +3 to accommodate the button, info text and generated text
              itemBuilder: (context, index) {
                if (index == _selectedItems.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      onPressed: _selectedItems.length >= 2
                          ? () {
                        print(_selectedItems); // Seçilen elemanları konsola yazdırır
                        _generateText();
                      }
                          : null,
                      child: Text('Compare Stocks'),
                    ),
                  );
                } else if (index == _selectedItems.length + 1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 25),
                    child: Text(
                      _selectedItems.length < 2
                          ? 'You must select at least two stocks for the button to be active.'
                          : '',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (index == _selectedItems.length + 2) {
                  return _isLoadingAi
                      ? Center(child: CircularProgressIndicator())
                      : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 25),
                    child: _generatedText.isNotEmpty
                        ? Expanded(
                      //height: 200, // Scroll edilebilir alanın yüksekliği
                      child: SingleChildScrollView(
                        child: Text(_generatedText),
                      ),
                    )
                        : Container(),
                  );
                } else {
                  return ListTile(
                    title: Text(_selectedItems[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        _removeSelectedItem(index);
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
