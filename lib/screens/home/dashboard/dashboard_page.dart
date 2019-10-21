import 'package:expenses_pal/blocs/expenses_bloc.dart';
import 'package:expenses_pal/common/assets.dart';
import 'package:expenses_pal/common/helpers.dart';
import 'package:expenses_pal/common/models/expenses.dart';
import 'package:expenses_pal/common/ui/expense_tags.dart';
import 'package:expenses_pal/common/ui/pal_button.dart';
import 'package:expenses_pal/common/ui/pal_title_view.dart';
import 'package:expenses_pal/common/ui/swipeable_tabbar.dart';
import 'package:expenses_pal/screens/home/dashboard/add_expense_page.dart';
import 'package:expenses_pal/screens/home/dashboard/expense_details_page.dart';
import 'package:expenses_pal/screens/home/dashboard/filter/filter.dart';
import 'package:expenses_pal/screens/home/dashboard/filter/filter_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:rxdart/rxdart.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final addPage = AddExpensePage();
  final filterPage = FilterPage();

  @override
  void initState() {
    super.initState();
    expensesBloc.fetchAllExpenses();
    filtersBloc.fetchInitialFilters();
  }

  Observable<List<Object>> getData() {
    var stream = Observable.combineLatestList(
        [expensesBloc.allExpenses, filtersBloc.filters]);
    return stream;
  }

  Widget _createBody(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<List<Object>>(
        stream: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Widget mainWidget;
          SwipeableTabBar currencyTabBar;
          FilteredList<Expense> expenses = FilteredList();
          int activeFilters = 0;
          if (snapshot.hasData) {
            List<Object> data = snapshot.data;
            expenses.addAll(data.first);

            List<ExpenseFilter> filters = data.last;
            if (filters != null) {
              expenses = expenses.applyFilters(filters);
              activeFilters = filters.length;
            }

            currencyTabBar = SwipeableTabBar(
              expenses: expenses,
              singleLine: true,
            );
            mainWidget = _buildList(expenses, expensesBloc, activeFilters > 0);
          } else if (snapshot.hasError) {
            mainWidget = Text(snapshot.error.toString());
          } else
            mainWidget = Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.green[600],
                ),
              ),
            );

          Widget titleWidget;
          titleWidget = PalTitleView(
            title: "YOUR EXPENSES",
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
                        IconButton(
                          icon: Icon(Icons.filter_list),
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                fullscreenDialog: true,
                                builder: (BuildContext context) {
                                  return filterPage;
                                },
                              ),
                            );
                          },
                        ),
                        Flexible(
                          child: titleWidget,
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                fullscreenDialog: true,
                                builder: (BuildContext context) {
                                  return addPage;
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Center(
                child: activeFilters == 0
                    ? Container()
                    : Container(
                        color: Colors.redAccent.shade200,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 40,
                            ),
                            Expanded(
                              child: Text(
                                'There is a $activeFilters active filter' +
                                    (activeFilters > 1 ? 's' : ''),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(2.0, 2.0),
                                        blurRadius: 2.0,
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                    ]),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel),
                              color: Colors.white,
                              highlightColor: Colors.transparent,
                              onPressed: () {
                                filtersBloc.setFilters([]);
                              },
                            )
                          ],
                        ),
                      ),
              ),
              Expanded(
                child: mainWidget,
              ),
              Center(
                child: expenses.length == 0 || activeFilters == 0
                    ? Container()
                    : Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "SUMMARY",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 15.0,
                                color: Colors.black87,
                              ),
                            ),
                            currencyTabBar
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _createBody(context);
  }

  Widget _buildList(
      FilteredList<Expense> expenses, ExpensesBloc bloc, bool filtersActive) {
    if (expenses.length <= 0) {
      return _DashboardEmptyState(filtersActive: filtersActive);
    }

    List<dynamic> items = [];

    Expense lastExpense;
    expenses.forEach((expense) {
      if (items.length == 0) {
        items.add(expense.date);
      } else if (lastExpense != null &&
          !DateHelper.isSameDay(expense.date, lastExpense.date)) {
        items.add(expense.date);
      }

      items.add(expense);
      lastExpense = expense;
    });

    void _onTapItem(BuildContext context, Expense expense) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return ExpenseDetailsPage(
              expense: expense,
              expenses: expenses,
            );
          },
        ),
      );
    }

    return NestedScrollView(
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          return (items[index] is Expense)
              ? GestureDetector(
                  child: _ExpenseCard(
                    expense: items[index],
                  ),
                  onTap: () => _onTapItem(context, items[index]),
                )
              : _DateHeaderCard(
                  date: items[index],
                );
        },
      ),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return filtersActive
            ? []
            : <Widget>[
                SliverAppBar(
                  backgroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: screenAwareSize(192.0, context),
                          child: FlareActor(
                            Assets.walletFlare,
                            alignment: Alignment.center,
                            fit: BoxFit.contain,
                            animation: "idle",
                          ),
                        )
                      ],
                    ),
                  ),
                  expandedHeight: screenAwareSize(192.0, context),
                ),
              ];
      },
    );
  }
}

class _DateHeaderCard extends StatelessWidget {
  final DateTime date;

  _DateHeaderCard({@required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        DateHelper.formatDate(date),
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final Expense expense;

  _ExpenseCard({@required this.expense});

  List<Widget> buildDetails() {
    Widget title = Padding(
      padding: EdgeInsets.only(bottom: 4.0),
      child: Text(
        expense.title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    Widget description = Text(
      expense.description,
      style: TextStyle(
        color: Colors.black.withOpacity(0.75),
        fontSize: 15.0,
        fontWeight: FontWeight.w500,
      ),
    );

    Widget date = Text(
      "${expense.date.hour}".padLeft(2, '0') +
          ":" +
          "${expense.date.minute}".padLeft(2, '0'),
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 15.0,
        fontWeight: FontWeight.w500,
      ),
    );

    List<Widget> widgets = [title];

    if (expense.description.isNotEmpty) {
      widgets.add(description);
    }

    widgets.add(date);

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    String currency = expense.currency != null ? " ${expense.currency}" : "";
    Widget tags = Padding(
      padding: EdgeInsets.only(top: 4.0),
      child: ExpenseTags(
        tags: expense.tags,
      ),
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(
          8.0,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0.0, 4.0),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: buildDetails(),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  expense.amount.toStringAsFixed(2) + currency,
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: 8.0,
            ),
            child: expense.tags.isNotEmpty ? tags : Container(),
          ),
        ],
      ),
    );
  }
}

class _DashboardEmptyState extends StatelessWidget {
  final bool filtersActive;

  _DashboardEmptyState({@required this.filtersActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: FlareActor(
            Assets.walletFlare,
            alignment: Alignment.center,
            fit: BoxFit.contain,
            animation: "idle",
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              filtersActive
                  ? "There is no expenses with given criteria"
                  : "Nothing to see here yet. Add an expense after you spend some money.",
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
              ),
            ),
          ),
        ),
        PalButton(
          title: "ADD",
          width: MediaQuery.of(context).size.width * (2.0 / 3.0),
          colors: [Colors.green[600], Colors.green[900]],
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return AddExpensePage();
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
