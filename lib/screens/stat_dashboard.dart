import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  late TabController _tabController;
  
  // More sample data for better visualization
  List<FamilyData> familyData = List.generate(
    20,
    (index) => FamilyData('Region ${String.fromCharCode(65 + index)}', math.Random().nextInt(150) + 50),
  );

  List<LoanData> loanData = List.generate(
    24,
    (index) => LoanData(
        'Month ${index + 1}', 
        10000 + (index * 2500) + math.Random().nextInt(5000)),
  );

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
  _tabController = TabController(length: 4, vsync: this);
  _timer = Timer.periodic(const Duration(seconds: 3), (timer) => _updateData());
}
  @override
void dispose() {
  _tabController.dispose();
  _timer?.cancel();
  super.dispose();
}

  void _updateData() {
    setState(() {
      // Update family data with more variation
      familyData = familyData
          .map((data) => FamilyData(data.region, data.count + math.Random().nextInt(20) - 10))
          .toList();

      // Update loan data with growth trend
      loanData = loanData
          .map((data) => LoanData(data.month, data.amount + math.Random().nextInt(8000) - 2000))
          .toList();

      // Update donation data
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
       bottom: TabBar(
    controller: _tabController,
    tabs: const [
      Tab(text: 'Family Data'),
      Tab(text: 'Loan Relief'),
      Tab(text: 'Donations'),
      Tab(text: 'Role Management'),  // Add this tab
    ],
  ),
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Family Data Chart
            _buildChartCard(
              'Family Count by Region',
              _buildFamilyCountChart(),
              Colors.blue[700]!,
              Icons.people
            ),
            
            // Loan Relief Chart
            _buildChartCard(
              'Loan Relief Progress',
              _buildLoanReliefChart(),
              Colors.green[700]!,
              Icons.trending_up
            ),
            
            // Donations Chart
            _buildChartCard(
              'Donations Breakdown',
              _buildDonationsChart(),
              Colors.orange[700]!,
              Icons.pie_chart
            ),
            _buildRoleManagementTab(), 
            
            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/test-family'),
                  child: const Text('Family Data'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/loan-relief'),
                  child: const Text('Loan Relief'),
                ),
               ElevatedButton(
                 onPressed: () => Navigator.pushNamed(context, '/donations'),
                 style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.orange[700],
                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
  child: const Text('Add New Donation'),
),
              ],
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

  Widget _buildFamilyCountChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelRotation: 45,
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Number of Families'),
        labelFormat: '{value}',
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      series: <CartesianSeries>[
        ColumnSeries<FamilyData, String>(
          dataSource: familyData,
          xValueMapper: (FamilyData data, _) => data.region,
          yValueMapper: (FamilyData data, _) => data.count,
          name: 'Family Count',
          dataLabelSettings: const DataLabelSettings(
            isVisible: false,
          ),
          width: 0.6,
          spacing: 0.2,
          // Using a simpler approach for colors
          pointColorMapper: (FamilyData data, _) => 
            data.count > 150 ? Colors.red : 
            data.count > 100 ? Colors.orange : Colors.blue,
        ),
      ],
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableDoubleTapZooming: true,
      ),
    );
  }

  Widget _buildLoanReliefChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Amount (\$)'),
        numberFormat: NumberFormat.compact(),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      crosshairBehavior: CrosshairBehavior(
        enable: true,
        lineType: CrosshairLineType.both,
      ),
      trackballBehavior: TrackballBehavior(
        enable: true,
        tooltipSettings: const InteractiveTooltip(
          enable: true,
          format: 'Month: \${point.x} \nAmount: \${point.y}',
        ),
      ),
      series: <CartesianSeries>[
        LineSeries<LoanData, String>(
          dataSource: loanData,
          xValueMapper: (LoanData data, _) => data.month,
          yValueMapper: (LoanData data, _) => data.amount,
          name: 'Loan Relief',
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            height: 8,
            width: 8,
          ),
          color: Colors.green[600],
          width: 3,
        ),
        // Add area under the curve
        AreaSeries<LoanData, String>(
          dataSource: loanData,
          xValueMapper: (LoanData data, _) => data.month,
          yValueMapper: (LoanData data, _) => data.amount,
          name: 'Relief Trend',
          opacity: 0.3,
          color: Colors.green[300],
        ),
      ],
      zoomPanBehavior: ZoomPanBehavior(
        enablePinching: true,
        enablePanning: true,
        enableDoubleTapZooming: true,
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
Widget _buildRoleManagementTab() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Survey Volunteer Roles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Family Survey Volunteer Section
                  _buildRoleSection(
                    title: 'Family Survey Volunteer',
                    description: 'Responsible for conducting initial family surveys and data collection',
                    icon: Icons.family_restroom,
                    onAssign: () => _assignRole('familysurveyvolunteer'),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Verification Survey Volunteer Section
                  _buildRoleSection(
                    title: 'Verification Survey Volunteer',
                    description: 'Responsible for verifying and validating collected family data',
                    icon: Icons.verified_user,
                    onAssign: () => _assignRole('verificationsurveyvolunteer'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildRoleSection({
  required String title,
  required String description,
  required IconData icon,
  required VoidCallback onAssign,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: Colors.blue[700]),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: onAssign,
              icon: const Icon(Icons.person_add),
              label: const Text('Assign Role'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void _assignRole(String role) {
  // TODO: Implement role assignment logic
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Assign Role'),
      content: const Text('Are you sure you want to assign this role?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement role assignment to backend
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Role assigned successfully'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
}
  int _getTotalDonations() {
    return donationData.map((data) => data.value).reduce((a, b) => a + b).toInt();
  }
}

// Data models for better type safety
class FamilyData {
  final String region;
  final int count;
  FamilyData(this.region, this.count);
}

class LoanData {
  final String month;
  final int amount;
  LoanData(this.month, this.amount);
}

// Replace lines 301-305 with this:
class DonationData {
  final String type;      // 'money' or 'assets'
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