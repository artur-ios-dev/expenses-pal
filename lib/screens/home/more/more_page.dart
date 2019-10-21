import 'dart:io';

import 'package:expenses_pal/common/ui/pal_title_view.dart';
import 'package:expenses_pal/screens/home/more/policy_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:launch_review/launch_review.dart';

class MorePage extends StatelessWidget {
  _sendMail(String toMailId, String subject, String body) async {
    var url = 'mailto:$toMailId?subject=$subject&body=$body';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                    Container(
                      width: 40.0,
                    ),
                    Flexible(
                      child: PalTitleView(title: "MORE"),
                    ),
                    IconButton(
                      icon: Icon(Icons.help_outline),
                      color: Colors.transparent,
                      disabledColor: Colors.transparent,
                      onPressed: null,
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: Icon(
                      Icons.rate_review,
                      color: Colors.green[600],
                    ),
                    title: Text(Platform.isIOS
                        ? 'Rate us on AppStore'
                        : 'Rate us on GooglePlay'),
                    onTap: () {
                      LaunchReview.launch();
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.book,
                      color: Colors.green[600],
                    ),
                    title: Text('Privacy Policy'),
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          fullscreenDialog: true,
                          builder: (BuildContext context) {
                            return PolicyPage();
                          },
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.mail,
                      color: Colors.green[600],
                    ),
                    title: Text('Contact us'),
                    onTap: () {
                      _sendMail("expense.pal.app@gmail.com", "Expense Pal", "Check out this app. It's really great!");
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
