import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/transaction.dart';
import '../models/transaction.dart';
import '../widgets/charts.dart';
import 'edit_transaction.dart';






class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              final provider = Provider.of<TransactionProvider>(context, listen: false);
              switch (value) {
                case 'date_asc':
                  provider.transactions = provider.getTransactionsSortedByDate(ascending: true);
                  break;
                case 'date_desc':
                  provider.transactions = provider.getTransactionsSortedByDate(ascending: false);
                  break;
                case 'category':
                  provider.transactions = provider.getTransactionsSortedByCategory();
                  break;
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'date_asc',
                child: Text('Sort by Date (Oldest First)'),
              ),
              const PopupMenuItem(
                value: 'date_desc',
                child: Text('Sort by Date (Newest First)'),
              ),
              const PopupMenuItem(
                value: 'category',
                child: Text('Sort by Category'),
              ),
            ],
          ),
        ],
      ),

      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          final transactions = provider.transactions;
          
          if (transactions.isEmpty) {
            return const Center(
              child: Text('No transactions found'),
            );
          }

          return Column(
            children: [
              // Monthly Summary Section
              SimpleSummaryCard(
                income: provider.getMonthlySummary(DateTime.now())['income'] ?? 0.0,
                expenses: provider.getMonthlySummary(DateTime.now())['expenses'] ?? 0.0,
                categories: provider.getMonthlySummary(DateTime.now())['categories'] ?? <String, double>{},
              ),

              
              // Recent Transactions Section
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Dismissible(
                      key: Key(transaction.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Transaction'),
                            content: const Text(
                                'Are you sure you want to delete this transaction?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        provider.deleteTransaction(transaction.id);
                      },
                      child: ListTile(
                        title: Text(transaction.title),
                        subtitle: Text(
                          '${transaction.type} - ${transaction.category}\n'
                          'Amount: \$${transaction.amount.toStringAsFixed(2)}\n'
                          'Date: ${DateFormat.yMd().format(transaction.date)}'
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => EditTransactionDialog(
                                transaction: transaction,
                                onSave: (updatedTransaction) {
                                  provider.updateTransaction(updatedTransaction);
                                },
                              ),
                            );
                          },

                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );

        },
      ),
    );
  }
}
