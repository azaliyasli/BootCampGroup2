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