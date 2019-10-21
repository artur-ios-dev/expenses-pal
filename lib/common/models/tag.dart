import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Tag {
  final String name;
  final Color color;

  Tag({@required this.name, this.color = Colors.black});

  Tag.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        color = Color(int.parse(json['color'], radix: 16));

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color.toString().split('(0x')[1].split(')')[0],
      };
}
