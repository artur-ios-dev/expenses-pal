import 'package:expenses_pal/blocs/expenses_bloc.dart';
import 'package:expenses_pal/common/helpers.dart';
import 'package:expenses_pal/common/models/expenses.dart';
import 'package:expenses_pal/common/ui/swipeable_tabbar.dart';
import 'package:expenses_pal/screens/home/dashboard/filter/filter.dart';
import 'package:expenses_pal/screens/home/stats/line_chart.dart';
import 'package:expenses_pal/screens/home/stats/time_series_expense.dart';
import 'package:flutter/material.dart';
import 'package:expenses_pal/common/ui/pal_title_view.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:math';

class StatsPage extends StatelessWidget {
  List<TimeSeriesExpense> _seriesFor(
      DateTime date, String currency, FilteredList<Expense> expenses) {
    List<TimeSeriesExpense> data = [];

    var currentAmount = 0.0;
    for (var i = 1; i <= date.day; i++) {
      var currentDate = DateTime.utc(date.year, date.month, i);
      var expesnesForDay = expenses
          .where((expense) =>
              DateHelper.isSameDay(expense.date, currentDate) &&
              expense.currency == currency)
          .toList();

      double amount = 0;
      if (expesnesForDay.length > 0) {
        amount = expesnesForDay
            .map((expense) => expense.amount)
            .reduce((value, element) => value + element);
      }

      currentAmount += amount;
      if (data.length >= 2) {
        var last = data[data.length - 1];
        var secondLast = data[data.length - 2];

        if (last.amount == secondLast.amount &&
            secondLast.amount == currentAmount) {
          data.removeLast();
        }
      }
      data.add(TimeSeriesExpense(currentDate, currentAmount));
    }

    return data.length > 1 ? data : [];
  }

  List<TimeSeriesExpense> _seriesForAllTime(
      String currency, FilteredList<Expense> expenses) {
    List<TimeSeriesExpense> data = [];
    DateTime t = DateTime.now();

    var currentAmount = 0.0;
    for (var i = 1; i <= 31; i++) {
      var expesnesForDay = expenses
          .where((expense) =>
              expense.date.day == i && expense.currency == currency)
          .toList();

      double amount = 0.0;
      if (expesnesForDay.length > 0) {
        amount = expesnesForDay
            .map((expense) => expense.amount)
            .reduce((value, element) => value + element);
      }

      currentAmount += amount;
      if (data.length >= 2) {
        var last = data[data.length - 1];
        var secondLast = data[data.length - 2];

        if (last.amount == secondLast.amount &&
            secondLast.amount == currentAmount) {
          data.removeLast();
        }
      }
      // TODO: date might be incorrect in some cases?
      data.add(TimeSeriesExpense(DateTime.utc(t.year, 1, i), currentAmount));
    }

    return data.length > 1 ? data : [];
  }

  List<charts.Series<TimeSeriesExpense, DateTime>> _createData(
      FilteredList<Expense> expenses, String currency, DateTime date) {
    List<TimeSeriesExpense> data = _seriesFor(date, currency, expenses);

    DateTime lastDay = date.month < 12
        ? DateTime.utc(date.year, date.month + 1, 0)
        : DateTime.utc(date.year + 1, 1, 0);

    var series = [
      charts.Series<TimeSeriesExpense, DateTime>(
        id: 'Expenses',
        domainFn: (TimeSeriesExpense expense, _) => expense.date,
        measureFn: (TimeSeriesExpense expense, _) => expense.amount,
        strokeWidthPxFn: (TimeSeriesExpense expense, _) => 4,
        colorFn: (TimeSeriesExpense expense, _) =>
            charts.MaterialPalette.green.shadeDefault,
        data: data,
      )
    ];

    if (date.day < lastDay.day) {
      List<TimeSeriesExpense> remainingData = [];
      for (var i = date.day + 1; i <= lastDay.day; i++) {
        var currentDate = DateTime.utc(lastDay.year, lastDay.month, i);
        remainingData.add(TimeSeriesExpense(currentDate, 0.0));
      }

      series.add(charts.Series<TimeSeriesExpense, DateTime>(
        id: 'Expenses-Remaining',
        domainFn: (TimeSeriesExpense expense, _) => expense.date,
        measureFn: (TimeSeriesExpense expense, _) => expense.amount,
        strokeWidthPxFn: (TimeSeriesExpense expense, _) => 1,
        colorFn: (TimeSeriesExpense expense, _) =>
            charts.MaterialPalette.transparent,
        data: remainingData,
      ));
    }

    return series;
  }

