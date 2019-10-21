import 'package:flutter/material.dart';

class PalTitleView extends StatelessWidget {
  final String title;

  PalTitleView({@required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.green[700],
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        shadows: <Shadow>[
          Shadow(
            offset: Offset(2.0, 2.0),
            blurRadius: 2.0,
            color: Colors.black.withOpacity(0.15),
          ),
        ],
      ),
    );
  }
}
