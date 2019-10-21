import 'dart:collection';

import 'package:expenses_pal/common/helpers.dart';
import 'package:expenses_pal/common/models/expenses.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

abstract class ExpenseFilter {
  bool filter(Expense expense);
}

enum DateFilterType { today, yesterday, week, month, year, custom }

const Map<DateFilterType, String> DateFilterTypeName = {
  DateFilterType.today: "Today",
  DateFilterType.yesterday: "Yesterday",
  DateFilterType.week: "Last week",
  DateFilterType.month: "Last month",
  DateFilterType.year: "Last year",
  DateFilterType.custom: "Custom",
};

class DateFilter extends ExpenseFilter {
  final DateTime dateTime;
  final DateFilterType type;

  DateFilter({@required this.type, this.dateTime});

  @override
  bool filter(Expense expense) {
    var today = DateTime.now();
    switch (type) {
      case DateFilterType.today:
        return DateHelper.isSameDay(expense.date, today);
        break;
      case DateFilterType.yesterday:
        return DateHelper.isSameDay(
            expense.date, today.add(Duration(days: -1)));
        break;
      case DateFilterType.week:
        return DateHelper.isSameDay(expense.date, today) ||
            (expense.date.isBefore(today) &&
                expense.date.isAfter(today.add(Duration(days: -7))));
        break;
      case DateFilterType.month:
        return DateHelper.isSameDay(expense.date, today) ||
            (expense.date.isBefore(today) &&
                expense.date.isAfter(today.add(Duration(days: -31))));
        break;
      case DateFilterType.year:
        return DateHelper.isSameDay(expense.date, today) ||
            (expense.date.isBefore(today) &&
                expense.date.isAfter(today.add(Duration(days: -351))));
        break;
      case DateFilterType.custom:
        return expense.date.isBefore(dateTime);
        break;
    }

    return true;
  }
}

class KeywordFilter extends ExpenseFilter {
  final String keyword;

  KeywordFilter({@required this.keyword});

  @override
  bool filter(Expense expense) {
    bool contains = false;
    if (expense.title != null) {
      contains = contains || expense.title.contains(keyword);
    }

    if (expense.description != null) {
      contains = contains || expense.description.contains(keyword);
    }

    if (expense.currency != null) {
      contains = contains || expense.currency.contains(keyword);
    }

    if (expense.amount != null) {
      contains = contains || expense.amount.toString().contains(keyword);
    }

    expense.tags.forEach((tag) {
      contains = contains || tag.name.contains(keyword);
    });

    return contains;
  }
}

class FilteredList<E> extends ListBase<E> {
  List innerList = List();

  int get length => innerList.length;

  set length(int length) {
    innerList.length = length;
  }

  void operator []=(int index, E value) {
    innerList[index] = value;
  }

  E operator [](int index) => innerList[index];

  void add(E value) => innerList.add(value);

  void addAll(Iterable<E> all) => innerList.addAll(all);

  FilteredList<Expense> applyFilters(List<ExpenseFilter> f) {
    var newList = innerList.where((item) {
      return f.length > 0
          ? f.fold(true, (value, element) => value && element.filter(item))
          : true;
    }).toList();

    FilteredList<Expense> filteredExpenses = FilteredList();
    newList.forEach((item) => filteredExpenses.add(item));
    return filteredExpenses;
  }
}

class FilterBloc {
  final _filtersFetcher = BehaviorSubject<List<ExpenseFilter>>();
  Observable<List<ExpenseFilter>> get filters => _filtersFetcher.stream;

  fetchInitialFilters() async {
    setFilters([]);
  }

  dispose() {
    _filtersFetcher.close();
  }

  void setFilters(List<ExpenseFilter> filters) async {
    _filtersFetcher.sink.add(filters);
  }
}

final filtersBloc = FilterBloc();