  List<charts.Series<TimeSeriesExpense, DateTime>> _createPreviousData(
      FilteredList<Expense> expenses,
      String currency,
      bool allTime,
      DateTime date) {
    List<TimeSeriesExpense> data = allTime
        ? _seriesForAllTime(currency, expenses)
        : _seriesFor(date, currency, expenses);

    return [
      charts.Series<TimeSeriesExpense, DateTime>(
        id: 'Expenses',
        domainFn: (TimeSeriesExpense expense, _) => expense.date,
        measureFn: (TimeSeriesExpense expense, _) => expense.amount,
        strokeWidthPxFn: (TimeSeriesExpense expense, _) => 3,
        colorFn: (TimeSeriesExpense expense, _) =>
            charts.MaterialPalette.gray.shade200,
        data: data,
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    expensesBloc.fetchAllExpenses();
    bool allTime = false;

    return SafeArea(
      child: StreamBuilder<FilteredList<Expense>>(
          stream: expensesBloc.allExpenses,
          initialData: FilteredList(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            Widget mainWidget;
            FilteredList<Expense> data = snapshot.data;
            if (data.isNotEmpty) {
              SwipeableTabBar currencyTabBar = SwipeableTabBar(
                expenses: data,
              );

              mainWidget = Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  currencyTabBar,
                  Divider(),
                  StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      children: <Widget>[
                        StatsTypeSwitch(
                          initialValue: allTime,
                          onChanged: ((bool value) => {
                                setState(() {
                                  allTime = value;
                                })
                              }),
                        ),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: Container(
                            height: MediaQuery.of(context).size.height / 5.0,
                            child: StreamBuilder<String>(
                              initialData: "EUR",
                              stream: currencyTabBar.currencyChanged,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                DateTime t = DateTime.now();
                                DateTime today =
                                    DateTime.utc(t.year, t.month, t.day);
                                DateTime previousMonthDate = DateTime.utc(
                                    t.year,
                                    t.month - 1,
                                    DateTime.utc(t.year, t.month, 0).day);

                                var previousData = _createPreviousData(data,
                                    snapshot.data, allTime, previousMonthDate);
                                var currentData =
                                    _createData(data, snapshot.data, today);

                                var values = [0.0];

                                if (previousData.isNotEmpty &&
                                    previousData.first.data.isNotEmpty) {
                                  var maxPrevious =
                                      previousData.first.data.last.amount;
                                  values.add(maxPrevious);
                                }
                                if (currentData.isNotEmpty &&
                                    currentData.first.data.isNotEmpty) {
                                  var maxCurrent =
                                      currentData.first.data.last.amount;
                                  values.add(maxCurrent);
                                }

                                var maxValue = values.reduce(max);

                                return Stack(
                                  children: <Widget>[
                                    LineStatsChart(
                                      previousData,
                                      maxValue: maxValue,
                                      animate: true,
                                    ),
                                    LineStatsChart(
                                      currentData,
                                      maxValue: maxValue,
                                      animate: true,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  Divider(),
                  StreamBuilder<String>(
                      initialData: "EUR",
                      stream: currencyTabBar.currencyChanged,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return StatsDetails(
                          expenses: data,
                          currency: snapshot.data,
                        );
                      }),
                ],
              );
            } else if (snapshot.hasError) {
              mainWidget = Text(snapshot.error.toString());
            } else
              mainWidget = Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                      'You have to add some expenses before you can see statistics.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(2.0, 2.0),
                            blurRadius: 2.0,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      )),
                ),
              );

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 40.0,
                          ),
                          Flexible(
                            child: PalTitleView(title: "STATS"),
                          ),
                          IconButton(
                            icon: Icon(Icons.help_outline),
                            color: Colors.transparent,
                            disabledColor: Colors.transparent,
                            onPressed: null,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: mainWidget,
                ),
              ],
            );
          }),
    );
  }
}

