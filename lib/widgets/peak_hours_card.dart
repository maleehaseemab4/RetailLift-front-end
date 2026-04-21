import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoplifting_app/providers/analytics_provider.dart';

class PeakHoursCard extends StatelessWidget {
  const PeakHoursCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, analytics, _) {
        final bars = <BarChartGroupData>[];
        for (int hour = 0; hour < 24; hour++) {
          final count = analytics.peakHours[hour] ?? 0;
          bars.add(
            BarChartGroupData(
              x: hour,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  color: const Color(0xFF001F3F),
                  width: 16,
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Peak Hours of Shoplifting',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: BarChart(
                  BarChartData(
                    barGroups: bars,
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() % 4 == 0) {
                              return Text(
                                '${value.toInt()}:00',
                                style: const TextStyle(fontSize: 10),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
