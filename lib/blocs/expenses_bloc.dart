import 'dart:async';

import 'package:expenses_pal/common/database_manager/database_manager.dart';
import 'package:expenses_pal/common/models/expenses.dart';
import 'package:expenses_pal/screens/home/dashboard/filter/filter.dart';
import 'package:rxdart/rxdart.dart';

class ExpensesBloc {
  final _expensesFetcher = BehaviorSubject<FilteredList<Expense>>();
  final manager = DatabaseManager.defaultManager;

  Observable<FilteredList<Expense>> get allExpenses => _expensesFetcher.stream;

  fetchAllExpenses() async {
    ExpenseTable table = ExpenseTable();
    List<Map> maps = await manager.fetchAllEntriesOf(Expense);
    FilteredList<Expense> expenses = FilteredList();

    maps.forEach((map) {
      Expense expense = table.entryFromMap(map);
      expenses.add(expense);
    });

    expenses.sort((e1, e2) => e2.date.compareTo(e1.date));

    _expensesFetcher.sink.add(expenses);
  }

  Future<bool> addExpense(Expense expense) async {
    return manager.insert([expense]).then((value) {
      fetchAllExpenses();
    });
  }

  Future<bool> removeExpense(Expense expense) async {
    return manager.remove([expense]).then((value) {
      fetchAllExpenses();
    });
  }

  dispose() {
    _expensesFetcher.close();
  }
}

final expensesBloc = ExpensesBloc();
