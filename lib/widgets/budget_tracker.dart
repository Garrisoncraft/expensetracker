import 'package:flutter/material.dart';

class BudgetTracker extends StatelessWidget {
  final double income;
  final double expenses;
  final double budget;

  const BudgetTracker({
    super.key,
    required double? income,
    required double? expenses,
    required double? budget,
  }) : income = income ?? 0.0,
       expenses = expenses ?? 0.0,
       budget = budget ?? 0.0;


  @override
  Widget build(BuildContext context) {
    final netIncome = income - expenses;
    final safeBudget = budget > 0 ? budget : 1.0;
    final remainingBudget = netIncome;
    final budgetUsage = expenses / income.clamp(1.0, double.infinity);



    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budget Tracker',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Net: \$${netIncome.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: netIncome >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: budgetUsage,
              backgroundColor: Colors.grey[200],
              color: budgetUsage > 0.8 ? Colors.red : Colors.green,
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Income: \$${income.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Expenses: \$${expenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Remaining: \$${remainingBudget.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: remainingBudget >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
