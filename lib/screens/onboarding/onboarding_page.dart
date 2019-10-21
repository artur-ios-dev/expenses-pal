import 'package:expenses_pal/common/assets.dart';
import 'package:expenses_pal/common/helpers.dart';
import 'package:expenses_pal/common/ui/pal_button.dart';
import 'package:expenses_pal/screens/home/home_page.dart';
import 'package:expenses_pal/screens/onboarding/circled_image.dart';
import 'package:expenses_pal/screens/onboarding/dots_indicator.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final home = HomePage();
  final _controller = PageController();
  final List<Widget> _pages = [
    OnboardingSinglePage(
      image: Assets.onboarding1,
      title: "Expenses",
      subtitle:
          "Add your expenses to be able to always get back and check where you have spent your money",
      colors: [
        Colors.lightBlue[50],
        Colors.lightBlue[600],
        Colors.lightBlue[900],
      ],
    ),
    OnboardingSinglePage(
      image: Assets.onboarding2,
      title: "Tags",
      subtitle: "You can also tag them to easily search through them and check where you spend your money the most",
      colors: [
        Colors.lightBlue[50],
        Colors.lightBlue[600],
        Colors.lightBlue[900],
      ],
    ),
    OnboardingSinglePage(
      image: Assets.onboarding3,
      title: "Stats",
      subtitle: "Check stats of your expenses and compare your current month expenses to last month or lifetime average",
      colors: [
        Colors.lightBlue[50],
        Colors.lightBlue[600],
        Colors.lightBlue[900],
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    int page;
    OnboardingSinglePage currentPage;
    List<Color> nextColors;

    _configurePage(int index) {
      page = index;
      currentPage = _pages[page];
      nextColors = [currentPage.colors[2], currentPage.colors[1]];
    }

    _configurePage(0);

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        List<Widget> bottomButtons = [];
        if (page < _pages.length - 1) {
          bottomButtons.add(
            PalButton(
              title: "NEXT",
              onPressed: () {
                int nextPage = page + 1;
                setState(() {
                  _configurePage(nextPage);
                });
                _controller.animateToPage(
                  nextPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              colors: nextColors,
            ),
          );
        }

        bottomButtons.add(
          PalButton(
            title: page == _pages.length - 1 ? 'DONE' : 'SKIP',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => home));
            },
          ),
        );

        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: PageView.builder(
                physics: ClampingScrollPhysics(),
                itemCount: _pages.length,
                controller: _controller,
                itemBuilder: (BuildContext context, int index) {
                  return _pages[index % _pages.length];
                },
                onPageChanged: (int index) {
                  setState(() {
                    _configurePage(index);
                  });
                },
              ),
            ),
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 8.0,
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: DotsIndicator(
                        controller: _controller,
                        itemCount: _pages.length,
                        onPageSelected: (int index) {
                          setState(() {
                            _configurePage(index);
                          });
                          _controller.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: bottomButtons,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class OnboardingSinglePage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final List<Color> colors;

  OnboardingSinglePage(
      {@required this.image,
      @required this.title,
      @required this.subtitle,
      @required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment(0.5, -1.0),
          end: Alignment(0.5, 1.0),
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CircledImage(
              image: image,
              imageSize: screenAwareSize(256.0, context),
            ),
          ),
          Positioned(
            top: screenAwareSize(464.0, context),
            left: 0.0,
            right: 0.0,
            child: SafeArea(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: screenAwareFontSize(32.0, context),
                          fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenAwareFontSize(16.0, context),
                      ),
                      textAlign: TextAlign.center,
                    ),
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
