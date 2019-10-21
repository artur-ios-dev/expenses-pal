import 'package:expenses_pal/common/models/tag.dart';
import 'package:expenses_pal/common/ui/single_tag.dart';
import 'package:flutter/material.dart';

class ExpenseTags extends StatelessWidget {
  final List<Tag> tags;

  ExpenseTags({@required this.tags});

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
                child: SingleTag(tag: tag),
              ),
            );
          },
        ),
      ),
    );
  }
}
