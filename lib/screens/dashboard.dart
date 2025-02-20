import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/transaction.dart';
import '../widgets/charts.dart';
import 'add_transaction.dart';
import '../widgets/budget_tracker.dart';
import 'transaction.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final summary = transactionProvider.getMonthlySummary(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _generateMonthlyReport(context, summary);
                    },
                    child: const Text('Monthly Report'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement export functionality
                    },
                    child: const Text('Export Data'),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Monthly Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem('Income', summary['income']),
                            _buildSummaryItem('Expenses', summary['expenses']),
                            _buildSummaryItem(
                              'Balance',
                              (summary['income'] as double) -
                                  (summary['expenses'] as double),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SimpleSummaryCard(
                  income: summary['income'] ?? 0.0,
                  expenses: summary['expenses'] ?? 0.0,
                  categories: summary['categories'] ?? <String, double>{},
                ),

              ],
            ),
            const SizedBox(height: 16),
            BudgetTracker(
              income: summary['income'],
              expenses: summary['expenses'],
              budget: summary['budget'],
            ),

            const SizedBox(height: 16),
            Column(
              children: [
                const Text(
                  'Category Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                SizedBox(
                  height: 200,
                  child: ListView(
                    children: _buildCategoryList(summary['categories']),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),

    );
  }

  Widget _buildSummaryItem(String label, dynamic value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategoryList(Map<String, double> categories) {
    return categories.entries.map((entry) {
      return Card(
        child: ListTile(
          title: Text(entry.key),
          trailing: Text('\$${entry.value.toStringAsFixed(2)}'),
        ),
      );
    }).toList();
  }

  void _generateMonthlyReport(BuildContext context, Map<String, dynamic> summary) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    final report = '''
Monthly Financial Report
=======================

Income: ${formatter.format(summary['income'])}
Expenses: ${formatter.format(summary['expenses'])}
Balance: ${formatter.format(summary['balance'])}

Category Breakdown:
${_formatCategoryBreakdown(summary['categories'])}
''';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monthly Report'),
        content: SingleChildScrollView(
          child: Text(report),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatCategoryBreakdown(Map<String, double> categories) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return categories.entries
        .map((e) => '${e.key}: ${formatter.format(e.value)}')
        .join('\n');
  }
}
