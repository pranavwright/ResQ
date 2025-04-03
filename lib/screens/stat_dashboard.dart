import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:resq/utils/resq_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _timer;
  
  List<DonationData> monetaryDonations = [
    DonationData(
      type: 'money',
      description: 'Cash Donation',
      value: 54000.0,
      date: DateTime.now(),
    ),
  ];

  List<AssetDonation> assetDonations = [
    AssetDonation(
      type: 'medical',
      description: 'Medical Equipment',
      quantity: 15,
      date: DateTime.now(),
    ),
    AssetDonation(
      type: 'food',
      description: 'Food Supplies',
      quantity: 120,
      date: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) => _updateData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateData() {
    setState(() {
      monetaryDonations = monetaryDonations
          .map((data) => DonationData(
                type: data.type,
                description: data.description,
                value: data.value + math.Random().nextInt(5000) - 2000,
                date: data.date,
              ))
          .toList();

      assetDonations = assetDonations
          .map((data) => AssetDonation(
                type: data.type,
                description: data.description,
                quantity: data.quantity + math.Random().nextInt(10) - 3,
                date: data.date,
              ))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Dashboard'),
        backgroundColor: Colors.blueGrey[800],
      ),
      drawer: MediaQuery.of(context).size.width < 800
          ? const ResQMenu(roles: ['admin'])
          : null,
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              if (MediaQuery.of(context).size.width >= 800)
                const ResQMenu(roles: ['admin'], showDrawer: false),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildChartCard(
                        'Monetary Donations',
                        _buildMonetaryDonationsChart(),
                        Colors.blue[700]!,
                        Icons.attach_money,
                      ),
                      _buildChartCard(
                        'Asset Donations',
                        _buildAssetDonationsChart(),
                        Colors.green[700]!,
                        Icons.inventory,
                      ),
                      _buildResourceDistributionChart(),
                      _buildDayTimelineChart(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart, Color color, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  title, 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  )
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 320, 
              child: chart
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonetaryDonationsChart() {
    return SfCircularChart(
      title: ChartTitle(text: 'Total: \$${_getTotalMonetaryDonations().toStringAsFixed(0)}'),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        DoughnutSeries<DonationData, String>(
          dataSource: monetaryDonations,
          xValueMapper: (DonationData data, _) => data.description,
          yValueMapper: (DonationData data, _) => data.value,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            useSeriesColor: true,
            connectorLineSettings: ConnectorLineSettings(
              type: ConnectorType.curve,
              length: '15%',
            ),
          ),
          dataLabelMapper: (DonationData data, _) => 
            '${data.description}\n\$${(data.value / 1000).toStringAsFixed(0)}K',
          explode: true,
          explodeIndex: 0,
          explodeOffset: '10%',
          radius: '80%',
          innerRadius: '50%',
          cornerStyle: CornerStyle.bothCurve,
        ),
      ],
    );
  }

  Widget _buildAssetDonationsChart() {
    return SfCircularChart(
      title: ChartTitle(text: 'Total Items: ${_getTotalAssetDonations()}'),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        PieSeries<AssetDonation, String>(
          dataSource: assetDonations,
          xValueMapper: (AssetDonation data, _) => data.description,
          yValueMapper: (AssetDonation data, _) => data.quantity,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            useSeriesColor: true,
            connectorLineSettings: ConnectorLineSettings(
              type: ConnectorType.curve,
              length: '15%',
            ),
          ),
          dataLabelMapper: (AssetDonation data, _) => 
            '${data.description}\n${data.quantity}',
          explode: true,
          explodeIndex: 0,
          explodeOffset: '10%',
          radius: '80%',
        ),
      ],
    );
  }

  Widget _buildResourceDistributionChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resource Distribution',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  groupsSpace: 30,
                  barGroups: [
                    // Day 1
                    BarChartGroupData(
                      x: 0,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 1200,
                          color: Colors.blue[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: 850,
                          color: Colors.green[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    ),
                    // Day 2
                    BarChartGroupData(
                      x: 1,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 900,
                          color: Colors.blue[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: 700,
                          color: Colors.green[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    ),
                    // Day 3
                    BarChartGroupData(
                      x: 2,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 600,
                          color: Colors.blue[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: 500,
                          color: Colors.green[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final titles = ['Day 1', 'Day 2', 'Day 3'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              titles[value.toInt()],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 200,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem(Colors.blue[400]!, 'Incoming Donations'),
                _buildLegendItem(Colors.green[400]!, 'Outgoing Donations'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTimelineChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disaster Timeline', 
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  groupsSpace: 20,
                  barGroups: [
                    // Day 1
                    BarChartGroupData(
                      x: 0,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 30,
                          color: Colors.green[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: 10,
                          color: Colors.orange[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: 5,
                          color: Colors.red[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    ),
                    // Day 2
                    BarChartGroupData(
                      x: 1,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 18,
                          color: Colors.green[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: 7,
                          color: Colors.orange[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: 3,
                          color: Colors.red[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    ),
                    // Day 3
                    BarChartGroupData(
                      x: 2,
                      barsSpace: 4,
                      barRods: [
                        BarChartRodData(
                          toY: 8,
                          color: Colors.green[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: 5,
                          color: Colors.orange[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        BarChartRodData(
                          toY: 2,
                          color: Colors.red[400]!,
                          width: 12,
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final titles = ['Day 1', 'Day 2', 'Day 3'];
                          return SideTitleWidget(
                            angle: 0,
                            space: 4,
                            meta: meta,
                            child: Text(
                              titles[value.toInt()],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem(Colors.green[400]!, 'Alive'),
                _buildLegendItem(Colors.orange[400]!, 'Missing'),
                _buildLegendItem(Colors.red[400]!, 'Deceased'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  double _getTotalMonetaryDonations() {
    return monetaryDonations.map((data) => data.value).reduce((a, b) => a + b);
  }

  int _getTotalAssetDonations() {
    return assetDonations.map((data) => data.quantity).reduce((a, b) => a + b);
  }
}

class DonationData {
  final String type;
  final String description;
  final double value;
  final DateTime date;

  DonationData({
    required this.type,
    required this.description,
    required this.value,
    required this.date,
  });
}

class AssetDonation {
  final String type;
  final String description;
  final int quantity;
  final DateTime date;

  AssetDonation({
    required this.type,
    required this.description,
    required this.quantity,
    required this.date,
  });
}