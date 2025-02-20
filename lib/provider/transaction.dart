import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;
  set transactions(List<Transaction> transactions) {
    _transactions = transactions;
    notifyListeners();
  }

  
  List<Transaction> getRecentTransactions({int days = 7}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _transactions.where((t) => t.createdAt.isAfter(cutoff)).toList();
  }

  List<Transaction> getTransactionsSortedByDate({bool ascending = true}) {
    final transactions = List<Transaction>.from(_transactions);
    transactions.sort((a, b) => ascending 
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    return transactions;
  }

  List<Transaction> getTransactionsSortedByCategory() {
    final transactions = List<Transaction>.from(_transactions);
    transactions.sort((a, b) => a.category.compareTo(b.category));
    return transactions;
  }



  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction); 
    notifyListeners();
  }


  void updateTransaction(Transaction updatedTransaction) {
    final index = _transactions.indexWhere(
      (t) => t.id == updatedTransaction.id,
    );
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((transaction) => transaction.id == id);
    notifyListeners();
  }

  Map<String, dynamic> getMonthlySummary(DateTime date) {
    final monthTransactions = _transactions.where((t) =>
        t.date.month == date.month && t.date.year == date.year).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending


    final income = monthTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (double sum, t) => sum + (t.amount ?? 0.0));

    final expenses = monthTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (double sum, t) => sum + (t.amount ?? 0.0));

    final categories = <String, double>{};
    for (final t in monthTransactions) {
      final amount = t.amount ?? 0.0;
      final category = t.category ?? 'Other';
      final value = t.type == 'income' ? amount : -amount;
      categories[category] = (categories[category] ?? 0) + value;
    }



    return {
      'income': income,
      'expenses': expenses,
      'balance': income - expenses,
      'categories': categories,
    };
  }
}
