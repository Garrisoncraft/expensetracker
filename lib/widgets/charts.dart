import 'package:flutter/material.dart';

class SimpleSummaryCard extends StatelessWidget {
  final double income;
  final double expenses;
  final Map<String, double> categories;

  const SimpleSummaryCard({
    super.key,
    required this.income,
    required this.expenses,
    required this.categories,
  });
  

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryRow('Income', income),
            _buildSummaryRow('Expenses', expenses),
            const SizedBox(height: 16),
            ..._buildCategoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('\$${value.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryList() {
    if (categories.isEmpty) {
      return [const Text('No categories')];
    }

    return categories.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Text(
              '${entry.key}: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('\$${entry.value.toStringAsFixed(2)}'),
          ],
        ),
      );
    }).toList();
  }
}
