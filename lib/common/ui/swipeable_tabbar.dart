import 'package:expenses_pal/common/models/expenses.dart';
import 'package:expenses_pal/screens/home/dashboard/filter/filter.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SwipeableTabBar extends StatelessWidget {
  final _currencyFetcher = PublishSubject<String>();
  Observable<String> get currencyChanged => _currencyFetcher.stream;

  final FilteredList<Expense> expenses;
  final bool singleLine;
  final _controller = PageController();

  SwipeableTabBar({@required this.expenses, this.singleLine = false});

  dispose() {
    _currencyFetcher.close();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [];

    List<String> currencies = ["EUR"];
    if (expenses.length > 0) {
      currencies = expenses.map((expense) => expense.currency).toSet().toList();
      for (var currency in currencies) {
        var expesnesForCurrency =
            expenses.where((expense) => expense.currency == currency).toList();

        double amount = 0;
        if (expesnesForCurrency.length > 0) {
          amount = expesnesForCurrency
              .map((expense) => expense.amount)
              .reduce((value, element) => value + element);
        }

        _pages.add(CurrencyTabBarItem(
          currency: currency,
          amount: amount,
          singleLine: singleLine,
        ));
      }
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          height: 60.0,
          width: 150.0,
          child: PageView.builder(
            itemCount: _pages.length,
            controller: _controller,
            itemBuilder: (BuildContext context, int index) {
              return _pages[index % _pages.length];
            },
            onPageChanged: (int index) {
              _currencyFetcher.sink.add(currencies[index]);
            },
          ),
        );
      },
    );
  }
}

class CurrencyTabBarItem extends StatelessWidget {
  final String currency;
  final double amount;
  final bool singleLine;

  CurrencyTabBarItem(
      {@required this.currency,
      @required this.amount,
      @required this.singleLine});

  @override
  Widget build(BuildContext context) {
    String amountString = amount.toStringAsFixed(2);
    List<String> parts = amountString.split('.');

    var currencyText = Text(
      currency,
      style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w300),
    );

    var rowChildrens = <Widget>[
      Text(
        parts.first,
        style: TextStyle(fontSize: 21.0, fontWeight: FontWeight.w600),
      ),
      Text(
        '.',
        style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
      ),
      Text(
        parts.last,
        style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
      ),
    ];

    if (singleLine) {
      rowChildrens.add(Padding(
        padding: EdgeInsets.only(left: 4),
        child: currencyText,
      ));
    }

    var columnChildrens = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: rowChildrens,
      ),
    ];

    if (!singleLine) {
      columnChildrens.add(Text(
        currency,
        style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w300),
      ));
    }

    return Column(
      children: columnChildrens,
    );
  }
}
