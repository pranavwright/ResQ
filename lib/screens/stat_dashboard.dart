import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
  
  List<DonationData> donationData = [
    DonationData(
      type: 'money',
      description: 'Cash Donation',
      value: 54000.0,
      date: DateTime.now(),
    ),
    DonationData(
      type: 'assets',
      description: 'Medical Equipment',
      value: 72000.0,
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
      donationData = donationData
          .map((data) => DonationData(
                type: data.type,
                description: data.description,
                value: data.value + math.Random().nextInt(5000) - 2000,
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
                        'Donations Breakdown',
                        _buildDonationsChart(),
                        Colors.orange[700]!,
                        Icons.pie_chart
                      ),
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

  Widget _buildDonationsChart() {
    return SfCircularChart(
      title: ChartTitle(text: 'Total: \$${_getTotalDonations().toStringAsFixed(0)}'),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        DoughnutSeries<DonationData, String>(
          dataSource: donationData,
          xValueMapper: (DonationData data, _) => data.type,
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
            '${data.type}\n\$${(data.value / 1000).toStringAsFixed(0)}K',
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

  int _getTotalDonations() {
    return donationData.map((data) => data.value).reduce((a, b) => a + b).toInt();
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