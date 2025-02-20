import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/transaction.dart' show ExpenseTransaction;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  // Initialize with built-in user if not exists
  Future<void> initializeBuiltInUser() async {
    final db = await database;
    final builtInUser = User(
      id: 'builtin_user',
      email: 'test@example.com',
      password: 'password123',
      firstName: 'Test',
      lastName: 'User',
      createdOn: DateTime.now(),

    );

    final existingUser = await getUser('builtin_user');
    if (existingUser == null) {
      await insertUser(builtInUser);
    }
  }


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        created_on TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY(user_id) REFERENCES users(id)
      )
    ''');
  }

  // User operations
  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String id) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<List<User>> queryUsersByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // Transaction operations
  Future<void> insertTransaction(ExpenseTransaction transaction) async {
    try {
      final db = await database;
      await db.insert(
        'transactions', 
        transaction.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to insert transaction: ${e.toString()}');
    }
  }


  Future<List<ExpenseTransaction>> getTransactions(String userId,
      {String? category, DateTime? startDate, DateTime? endDate}) async {
    try {
      final db = await database;

    
    String where = 'user_id = ?';
    List<dynamic> whereArgs = [userId];
    
    if (category != null) {
      where += ' AND category = ?';
      whereArgs.add(category);
    }
    
    if (startDate != null) {
      where += ' AND date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      where += ' AND date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final maps = await db.query(
      'transactions',
      where: where,
      whereArgs: whereArgs,
    );

      return List.generate(maps.length, (i) {
        return ExpenseTransaction.fromMap(maps[i]);
      });
    } catch (e) {
      throw Exception('Failed to retrieve transactions: ${e.toString()}');
    }
  }



  Future<void> updateTransaction(ExpenseTransaction transaction) async {
    try {
      final db = await database;
      final rowsUpdated = await db.update(
        'transactions',
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      if (rowsUpdated == 0) {
        throw Exception('Transaction not found with id: ${transaction.id}');
      }
    } catch (e) {
      throw Exception('Failed to update transaction: ${e.toString()}');
    }
  }


  Future<void> deleteTransaction(String id) async {
    try {
      final db = await database;
      final rowsDeleted = await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (rowsDeleted == 0) {
        throw Exception('Transaction not found with id: $id');
      }
    } catch (e) {
      throw Exception('Failed to delete transaction: ${e.toString()}');
    }
  }


  Future<Map<String, dynamic>> getFinancialSummary(String userId) async {
    final db = await database;
    
    final incomeResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = ?',
      [userId, 'income']
    );
    
    final expenseResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND type = ?',
      [userId, 'expense']
    );
    
    final totalIncome = (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    final totalExpenses = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;
    
    return {
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'balance': totalIncome - totalExpenses
    };

  }

  Future<List<Map<String, dynamic>>> getMonthlyReport(String userId, DateTime month) async {
    final db = await database;
    
    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);
    
    final result = await db.rawQuery('''
      SELECT 
        category,
        type,
        SUM(amount) as total,
        COUNT(*) as count
      FROM transactions
      WHERE user_id = ? AND date BETWEEN ? AND ?
      GROUP BY category, type
      ORDER BY total DESC
    ''', [userId, startDate.toIso8601String(), endDate.toIso8601String()]);
    
    return result;
  }

}
