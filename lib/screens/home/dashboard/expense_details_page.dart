import 'package:expenses_pal/blocs/expenses_bloc.dart';
import 'package:expenses_pal/common/helpers.dart';
import 'package:expenses_pal/common/models/expenses.dart';
import 'package:expenses_pal/common/ui/expense_tags.dart';
import 'package:expenses_pal/common/ui/pal_button.dart';
import 'package:expenses_pal/screens/home/dashboard/filter/filter.dart';
import 'package:flutter/material.dart';
import 'package:expenses_pal/common/ui/pal_title_view.dart';

class ExpenseDetailsPage extends StatelessWidget {
  final FilteredList<Expense> expenses;
  final Expense expense;

  ExpenseDetailsPage({@required this.expense, @required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
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
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Flexible(
                        child: PalTitleView(title: expense.title),
                      ),
                      Container(
                        width: 40.0,
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          DateHelper.formatDate(expense.date,
                              fullDate: true, withTime: true),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.shopping_basket)),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          expense.amount.toStringAsFixed(2) +
                              " " +
                              expense.currency,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 21.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          expense.description, // TDOO: if exists
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: expense.tags.length > 0
                          ? ExpenseTags(
                              tags: expense.tags,
                            )
                          : Text("No tags"),
                    ),
                    Divider(),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(
                        child: PalButton(
                          title: "REMOVE",
                          width:
                              MediaQuery.of(context).size.width * (2.0 / 3.0),
                          colors: [Colors.red[600], Colors.red[900]],
                          onPressed: () {
                            expensesBloc.removeExpense(expense);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
