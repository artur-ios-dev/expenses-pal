import 'package:expenses_pal/common/helpers.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';

class CircledImage extends StatelessWidget {
  final String image;
  final double imageSize;

  CircledImage({@required this.image, @required this.imageSize});

  Widget _centerCircle(
      double radius, double opacity, bool randomizeCenter, double width) {
    Random rnd = Random();
    double diff = (rnd.nextDouble() - 0.5) / 10.0;
    double centerTopOffset =
        randomizeCenter ? (rnd.nextDouble() - 0.5) * (radius / 5.0) : 0.0;
    double centerLeftOffset =
        randomizeCenter ? (rnd.nextDouble() - 0.5) * (radius / 5.0) : 0.0;

    return new Positioned(
      top: 1.25 * imageSize - radius / 2.0 + centerTopOffset,
      left: (width - radius) / 2.0 + centerLeftOffset,
      width: radius,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity + diff),
        ),
      ),
    );
  }

  Widget _largeCircle(double height) {
    Random rnd = Random();
    double top = rnd.nextDouble();
    double radius = rnd.nextDouble() * height;
    double opacity = rnd.nextDouble() * 0.25;

    return new Positioned(
      top: top,
      width: radius,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }

  Widget _smallCircle(double height, double width) {
    Random rnd = Random();
    double top = rnd.nextDouble() * height;
    double left = rnd.nextDouble() * width;
    double radius = rnd.nextDouble() * 15.0;
    double opacity = rnd.nextDouble() * 0.75;

    return new Positioned(
      top: top,
      left: left,
      width: radius,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = screenAwareSize(size.width, context);
    final height = screenAwareSize(size.height, context);

    List<Widget> widgets = [];
    List<Widget> smallCircles =
        List(10).map((_) => _smallCircle(height, width)).toList();
    List<Widget> largeCircles =
        List(5).map((_) => _largeCircle(width)).toList();
    List<Widget> centerCircles = [
      _centerCircle(width * 1.35, 0.07, true, width),
      _centerCircle(width * 1.25, 0.1, true, width),
      _centerCircle(width * 1.0, 0.15, true, width),
      _centerCircle(size.width * 0.8, 0.75, false, size.width),
    ];
    widgets.addAll(smallCircles);
    widgets.addAll(largeCircles);
    widgets.addAll(centerCircles);

    widgets.add(
      Positioned(
        top: imageSize * 1.25 - (size.width * 0.5) / 2.0,
        child: SizedBox(
          child: SvgPicture.asset(
            image,
            fit: BoxFit.cover,
          ),
          height: imageSize * 0.8,
          width: imageSize * 0.8,
        ),
      ),
    );

    return Stack(
      children: widgets,
      alignment: FractionalOffset.center,
    );
  }
}

// TODO: Credits
/*
<div>Icons made by <a href="https://www.flaticon.com/authors/dimitry-miroliubov" title="Dimitry Miroliubov">Dimitry Miroliubov</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
<div>Icons made by <a href="https://www.freepik.com/" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
<div>Icons made by <a href="https://www.flaticon.com/authors/smashicons" title="Smashicons">Smashicons</a> from <a href="https://www.flaticon.com/" 			    title="Flaticon">www.flaticon.com</a> is licensed by <a href="http://creativecommons.org/licenses/by/3.0/" 			    title="Creative Commons BY 3.0" target="_blank">CC 3.0 BY</a></div>
*/
