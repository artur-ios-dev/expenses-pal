import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class LineStatsChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final double maxValue;

  LineStatsChart(this.seriesList, {@required this.maxValue, this.animate});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      behaviors: [],
      domainAxis: charts.DateTimeAxisSpec(
        renderSpec: charts.NoneRenderSpec(),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.StaticNumericTickProviderSpec(
          <charts.TickSpec<num>>[
            charts.TickSpec<num>(0),
            charts.TickSpec<num>(maxValue),
          ],
        ),
        renderSpec: charts.NoneRenderSpec(),
      ),
    );
  }
}
