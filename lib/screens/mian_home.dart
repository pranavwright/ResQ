import 'package:flutter/material.dart';

class MainHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section with Image and Gradient Overlay
            Stack(
              children: [
                // Hero Image Section
                Container(
                  width: double.infinity,
                  height: height * 0.6, // Adjusted height based on screen height
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/hero-montain.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Semi-transparent Gradient Overlay for better text visibility
                Container(
                  width: double.infinity,
                  height: height * 0.6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
                // Positioned Welcome Text Over Image
                Positioned(
                  top: 80, // Adjust the position from the top
                  left: 20,
                  right: 20,
                  child: Text(
                    'Welcome to RESQ App',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 12.0,
                          color: Colors.black.withOpacity(0.7),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Main Text Section Below Hero Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Stay prepared, stay safe with RESQ.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

            // Navigation Section with Cards
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNavCard(context, 'App Download', '/app_download'),
                  _buildNavCard(context, 'Disaster Data', '/disaster_data'),
                  _buildNavCard(context, 'About', '/about'),
                  _buildNavCard(context, 'Login', '/login'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Card Widget for Navigation Links
  Widget _buildNavCard(BuildContext context, String title, String route) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
