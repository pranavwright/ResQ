import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Statistics Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data (replace with actual data fetching)
  List<DonationData> _monetaryDonations = _generateMonetaryDonations();
  List<AssetDonation> _assetDonations = _generateAssetDonations();
  List<ResourceDistributionData> _resourceDistributionData =
      _generateResourceDistribution();
  List<DisasterTimelineData> _disasterTimelineData = _generateDisasterTimeline();

    @override
  void initState() {
    super.initState();
    // Simulate data updates
    Future.delayed(Duration.zero, () {
      // Use a Timer to update the data periodically
      
      
    });
  }

  static List<DonationData> _generateMonetaryDonations() {
    const types = ['Cash Donation', 'Online Transfer', 'Cheque'];
    return List.generate(5, (i) => DonationData(
      type: types[i % types.length],
      description: 'Donation ${i + 1}',
      value: (10000 * (1 + (0.1 * i))), // Changed to double
      date: DateTime.now().subtract(Duration(days: i)),
    ));
  }

  static List<AssetDonation> _generateAssetDonations() {
    const types = ['Medical Supplies', 'Food Items', 'Clothing', 'Shelter'];
    return List.generate(5, (i) => AssetDonation(
      type: types[i % types.length],
      description: 'Asset Donation ${i + 1}',
      quantity: (100 + i * 10),
      date: DateTime.now().subtract(Duration(days: i)),
    ));
  }

  static List<ResourceDistributionData> _generateResourceDistribution() {
    return List.generate(7, (i) => ResourceDistributionData(
      day: 'Day ${i + 1}',
      incoming: 1000 + i * 100,
      outgoing: 700 + i * 50,
    ));
  }

  static List<DisasterTimelineData> _generateDisasterTimeline() {
  return List.generate(7, (i) => DisasterTimelineData(
    day: 'Day ${i + 1}',
    alive: 50 + (100 - i * 10).toInt(), // Ensure it doesn't go below 0
    missing: (50 - i * 5).toInt().clamp(0, 50), // Ensure 0-50 range
    deceased: (i * 3).toInt().clamp(0, 20),
  ));
}

  // Chart Colors
  final List<Color> _monetaryColors = [
    Colors.blue[400]!,
    Colors.green[400]!,
    Colors.orange[400]!,
    Colors.red[400]!,
    Colors.purple[400]!,
  ];
  final List<Color> _assetColors = [
    Colors.green[400]!,
    Colors.red[400]!,
    Colors.yellow[400]!,
    Colors.purple[400]!,
  ];
  final List<Color> _resourceColors = [
    Colors.blue[400]!,
    Colors.orange[400]!,
  ];
    final List<Color> _timelineColors = [
    Colors.green[400]!,
    Colors.orange[400]!,
    Colors.red[400]!,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics Dashboard'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Container(
        color: Colors.white,
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
    );
  }

  Widget _buildChartCard(
      String title, Widget chart, Color color, IconData icon) {
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
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(height: 320, child: chart),
          ),
        ],
      ),
    );
  }

  Widget _buildMonetaryDonationsChart() {
    final total = _monetaryDonations.fold<double>(
        0, (sum, item) => sum + item.value); // Calculate total

    return SfCircularChart(
      title: ChartTitle(text: 'Total: \$${total.toStringAsFixed(2)}'),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        DoughnutSeries<DonationData, String>(
          dataSource: _monetaryDonations,
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
              '${data.type}\n\$${data.value.toStringAsFixed(0)}', //Show value
          radius: '80%',
          innerRadius: '50%',
          pointColorMapper: (DonationData data, index) =>
              _monetaryColors[index % _monetaryColors.length],
        ),
      ],
    );
  }

  Widget _buildAssetDonationsChart() {
    final total = _assetDonations.fold<int>(
        0, (sum, item) => sum + item.quantity); // Calculate total

    return SfCircularChart(
      title: ChartTitle(text: 'Total Items: $total'),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.right,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        PieSeries<AssetDonation, String>(
          dataSource: _assetDonations,
          xValueMapper: (AssetDonation data, _) => data.type,
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
              '${data.type}\n${data.quantity}',
          radius: '80%',
           pointColorMapper: (AssetDonation data, index) =>
              _assetColors[index % _assetColors.length],
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
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<ResourceDistributionData, String>(
                    dataSource: _resourceDistributionData,
                    xValueMapper: (ResourceDistributionData data, _) => data.day,
                    yValueMapper: (ResourceDistributionData data, _) =>
                        data.incoming,
                    name: 'Incoming Donations',
                    color: _resourceColors[0],
                  ),
                  ColumnSeries<ResourceDistributionData, String>(
                    dataSource: _resourceDistributionData,
                    xValueMapper: (ResourceDistributionData data, _) => data.day,
                    yValueMapper: (ResourceDistributionData data, _) =>
                        data.outgoing,
                    name: 'Outgoing Donations',
                    color: _resourceColors[1],
                  ),
                ],
                legend: Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem(_resourceColors[0], 'Incoming Donations'),
                _buildLegendItem(_resourceColors[1], 'Outgoing Donations'),
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
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<DisasterTimelineData, String>(
                    dataSource: _disasterTimelineData,
                    xValueMapper: (DisasterTimelineData data, _) => data.day,
                    yValueMapper: (DisasterTimelineData data, _) => data.alive,
                    name: 'Alive',
                    color: _timelineColors[0],
                  ),
                  ColumnSeries<DisasterTimelineData, String>(
                    dataSource: _disasterTimelineData,
                    xValueMapper: (DisasterTimelineData data, _) => data.day,
                    yValueMapper: (DisasterTimelineData data, _) => data.missing,
                    name: 'Missing',
                    color: _timelineColors[1],
                  ),
                  ColumnSeries<DisasterTimelineData, String>(
                    dataSource: _disasterTimelineData,
                    xValueMapper: (DisasterTimelineData data, _) => data.day,
                    yValueMapper: (DisasterTimelineData data, _) => data.deceased,
                    name: 'Deceased',
                    color: _timelineColors[2],
                  ),
                ],
                legend: Legend(isVisible: true),
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem(_timelineColors[0], 'Alive'),
                _buildLegendItem(_timelineColors[1], 'Missing'),
                _buildLegendItem(_timelineColors[2], 'Deceased'),
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
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(text),
      ],
    );
  }
}

class DonationData {
  final String type;
  final String description;
  final double value; // Changed to double
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

class ResourceDistributionData {
  final String day;
  final int incoming;
  final int outgoing;

  ResourceDistributionData({
    required this.day,
    required this.incoming,
    required this.outgoing,
  });
}

class DisasterTimelineData {
  final String day;
  final int alive;
  final int missing;
  final int deceased;

  DisasterTimelineData({
    required this.day,
    required this.alive,
    required this.missing,
    required this.deceased,
  });
}

