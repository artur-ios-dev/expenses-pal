import 'dart:async';

import 'package:expenses_pal/blocs/expenses_bloc.dart';
import 'package:expenses_pal/common/helpers.dart';
import 'package:expenses_pal/common/models/expenses.dart';
import 'package:expenses_pal/common/models/tag.dart';
import 'package:expenses_pal/common/ui/pal_button.dart';
import 'package:expenses_pal/common/ui/pal_title_view.dart';
import 'package:expenses_pal/common/ui/single_tag.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddExpensePage extends StatefulWidget {
  @override
  AddExpensePageState createState() {
    return AddExpensePageState();
  }
}

class AddExpensePageState extends State<AddExpensePage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  final currencyController = TextEditingController();
  final tagController = TextEditingController();
  final tagFocusNode = FocusNode();
  final List<Tag> tags = [];

  final _formKey = GlobalKey<FormState>();

  Color currentColor = Color(0xff443a49);
  DateTime currentDate = DateTime.now();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    currencyController.dispose();
    tagController.dispose();
    tagFocusNode.dispose();
    super.dispose();
  }

  changeColor(Color color) => setState(() => currentColor = color);

  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: currentDate,
        firstDate: DateTime(currentDate.year - 1),
        lastDate: DateTime(currentDate.year + 1));
    if (picked != null)
      setState(() {
        DateTime now = DateTime.now();
        DateTime date = DateTime.utc(
            picked.year, picked.month, picked.day, now.hour, now.minute);
        currentDate = date;
      });
  }

  void addTag(String newValue, BuildContext context) {
    if (newValue.trim().length < 1) return;

    tags.removeWhere((tag) => tag.name == newValue.trim());

    Tag tag = Tag(name: newValue.trim(), color: currentColor);
    tagController.text = "";

    setState(() {
      tags.add(tag);
    });

    FocusScope.of(context).requestFocus(tagFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Flexible(
                        child: PalTitleView(title: "ADD"),
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
              child: Form(
                key: _formKey,
                child: ListView(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.title),
                      title: TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: "Title",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter title";
                          }
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.attach_money),
                      title: TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Amount",
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Please enter amount";
                          }
                        },
                      ),
                      trailing: Container(
                        width: 50.0,
                        child: TextField(
                          controller: currencyController,
                          decoration: InputDecoration(
                            hintText: "EUR",
                          ),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          hintText: "Description",
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.label),
                      title: TextField(
                        controller: tagController,
                        focusNode: tagFocusNode,
                        onChanged: (newValue) {
                          if (newValue.endsWith(',')) {
                            addTag(newValue.replaceAll(",", ""), context);
                          }
                        },
                        onSubmitted: (newValue) {
                          addTag(newValue, context);
                        },
                        decoration: InputDecoration(
                          hintText: "Tag",
                        ),
                      ),
                      trailing: Container(
                        width: 40.0,
                        child: FlatButton(
                          onPressed: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  titlePadding: const EdgeInsets.all(0.0),
                                  contentPadding: const EdgeInsets.all(0.0),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: currentColor,
                                      onColorChanged: changeColor,
                                      colorPickerWidth: MediaQuery.of(context).size.width - 32.0,
                                      pickerAreaHeightPercent: 0.7,
                                      enableAlpha: true,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          color: currentColor,
                          child: null,
                        ),
                      ),
                    ),
                    ListTile(
                      title: tags.length > 0
                          ? _RemoveableExpenseTags(
                              tags: tags,
                              removeAction: (tag) {
                                setState(() {
                                  tags.remove(tag);
                                });
                              },
                            )
                          : Center(
                              child: Text(
                                'No tags yet. Add tag by typing in the field above. To confirm it just press Return or type a comma.',
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 14.0),
                              ),
                            ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.today),
                      title: const Text('Date'),
                      subtitle: Text(
                        DateHelper.formatDate(
                          currentDate,
                          fullDate: true,
                          withTime: true,
                        ),
                      ),
                      onTap: _selectDate,
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: PalButton(
                        title: "ADD",
                        width: MediaQuery.of(context).size.width * (2.0 / 3.0),
                        colors: [Colors.green[600], Colors.green[900]],
                        onPressed: () {
                          if (!_formKey.currentState.validate()) {
                            return;
                          }
                          Expense expense = Expense(
                              title: titleController.text,
                              description: descriptionController.text,
                              date: currentDate,
                              amount:
                                  double.tryParse(amountController.text) ?? 0.0,
                              currency: currencyController.text.isNotEmpty
                                  ? currencyController.text
                                  : "EUR",
                              tags: tags);
                          expensesBloc.addExpense(expense);
                          Navigator.of(context).pop();
                        },
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

class _RemoveableExpenseTags extends StatelessWidget {
  final List<Tag> tags;
  final SingleTagCallback removeAction;

  _RemoveableExpenseTags({@required this.tags, this.removeAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.0,
      child: Center(
        child: ListView.builder(
          itemCount: tags.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            Tag tag = tags[index];
            return Center(
              child: Padding(
                padding: EdgeInsets.only(
                    right: index == tags.length - 1 ? 0.0 : 4.0),
                child: SingleTag(
                  tag: tag,
                  removeAction: removeAction,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
