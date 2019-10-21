import 'package:expenses_pal/common/helpers.dart';
import 'package:flutter/material.dart';

class PalButton extends StatelessWidget {
  final String title;
  final double width;
  final VoidCallback onPressed;
  final Color textColor;
  final Color highlightColor;
  final List<Color> colors;

  PalButton(
      {@required this.title,
      this.width = 150.0,
      this.onPressed,
      this.textColor = Colors.white,
      this.highlightColor = Colors.white30,
      this.colors});

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;

    final double radius = screenAwareSize(30.0, context);

    var boxShadow = [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 4.0,
        spreadRadius: 2.0,
        offset: Offset(
          3.0,
          3.0,
        ),
      )
    ];

    if (colors == null) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white, width: 1.0),
        color: Colors.transparent,
      );
    } else {
      decoration = BoxDecoration(
        gradient: LinearGradient(
            colors: colors,
            begin: Alignment(0.5, -1.0),
            end: Alignment(0.5, 1.0)),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: boxShadow,
      );
    }

    return Center(
      child: Container(
        width: width,
        height: screenAwareSize(50.0, context),
        decoration: decoration,
        child: Material(
          child: FlatButton(
            child: Text(
              title,
              style: TextStyle(color: textColor),
            ),
            onPressed: onPressed,
            highlightColor: highlightColor,
            splashColor: highlightColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
              30.0,
            )),
          ),
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
