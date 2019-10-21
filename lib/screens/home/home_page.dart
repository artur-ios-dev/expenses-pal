import 'package:expenses_pal/common/ui/shadow_icon.dart';
import 'package:expenses_pal/screens/home/dashboard/dashboard_page.dart';
import 'package:expenses_pal/screens/home/more/more_page.dart';
import 'package:expenses_pal/screens/home/stats/stats_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dashboard = DashboardPage();
  final stats = StatsPage();
  final more = MorePage();

  Widget _tabs;

  Widget _getBody(index) {
    switch (index) {
      case 0:
        return dashboard;
        break;
      case 1:
        return stats;
        break;
      case 2:
        return more;
        break;
      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  Widget _createTabs(BuildContext context) {
    return CupertinoTabScaffold(
      resizeToAvoidBottomInset: false,
      tabBar: CupertinoTabBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ShadowIcon(
              Icons.dashboard,
              offsetX: 0.0,
              offsetY: 0.0,
              blur: 3.0,
              shadowColor: Colors.black.withOpacity(0.25),
            ),
            title: Text(
              'Dashboard',
              style: TextStyle(
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
          BottomNavigationBarItem(
            icon: ShadowIcon(
              Icons.show_chart,
              offsetX: 0.0,
              offsetY: 0.0,
              blur: 3.0,
              shadowColor: Colors.black.withOpacity(0.25),
            ),
            title: Text(
              'Stats',
              style: TextStyle(
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
          BottomNavigationBarItem(
            icon: ShadowIcon(
              Icons.more_horiz,
              offsetX: 0.0,
              offsetY: 0.0,
              blur: 3.0,
              shadowColor: Colors.black.withOpacity(0.25),
            ),
            title: Text(
              'More',
              style: TextStyle(
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
        ],
        backgroundColor: Colors.white,
        border: null,
        iconSize: 28.0,
        activeColor: Colors.green[700],
        inactiveColor: const Color(0xFFa3a3a3),
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            return CupertinoPageScaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: const Color(0xFFffffff),
              child: MaterialApp(
                home: Material(
                  type: MaterialType.transparency,
                  child: _getBody(index),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs == null) {
      _tabs = _createTabs(context);
    }
    return _tabs;
  }
}
