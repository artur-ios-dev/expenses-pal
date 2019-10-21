import 'package:expenses_pal/common/database_manager/database_model.dart';
import 'package:expenses_pal/common/models/tag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class Expense extends DatabaseModel {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final double amount;
  final String currency;
  final List<Tag> tags;

  Expense(
      {this.id,
      this.title,
      this.description,
      @required this.date,
      @required this.amount,
      @required this.currency,
      @required this.tags});

  @override
  List<String> removeArgs() {
    return [id.toString()];
  }

  @override
  String removeQuery() {
    return '_id = ?';
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'amount': amount.toString(),
      'currency': currency,
      'tags': jsonEncode(tags) //tags.map((tag) => tag.toJson())
    };

    if (id != null) {
      map['_id'] = id;
    }
    return map;
  }
}

class ExpenseTable extends DatabaseTable {
  ExpenseTable()
      : super(
            'Expenses',
            [
              '_id',
              'title',
              'description',
              'date',
              'amount',
              'currency',
              'tags'
            ],
            '_id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description TEXT, date TEXT, amount TEXT, currency TEXT, tags TEXT');

  @override
  DatabaseModel entryFromMap(Map map) {
    List<Tag> tags = (jsonDecode(map['tags']) as List<dynamic>).map((json) => Tag.fromJson(json)).toList();
    var entry = Expense(
      id: map['_id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.parse(map['date']),
      amount: double.parse(map['amount']),
      currency: map['currency'],
      tags: tags,
    );

    return entry;
  }
}
