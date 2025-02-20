import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class EditTransactionDialog extends StatefulWidget {
  final Transaction transaction;
  final Function(Transaction) onSave;

  const EditTransactionDialog({
    super.key,
    required this.transaction,
    required this.onSave,
  });

  @override
  State<EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<EditTransactionDialog> {
  late final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.transaction.title,
  );
  late final _amountController = TextEditingController(
    text: widget.transaction.amount.toStringAsFixed(2),
  );
  late final _descriptionController = TextEditingController(
    text: widget.transaction.description,
  );
  late String _selectedType = widget.transaction.type;
  late String _selectedCategory = widget.transaction.category;
  late DateTime _selectedDate = widget.transaction.date;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Transaction'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: const [
                  DropdownMenuItem(
                    value: 'income',
                    child: Text('Income'),
                  ),
                  DropdownMenuItem(
                    value: 'expense',
                    child: Text('Expense'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: Transaction.categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                ),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Date:'),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text(
                      DateFormat.yMd().format(_selectedDate),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final updatedTransaction = Transaction(
                id: widget.transaction.id,
                userId: widget.transaction.userId,
                title: _titleController.text,
                type: _selectedType,
                category: _selectedCategory,
                amount: double.parse(_amountController.text),
                date: _selectedDate,
                description: _descriptionController.text,
              );
              widget.onSave(updatedTransaction);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
