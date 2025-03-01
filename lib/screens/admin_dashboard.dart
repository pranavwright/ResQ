import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildDashboardCard(
              context,
              'Families',
              Icons.family_restroom,
              '/families',
              Colors.blue,
            ),
            _buildDashboardCard(
              context,
              'Camp Status',
              Icons.home_work,
              '/camp-status',
              Colors.green,
            ),
            _buildDashboardCard(
              context,
              'Notice Board',
              Icons.announcement,
              '/notice-board',
              Colors.orange,
            ),
            _buildDashboardCard(
              context,
              'Collection Point',
              Icons.place,
              '/collection-point',
              Colors.purple,
            ),
            _buildDashboardCard(
              context,
              'Create Notice',
              Icons.create,
              '/create-notice',
              Colors.red,
            ),
            _buildDashboardCard(
              context,
              'Home',
              Icons.home,
              '/home',
              Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, 
      String route, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.7)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}