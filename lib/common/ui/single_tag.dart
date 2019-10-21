import 'package:expenses_pal/common/models/tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/utils.dart';

typedef void SingleTagCallback(Tag tag);

class SingleTag extends StatelessWidget {
  final Tag tag;
  final SingleTagCallback removeAction;

  SingleTag({@required this.tag, this.removeAction});

  @override
  Widget build(BuildContext context) {
    Color color = useWhiteForeground(tag.color) ? Colors.white : Colors.black;
    double rightPadding = removeAction == null ? 8.0 : 4.0;
    List<Widget> childs = [
      Text(
        tag.name,
        style: TextStyle(
          color: color,
        ),
      ),
    ];

    if (removeAction != null) {
      childs.add(
        Icon(
          Icons.close,
          color: color,
          size: 20,
        ),
      );
    }

    Widget main = Container(
      decoration: BoxDecoration(
        color: tag.color,
        borderRadius: BorderRadius.circular(
          8.0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 8.0,
          top: 2.0,
          bottom: 2.0,
          right: rightPadding,
        ),
        child: Row(
          children: childs,
        ),
      ),
    );

    if (removeAction != null) {
      return GestureDetector(
        onTap: () {
          removeAction(tag);
        },
        child: main,
      );
    }

    return main;
  }
}
