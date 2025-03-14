import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainHome extends StatelessWidget {
  // Create a ScrollController
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    // Set system UI overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController, // Attach ScrollController
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Hero Section with parallax effect
            Stack(
              children: [
                // Hero Image with Parallax Scroll Effect
                Container(
                  width: double.infinity,
                  height: height * 0.65,
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black, Colors.transparent],
                      ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height),
                      );
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.asset(
                      'assets/images/hero-montain.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Gradient Overlay
                Container(
                  width: double.infinity,
                  height: height * 0.65,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Color(0xFF0C3B5E).withOpacity(0.85),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: height * 0.15,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(8),
                        child: Image.asset(
                          'images/logo.jpg',
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading logo: $error');
                            return Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFFF6B35),
                              size: 40,
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 24),

                      // Main headline
                      Text(
                        'Disaster Response\nMade Simple',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Subheadline
                      Text(
                        'Connecting communities with emergency services when they need it most.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: 32),

                      // CTA Buttons
                      Row(
                        children: [
                          // Primary CTA
                          ElevatedButton(
                            onPressed:
                                () => Navigator.pushNamed(context, '/otp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF6B35),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(width: 16),

                          // Secondary CTA
                          // OutlinedButton(
                          //   onPressed:
                          //       () => Navigator.pushNamed(context, '/about'),
                          //   style: OutlinedButton.styleFrom(
                          //     foregroundColor: Colors.white,
                          //     side: BorderSide(color: Colors.white, width: 1.5),
                          //     padding: EdgeInsets.symmetric(
                          //       horizontal: 24,
                          //       vertical: 16,
                          //     ),
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(12),
                          //     ),
                          //   ),
                          //   child: Text(
                          //     'Learn More',
                          //     style: TextStyle(
                          //       fontSize: 16,
                          //       fontWeight: FontWeight.w500,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Scroll indicator
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        // Scroll to the next section when tapped
                        _scrollController.animateTo(
                          height * 1.0, // Adjust the scroll position
                          duration: Duration(seconds: 1),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Features Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Essential Tools',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C3B5E),
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Everything you need during emergency situations',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Features Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildFeatureCard(
                        context,
                        icon: Icons.download_rounded,
                        title: 'App Download',
                        description: 'Get mobile access for offline use',
                        route: '/download',
                        color: Color(0xFF4CAF50),
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.assessment_rounded,
                        title: 'Disaster Data',
                        description: 'Real-time information and statistics',
                        route: '/disaster',
                        color: Color(0xFF2196F3),
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.contact_support_rounded,
                        title: 'About RESQ',
                        description: 'Learn about our mission and impact',
                        route: '/about',
                        color: Color(0xFF9C27B0),
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.login_rounded,
                        title: 'Login / Register',
                        description: 'Access your RESQ account',
                        route: '/otp',
                        color: Color(0xFFFF6B35),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Statistics / Impact Section
            Container(
              padding: EdgeInsets.symmetric(vertical: 36),
              color: Color(0xFFF5F7FA),
              child: Column(
                children: [
                  Text(
                    'Our Impact',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C3B5E),
                    ),
                  ),

                  SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatistic('5K+', 'People Helped'),
                      _buildStatistic('20+', 'Communities'),
                      _buildStatistic('100+', 'Volunteers'),
                    ],
                  ),
                ],
              ),
            ),

            // Emergency Contact Section
            Padding(
              padding: EdgeInsets.fromLTRB(24, 36, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Contacts',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0C3B5E),
                    ),
                  ),

                  SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD32F2F), Color(0xFFFF5252)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.phone_in_talk_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),

                        SizedBox(width: 16),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Helpline',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              '112',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  _buildContactCard(
                    icon: Icons.medical_services_rounded,
                    title: 'Medical Emergency',
                    number: '108',
                    color: Color(0xFF42A5F5),
                  ),

                  _buildContactCard(
                    icon: Icons.fire_truck_rounded,
                    title: 'Fire Department',
                    number: '101',
                    color: Color(0xFFFFA726),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24),
              color: Color(0xFF0C3B5E),
              child: Column(
                children: [
                  Text(
                    'RESQ Initiative',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    '© 2025 All Rights Reserved',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Feature Card Widget
  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String route,
    required Color color,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 30, color: color),
            ),

            SizedBox(height: 12),

            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C3B5E),
              ),
            ),

            SizedBox(height: 4),

            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Statistic Widget
  Widget _buildStatistic(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFF6B35),
          ),
        ),

        SizedBox(height: 8),

        Text(label, style: TextStyle(fontSize: 16, color: Colors.black54)),
      ],
    );
  }

  // Contact Card Widget
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String number,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          SizedBox(width: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 4),

              Text(
                number,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