class StatsTypeSwitch extends StatelessWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  StatsTypeSwitch({@required this.initialValue, @required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          child: Column(
            children: <Widget>[
              Text(
                "COMPARE TO",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "PREVIOUS MONTH",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  Switch(
                    value: initialValue,
                    onChanged: ((bool value) => {
                          setState(() {
                            onChanged(value);
                          })
                        }),
                    activeColor: Colors.grey.shade200,
                    inactiveTrackColor: Colors.grey.shade200,
                  ),
                  Text(
                    "ALL TIME AVERAGE",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class StatsDetails extends StatelessWidget {
  final FilteredList<Expense> expenses;
  final String currency;

  StatsDetails({@required this.expenses, @required this.currency});

  double thisMonth() {
    DateTime t = DateTime.now();
    DateTime today = DateTime.utc(t.year, t.month, t.day);

    var thisMonthExpenses = expenses.where((expense) =>
        expense.date.year == today.year &&
        expense.date.month == today.month &&
        expense.currency == currency);

    if (thisMonthExpenses.isEmpty) return 0.0;

    return thisMonthExpenses
        .map((expense) => expense.amount)
        .reduce((value, element) => value + element);
  }

  double previousMonth() {
    DateTime t = DateTime.now();
    DateTime lastMonth = DateTime.utc(t.year, t.month, 0);

    var lastMonthExpenses = expenses.where((expense) =>
        expense.date.year == lastMonth.year &&
        expense.date.month == lastMonth.month &&
        expense.currency == currency);

    if (lastMonthExpenses.isEmpty) return 0.0;

    return lastMonthExpenses
        .map((expense) => expense.amount)
        .reduce((value, element) => value + element);
  }

  double thisMonthPerDay() {
    DateTime t = DateTime.now();
    DateTime lastDay = t.month < 12
        ? DateTime.utc(t.year, t.month + 1, 0)
        : DateTime.utc(t.year + 1, 1, 0);

    return thisMonth() / lastDay.day;
  }

  double previousMonthPerDay() {
    DateTime t = DateTime.now();
    DateTime lastMonth = DateTime.utc(t.year, t.month, 0);
    DateTime lastDay = lastMonth.month < 12
        ? DateTime.utc(lastMonth.year, lastMonth.month + 1, 0)
        : DateTime.utc(lastMonth.year + 1, 1, 0);

    return previousMonth() / lastDay.day;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: StatsDetailText(
                  title: "This month",
                  value: thisMonth().toStringAsFixed(2) + " " + currency,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: StatsDetailText(
                  title: "Avg. per day",
                  value: thisMonthPerDay().toStringAsFixed(2) + " " + currency,
                  color: Colors.green,
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: StatsDetailText(
                  title: "Previous month",
                  value: previousMonth().toStringAsFixed(2) + " " + currency,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: StatsDetailText(
                  title: "Avg. per day",
                  value:
                      previousMonthPerDay().toStringAsFixed(2) + " " + currency,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatsDetailText extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  StatsDetailText(
      {@required this.title, @required this.value, @required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 17.0,
              color: color,
            ),
          ),
          Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15.0,
                color: color.withOpacity(0.8),
              )),
        ],
      ),
    );
  }
}
