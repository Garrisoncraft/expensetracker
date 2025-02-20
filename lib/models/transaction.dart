class Transaction {
  static const List<String> categories = [
    'Salary'
    'Groceries',
    'Utilities',
    'Entertainment',
    'Transportation',
    'Housing',
    'Healthcare',
    'Education',
    'Shopping',
    'Other'
  ];

  final String id;
  final String userId;
  final String title;
  final String type; // 'income' or 'expense'
  final String category;
  final double amount;
  final DateTime date;
  final String description;
  final DateTime createdAt;




  static bool isValidType(String type) {
    return type == 'expense' || type == 'income';
  }

  static bool isValidCategory(String category) {
    return categories.contains(category);
  }

  Transaction({
    required this.id,
    required this.userId,
    required this.title,
    required String type,
    required String category,
    required this.amount,
    required this.date,
    required this.description,
    DateTime? createdAt,
  }) : type = isValidType(type) ? type : 'income',
       category = isValidCategory(category) ? category : 'Other',
       createdAt = createdAt ?? DateTime.now() {


    if (amount < 0) {
      throw ArgumentError('Amount cannot be negative');
    }
    if (date.isAfter(DateTime.now())) {
      throw ArgumentError('Date cannot be in the future');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'created_at': createdAt.toIso8601String(),


    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      type: map['type'],
      category: map['category'],
      amount: map['amount'].toDouble(),
      date: DateTime.parse(map['date']),
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),


    );
  }
}
